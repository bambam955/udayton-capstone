import { randomUUID } from 'node:crypto';

import { Kysely, PostgresDialect, sql } from 'kysely';
import { Pool } from 'pg';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';

import { KyselyMobileRepository } from '../../../modules/mobile/repository.js';
import type { Database } from '../../../platform/db/types.js';

const describeIfDatabase = process.env.DATABASE_URL ? describe : describe.skip;

describeIfDatabase('mobile repository integration', () => {
  let pool: Pool;
  let db: Kysely<Database>;
  let repository: KyselyMobileRepository;

  beforeAll(() => {
    pool = new Pool({
      connectionString: process.env.DATABASE_URL,
      max: 10
    });
    db = new Kysely<Database>({
      dialect: new PostgresDialect({ pool })
    });
    repository = new KyselyMobileRepository(db);
  });

  afterAll(async () => {
    await db.destroy();
    await pool.end();
  });

  it('allows only one driver to accept the same delivery concurrently', async () => {
    const fixture = await createAcceptFixture(db);
    const [firstDriverId, secondDriverId] = fixture.driverIds;

    try {
      const results = await Promise.allSettled([
        repository.acceptDelivery(firstDriverId, fixture.deliveryId),
        repository.acceptDelivery(secondDriverId, fixture.deliveryId)
      ]);
      const fulfilled = results.filter((result) => result.status === 'fulfilled');
      const rejected = results.filter(
        (result): result is PromiseRejectedResult => result.status === 'rejected'
      );

      expect(fulfilled).toHaveLength(1);
      expect(rejected).toHaveLength(1);
      expect((rejected[0]?.reason as { code?: string } | undefined)?.code).toBe('CONFLICT');

      const assignment = await db
        .selectFrom('delivery_assignments')
        .select(['driver_id as driverId', 'status'])
        .where('delivery_id', '=', fixture.deliveryId)
        .executeTakeFirstOrThrow();

      expect(assignment.status).toBe('ASSIGNED');
      expect(fixture.driverIds).toContain(assignment.driverId ?? '');

      const offer = await db
        .selectFrom('delivery_offers')
        .select('status')
        .where('delivery_id', '=', fixture.deliveryId)
        .executeTakeFirstOrThrow();

      expect(offer.status).toBe('ACCEPTED');
    } finally {
      await cleanupFixture(db, fixture);
    }
  });

  it('returns the same order when the same cart is checked out twice concurrently', async () => {
    const fixture = await createCheckoutFixture(db);

    try {
      const firstRequest = repository.checkout(fixture.customerId, {
        cartId: fixture.cartId,
        addressId: fixture.addressId,
        deliveryNotes: 'Leave at concierge',
        tipCents: 250
      });
      const secondRequest = repository.checkout(fixture.customerId, {
        cartId: fixture.cartId,
        addressId: fixture.addressId,
        deliveryNotes: 'Leave at concierge',
        tipCents: 250
      });

      const [firstResult, secondResult] = await Promise.all([firstRequest, secondRequest]);

      expect(firstResult.order.orderId).toBe(secondResult.order.orderId);
      expect(firstResult.delivery.deliveryId).toBe(secondResult.delivery.deliveryId);
      expect(firstResult.payment.paymentId).toBe(secondResult.payment.paymentId);
      expect(firstResult.pricing.subtotalCents).toBe(2400);

      const orderCount = await countRows(db, 'orders', 'customer_id', fixture.customerId);
      const paymentCount = await countRows(db, 'payments', 'customer_id', fixture.customerId);
      const assignmentCount = await countDeliveryAssignmentsForCustomer(db, fixture.customerId);
      const offerCount = await countDeliveryOffersForCustomer(db, fixture.customerId);

      expect(orderCount).toBe(1);
      expect(paymentCount).toBe(1);
      expect(assignmentCount).toBe(1);
      expect(offerCount).toBe(1);

      const orderItem = await db
        .selectFrom('order_items')
        .select([
          'external_sku as externalSku',
          'name_snapshot as nameSnapshot',
          'unit_price_cents as unitPriceCents'
        ])
        .where('order_id', '=', firstResult.order.orderId)
        .executeTakeFirstOrThrow();

      expect(orderItem.externalSku).toBe('ITEM-1');
      expect(orderItem.nameSnapshot).toBe('Olive Oil');
      expect(Number(orderItem.unitPriceCents ?? 0)).toBe(1200);
    } finally {
      await cleanupFixture(db, fixture);
    }
  });

  it('hides and rejects expired offers', async () => {
    const fixture = await createAcceptFixture(db, {
      offerAgeSeconds: 600,
      expiresInSec: 300
    });
    const [driverId] = fixture.driverIds;

    try {
      const bootstrap = await repository.getDriverBootstrap(driverId);
      expect(bootstrap.availableJobs).toEqual([]);

      await expect(repository.acceptDelivery(driverId, fixture.deliveryId)).rejects.toMatchObject({
        code: 'CONFLICT'
      });

      const offers = await db
        .selectFrom('delivery_offers')
        .select('status')
        .where('delivery_id', '=', fixture.deliveryId)
        .orderBy('offer_id')
        .execute();

      expect(
        offers.every((offer) => offer.status === 'EXPIRED' || offer.status === 'OFFERED')
      ).toBe(true);
      expect(offers.some((offer) => offer.status === 'EXPIRED')).toBe(true);
    } finally {
      await cleanupFixture(db, fixture);
    }
  });

  it('shows shared offers as soon as an offline driver goes online', async () => {
    const fixture = await createAcceptFixture(db, {
      driverStatuses: ['OFFLINE', 'ONLINE']
    });
    const [driverId] = fixture.driverIds;

    try {
      const offlineBootstrap = await repository.getDriverBootstrap(driverId);
      expect(offlineBootstrap.availableJobs).toEqual([]);

      await db
        .updateTable('drivers')
        .set({ status: 'ONLINE' })
        .where('driver_id', '=', driverId)
        .execute();

      const onlineBootstrap = await repository.getDriverBootstrap(driverId);
      expect(onlineBootstrap.availableJobs).toHaveLength(1);
      expect(onlineBootstrap.availableJobs[0]?.deliveryId).toBe(fixture.deliveryId);
    } finally {
      await cleanupFixture(db, fixture);
    }
  });
});

async function countRows(
  db: Kysely<Database>,
  table: 'orders' | 'payments',
  column: 'customer_id',
  value: string
): Promise<number> {
  const result = await db
    .selectFrom(table)
    .select(sql<number>`count(*)::int`.as('count'))
    .where(column, '=', value)
    .executeTakeFirstOrThrow();

  return Number(result.count ?? 0);
}

async function countDeliveryAssignmentsForCustomer(
  db: Kysely<Database>,
  customerId: string
): Promise<number> {
  const result = await db
    .selectFrom('delivery_assignments as da')
    .innerJoin('orders as o', 'o.order_id', 'da.order_id')
    .select(sql<number>`count(*)::int`.as('count'))
    .where('o.customer_id', '=', customerId)
    .executeTakeFirstOrThrow();

  return Number(result.count ?? 0);
}

async function countDeliveryOffersForCustomer(
  db: Kysely<Database>,
  customerId: string
): Promise<number> {
  const result = await db
    .selectFrom('delivery_offers as offer')
    .innerJoin('orders as o', 'o.order_id', 'offer.order_id')
    .select(sql<number>`count(*)::int`.as('count'))
    .where('o.customer_id', '=', customerId)
    .executeTakeFirstOrThrow();

  return Number(result.count ?? 0);
}

async function createAcceptFixture(
  db: Kysely<Database>,
  options?: {
    offerAgeSeconds?: number;
    expiresInSec?: number;
    driverStatuses?: readonly string[];
  }
) {
  const customerId = randomUUID();
  const addressId = randomUUID();
  const retailerId = randomUUID();
  const orderId = randomUUID();
  const deliveryId = randomUUID();
  const driverIds = [randomUUID(), randomUUID()] as const;
  const now = new Date();
  const offerAgeSeconds = options?.offerAgeSeconds ?? 0;
  const expiresInSec = options?.expiresInSec ?? 300;
  const offeredAt = new Date(now.getTime() - offerAgeSeconds * 1000);

  await db
    .insertInto('customers')
    .values({
      customer_id: customerId,
      email: `customer-${customerId}@example.com`,
      password_hash: 'secret',
      is_active: true,
      created_at: now,
      updated_at: now
    })
    .execute();

  await db
    .insertInto('addresses')
    .values({
      address_id: addressId,
      customer_id: customerId,
      label: 'Home',
      line1: '1 Elm St',
      city: 'Charlotte',
      state: 'NC',
      postal_code: '28202',
      country: 'USA',
      is_default: true,
      created_at: now
    })
    .execute();

  await db
    .insertInto('retailers')
    .values({
      retailer_id: retailerId,
      name: `Retailer ${retailerId}`,
      is_enabled: true,
      created_at: now
    })
    .execute();

  await db
    .insertInto('drivers')
    .values(
      driverIds.map((driverId, index) => ({
        driver_id: driverId,
        email: `driver-${index}-${driverId}@example.com`,
        password_hash: 'secret',
        full_name: `Driver ${index + 1}`,
        is_active: true,
        status: options?.driverStatuses?.[index] ?? 'ONLINE',
        created_at: now,
        updated_at: now
      }))
    )
    .execute();

  await db
    .insertInto('orders')
    .values({
      order_id: orderId,
      customer_id: customerId,
      retailer_id: retailerId,
      retailer_location_id: null,
      address_id: addressId,
      external_order_id: `ORD-${orderId.slice(0, 8).toUpperCase()}`,
      status: 'SUBMITTED',
      placed_at: now,
      subtotal_cents: 1200,
      fees_cents: 300,
      tip_cents: 200,
      discount_cents: 0,
      total_cents: 1700,
      currency: 'USD',
      delivery_notes: null,
      created_at: now,
      updated_at: now
    })
    .execute();

  await db
    .insertInto('delivery_assignments')
    .values({
      delivery_id: deliveryId,
      order_id: orderId,
      driver_id: null,
      status: 'PENDING_ASSIGNMENT',
      pickup_location: 'Downtown Market',
      assigned_at: null,
      picked_up_at: null,
      delivered_at: null
    })
    .execute();

  await db
    .insertInto('delivery_offers')
    .values({
      offer_id: randomUUID(),
      order_id: orderId,
      delivery_id: deliveryId,
      status: 'OFFERED',
      offered_at: offeredAt,
      responded_at: null,
      expires_in_sec: expiresInSec,
      decline_reason: null
    })
    .execute();

  return {
    customerId,
    retailerId,
    driverIds,
    deliveryId
  };
}

async function createCheckoutFixture(db: Kysely<Database>) {
  const customerId = randomUUID();
  const addressId = randomUUID();
  const retailerId = randomUUID();
  const retailerLocationId = randomUUID();
  const retailerAccountId = randomUUID();
  const categoryId = randomUUID();
  const productId = randomUUID();
  const cartId = randomUUID();
  const cartItemId = randomUUID();
  const now = new Date();

  await db
    .insertInto('customers')
    .values({
      customer_id: customerId,
      email: `customer-${customerId}@example.com`,
      password_hash: 'secret',
      is_active: true,
      created_at: now,
      updated_at: now
    })
    .execute();

  await db
    .insertInto('addresses')
    .values({
      address_id: addressId,
      customer_id: customerId,
      label: 'Home',
      line1: '1 Elm St',
      city: 'Charlotte',
      state: 'NC',
      postal_code: '28202',
      country: 'USA',
      is_default: true,
      created_at: now
    })
    .execute();

  await db
    .insertInto('retailers')
    .values({
      retailer_id: retailerId,
      name: `Retailer ${retailerId}`,
      is_enabled: true,
      created_at: now
    })
    .execute();

  await db
    .insertInto('retailer_locations')
    .values({
      retailer_location_id: retailerLocationId,
      retailer_id: retailerId,
      external_store_id: null,
      name: 'Downtown Market',
      address_line1: '100 Main St',
      address_line2: null,
      city: 'Charlotte',
      state: 'NC',
      postal_code: '28202',
      country: 'USA',
      lat: 35.2271,
      lng: -80.8431,
      is_active: true,
      created_at: now,
      updated_at: now
    })
    .execute();

  await db
    .insertInto('retailer_accounts')
    .values({
      retailer_account_id: retailerAccountId,
      customer_id: customerId,
      retailer_id: retailerId,
      is_connected: true,
      access_token: `token-${retailerAccountId}`,
      refresh_token: `refresh-${retailerAccountId}`,
      token_expires_at: new Date(now.getTime() + 60_000),
      created_at: now,
      updated_at: now
    })
    .execute();

  await db
    .insertInto('product_categories')
    .values({
      category_id: categoryId,
      retailer_id: retailerId,
      name: 'Pantry',
      external_category_id: null,
      updated_at: now
    })
    .execute();

  await db
    .insertInto('products')
    .values({
      product_id: productId,
      retailer_id: retailerId,
      category_id: categoryId,
      external_sku: 'ITEM-1',
      name: 'Olive Oil',
      description: null,
      image_url: null,
      unit_price_cents: 1200,
      currency: 'USD',
      is_available: true,
      updated_at: now
    })
    .execute();

  await db
    .insertInto('carts')
    .values({
      cart_id: cartId,
      customer_id: customerId,
      retailer_id: retailerId,
      retailer_location_id: retailerLocationId,
      checked_out_order_id: null,
      status: 'ACTIVE',
      created_at: now,
      updated_at: now
    })
    .execute();

  await db
    .insertInto('cart_items')
    .values({
      cart_item_id: cartItemId,
      cart_id: cartId,
      product_id: productId,
      external_sku: 'SPOOFED-SKU',
      name_snapshot: 'Spoofed Name',
      unit_price_cents: 1,
      quantity: 2,
      substitution_allowed: true,
      notes: null,
      created_at: now
    })
    .execute();

  return {
    customerId,
    retailerId,
    driverIds: [] as string[],
    deliveryId: '',
    cartId,
    addressId
  };
}

async function cleanupFixture(
  db: Kysely<Database>,
  fixture: {
    customerId: string;
    retailerId: string;
    driverIds: readonly string[];
  }
) {
  if (fixture.driverIds.length > 0) {
    await db.deleteFrom('drivers').where('driver_id', 'in', fixture.driverIds).execute();
  }

  await db.deleteFrom('customers').where('customer_id', '=', fixture.customerId).execute();
  await db.deleteFrom('retailers').where('retailer_id', '=', fixture.retailerId).execute();
}
