import { randomUUID } from 'node:crypto';

import { Kysely, sql, Transaction } from 'kysely';

import { HttpError } from '../../app/errors.js';
import type { Database } from '../../platform/db/types.js';
import type {
  CustomerAddressSummary,
  CustomerBootstrapResult,
  CustomerCartSummary,
  CustomerCatalogInput,
  CustomerCatalogResult,
  CustomerCheckoutInput,
  CustomerCheckoutResult,
  CustomerOrderSummary,
  CustomerRetailerConnectionResult,
  CustomerRetailerSummary,
  CustomerSupportTicketSummary,
  DriverBootstrapResult,
  DriverEarningsSummary,
  DriverJobSummary,
  DriverSupportTicketSummary,
  MobileRepository,
  RetailerLocationSummary
} from './types.js';

type DbExecutor = Kysely<Database> | Transaction<Database>;

function toNumber(value: number | string | null | undefined): number {
  if (typeof value === 'number') {
    return value;
  }

  if (typeof value === 'string' && value.length > 0) {
    return Number(value);
  }

  return 0;
}

function clamp(value: number, min: number, max: number): number {
  return Math.min(Math.max(value, min), max);
}

function humanize(value: string | null | undefined, fallback: string): string {
  if (!value) {
    return fallback;
  }

  return value
    .toLowerCase()
    .split(/[_\s]+/)
    .filter(Boolean)
    .map((part) => `${part[0]?.toUpperCase() ?? ''}${part.slice(1)}`)
    .join(' ');
}

function formatAddress(parts: Array<string | null | undefined>): string {
  return parts
    .map((part) => part?.trim())
    .filter((part): part is string => Boolean(part))
    .join(', ');
}

function formatIso(value: Date | string | null | undefined): string | null {
  if (!value) {
    return null;
  }

  return typeof value === 'string' ? value : value.toISOString();
}

function buildRetailerLocationSummary(row: {
  retailerLocationId: string;
  retailerId: string;
  externalStoreId: string | null;
  name: string | null;
  addressLine1: string | null;
  addressLine2: string | null;
  city: string | null;
  state: string | null;
  postalCode: string | null;
  country: string | null;
  lat: number | string | null;
  lng: number | string | null;
  isActive: boolean | null;
}): RetailerLocationSummary {
  return {
    retailerLocationId: row.retailerLocationId,
    retailerId: row.retailerId,
    externalStoreId: row.externalStoreId,
    name: row.name ?? 'Partner location',
    addressLine: formatAddress([
      row.addressLine1,
      row.addressLine2,
      row.city,
      row.state,
      row.postalCode
    ]),
    city: row.city,
    state: row.state,
    postalCode: row.postalCode,
    country: row.country,
    lat: row.lat === null ? null : toNumber(row.lat),
    lng: row.lng === null ? null : toNumber(row.lng),
    isActive: row.isActive === true
  };
}

function buildCustomerCartSummary(row: {
  cartId: string;
  retailerId: string;
  retailerLocationId: string | null;
  status: string | null;
  itemCount: number | string | null;
  subtotalCents: number | string | null;
}): CustomerCartSummary {
  return {
    cartId: row.cartId,
    retailerId: row.retailerId,
    retailerLocationId: row.retailerLocationId,
    status: row.status,
    itemCount: toNumber(row.itemCount),
    subtotalCents: toNumber(row.subtotalCents)
  };
}

function buildCustomerOrderSummary(row: {
  orderId: string;
  externalOrderId: string | null;
  retailerId: string;
  retailerName: string | null;
  retailerLocationId: string | null;
  retailerLocationName: string | null;
  status: string | null;
  placedAt: Date | string | null;
  totalCents: number | string | null;
  currency: string | null;
  itemCount: number | string | null;
}): CustomerOrderSummary {
  return {
    orderId: row.orderId,
    externalOrderId: row.externalOrderId,
    retailerId: row.retailerId,
    retailerName: row.retailerName ?? 'Retailer',
    retailerLocationId: row.retailerLocationId,
    retailerLocationName: row.retailerLocationName,
    status: row.status,
    placedAt: formatIso(row.placedAt),
    totalCents: toNumber(row.totalCents),
    currency: row.currency,
    itemCount: toNumber(row.itemCount)
  };
}

function estimateBasePay(totalCents: number): number {
  return Math.max(650, Math.round(totalCents * 0.18));
}

function estimateDistanceMiles(itemCount: number): number {
  return Math.round(clamp(3 + itemCount * 0.75, 3, 18) * 10) / 10;
}

function estimateEtaMinutes(itemCount: number): number {
  return clamp(18 + itemCount * 4, 20, 60);
}

function stageFromAssignment(status: string | null): DriverJobSummary['stage'] {
  const normalized = status?.toUpperCase() ?? '';

  if (normalized === 'DELIVERED') {
    return 'delivered';
  }

  if (normalized === 'OUT_FOR_DELIVERY' || normalized === 'IN_TRANSIT') {
    return 'out_for_delivery';
  }

  return 'assigned';
}

function buildDriverJobSummary(row: {
  deliveryId: string;
  orderId: string;
  title: string | null;
  pickupLocationId: string | null;
  pickupName: string | null;
  pickupAddressLine: string;
  pickupLat: number | string | null;
  pickupLng: number | string | null;
  dropoffName: string;
  dropoffAddressLine: string;
  zone: string;
  totalCents: number | string | null;
  tipCents: number | string | null;
  earningBasePayCents: number | string | null;
  earningTipCents: number | string | null;
  earningTotalPayCents: number | string | null;
  itemCount: number | string | null;
  assignmentStatus: string | null;
  stage: DriverJobSummary['stage'];
  deliveryNotes: string | null;
}): DriverJobSummary {
  const itemCount = toNumber(row.itemCount);
  const orderTipCents = toNumber(row.tipCents);
  const basePayCents =
    row.earningBasePayCents === null
      ? estimateBasePay(toNumber(row.totalCents))
      : toNumber(row.earningBasePayCents);
  const tipCents = row.earningTipCents === null ? orderTipCents : toNumber(row.earningTipCents);
  const payoutEstimateCents =
    row.earningTotalPayCents === null
      ? basePayCents + tipCents
      : toNumber(row.earningTotalPayCents);

  return {
    deliveryId: row.deliveryId,
    orderId: row.orderId,
    title: row.title ?? `${row.pickupName ?? 'Pickup'} Delivery`,
    pickupLocationId: row.pickupLocationId,
    pickupName: row.pickupName ?? 'Partner pickup',
    pickupAddressLine: row.pickupAddressLine,
    pickupLat: row.pickupLat === null ? null : toNumber(row.pickupLat),
    pickupLng: row.pickupLng === null ? null : toNumber(row.pickupLng),
    dropoffName: row.dropoffName,
    dropoffAddressLine: row.dropoffAddressLine,
    zone: row.zone,
    payoutEstimateCents,
    distanceMiles: estimateDistanceMiles(itemCount),
    etaMinutes: estimateEtaMinutes(itemCount),
    stage: row.stage,
    detailLines: [
      `Status: ${humanize(row.assignmentStatus, 'Pending')}`,
      `Items: ${itemCount}`,
      row.deliveryNotes?.trim() ? `Note: ${row.deliveryNotes.trim()}` : 'Proof required at drop-off'
    ],
    basePayCents,
    tipCents
  };
}

export class KyselyMobileRepository implements MobileRepository {
  constructor(private readonly db: Kysely<Database>) {}

  async getCustomerBootstrap(customerId: string): Promise<CustomerBootstrapResult> {
    const customer = await this.db
      .selectFrom('customers')
      .select(['customer_id as id', 'email', 'full_name as fullName'])
      .where('customer_id', '=', customerId)
      .executeTakeFirst();

    if (!customer) {
      throw new HttpError(404, 'NOT_FOUND', 'Customer not found.');
    }

    const retailers = await this.db
      .selectFrom('retailers as r')
      .leftJoin('retailer_accounts as ra', (join) =>
        join.onRef('ra.retailer_id', '=', 'r.retailer_id').on('ra.customer_id', '=', customerId)
      )
      .select([
        'r.retailer_id as retailerId',
        'r.name',
        'r.website',
        sql<boolean>`coalesce(r.is_enabled, false)`.as('isEnabled'),
        sql<boolean>`coalesce(ra.is_connected, false)`.as('isConnected')
      ])
      .orderBy('r.name')
      .execute();

    const locations = await this.db
      .selectFrom('retailer_locations as rl')
      .select([
        'rl.retailer_location_id as retailerLocationId',
        'rl.retailer_id as retailerId',
        'rl.external_store_id as externalStoreId',
        'rl.name',
        'rl.address_line1 as addressLine1',
        'rl.address_line2 as addressLine2',
        'rl.city',
        'rl.state',
        'rl.postal_code as postalCode',
        'rl.country',
        'rl.lat',
        'rl.lng',
        'rl.is_active as isActive'
      ])
      .where('rl.is_active', '=', true)
      .orderBy('rl.name')
      .execute();

    const locationsByRetailer = new Map<string, RetailerLocationSummary[]>();
    for (const location of locations) {
      const summary = buildRetailerLocationSummary(location);
      const group = locationsByRetailer.get(summary.retailerId) ?? [];
      group.push(summary);
      locationsByRetailer.set(summary.retailerId, group);
    }

    const retailerSummaries: CustomerRetailerSummary[] = retailers.map((retailer) => ({
      retailerId: retailer.retailerId,
      name: retailer.name ?? 'Retailer',
      website: retailer.website,
      isEnabled: retailer.isEnabled === true,
      isConnected: retailer.isConnected === true,
      locations: locationsByRetailer.get(retailer.retailerId) ?? []
    }));

    const addresses = await this.db
      .selectFrom('addresses')
      .select([
        'address_id as addressId',
        'label',
        'line1',
        'line2',
        'city',
        'state',
        'postal_code as postalCode',
        'country',
        'instructions',
        'is_default as isDefault'
      ])
      .where('customer_id', '=', customerId)
      .orderBy('is_default desc')
      .orderBy('created_at desc')
      .execute();

    const addressSummaries: CustomerAddressSummary[] = addresses.map((address) => ({
      addressId: address.addressId,
      label: address.label,
      line1: address.line1,
      line2: address.line2,
      city: address.city,
      state: address.state,
      postalCode: address.postalCode,
      country: address.country,
      instructions: address.instructions,
      isDefault: address.isDefault === true,
      addressLine: formatAddress([
        address.line1,
        address.line2,
        address.city,
        address.state,
        address.postalCode
      ])
    }));

    const carts = await this.db
      .selectFrom('carts as c')
      .leftJoin('cart_items as ci', 'ci.cart_id', 'c.cart_id')
      .select([
        'c.cart_id as cartId',
        'c.retailer_id as retailerId',
        'c.retailer_location_id as retailerLocationId',
        'c.status',
        sql<number>`coalesce(count(ci.cart_item_id), 0)`.as('itemCount'),
        sql<number>`coalesce(sum(coalesce(ci.unit_price_cents, 0) * coalesce(ci.quantity, 0)), 0)`.as(
          'subtotalCents'
        )
      ])
      .where('c.customer_id', '=', customerId)
      .groupBy(['c.cart_id', 'c.retailer_id', 'c.retailer_location_id', 'c.status', 'c.updated_at'])
      .orderBy('c.updated_at desc')
      .execute();

    const orders = await this.db
      .selectFrom('orders as o')
      .innerJoin('retailers as r', 'r.retailer_id', 'o.retailer_id')
      .leftJoin('retailer_locations as rl', 'rl.retailer_location_id', 'o.retailer_location_id')
      .select([
        'o.order_id as orderId',
        'o.external_order_id as externalOrderId',
        'o.retailer_id as retailerId',
        'r.name as retailerName',
        'o.retailer_location_id as retailerLocationId',
        'rl.name as retailerLocationName',
        'o.status',
        'o.placed_at as placedAt',
        'o.total_cents as totalCents',
        'o.currency',
        sql<number>`(
          select count(*)::int
          from order_items oi
          where oi.order_id = o.order_id
        )`.as('itemCount')
      ])
      .where('o.customer_id', '=', customerId)
      .orderBy('o.created_at desc')
      .limit(20)
      .execute();

    const supportTickets = await this.db
      .selectFrom('support_tickets')
      .select([
        'ticket_id as ticketId',
        'order_id as orderId',
        'issue_type as issueType',
        'status',
        'message'
      ])
      .where('customer_id', '=', customerId)
      .orderBy('updated_at desc')
      .limit(20)
      .execute();

    const supportSummaries: CustomerSupportTicketSummary[] = supportTickets.map((ticket) => ({
      ticketId: ticket.ticketId,
      orderId: ticket.orderId,
      title: humanize(ticket.issueType, 'Support ticket'),
      status: ticket.status,
      summary: ticket.message ?? 'No details provided.'
    }));

    return {
      customer: customer,
      retailers: retailerSummaries,
      addresses: addressSummaries,
      carts: carts.map(buildCustomerCartSummary),
      orders: orders.map(buildCustomerOrderSummary),
      supportTickets: supportSummaries,
      defaultAddressId: addressSummaries.find((address) => address.isDefault)?.addressId ?? null
    };
  }

  async getCustomerCatalog(
    customerId: string,
    input: CustomerCatalogInput
  ): Promise<CustomerCatalogResult> {
    const locationRow = await this.db
      .selectFrom('retailer_locations as rl')
      .innerJoin('retailers as r', 'r.retailer_id', 'rl.retailer_id')
      .select([
        'rl.retailer_location_id as retailerLocationId',
        'rl.retailer_id as retailerId',
        'rl.external_store_id as externalStoreId',
        'rl.name',
        'rl.address_line1 as addressLine1',
        'rl.address_line2 as addressLine2',
        'rl.city',
        'rl.state',
        'rl.postal_code as postalCode',
        'rl.country',
        'rl.lat',
        'rl.lng',
        'rl.is_active as isActive',
        'r.name as retailerName'
      ])
      .where('rl.retailer_location_id', '=', input.retailerLocationId)
      .executeTakeFirst();

    if (!locationRow) {
      throw new HttpError(404, 'NOT_FOUND', 'Retailer location not found.');
    }

    const categories = await this.db
      .selectFrom('product_categories')
      .select(['category_id as categoryId', 'name'])
      .where('retailer_id', '=', locationRow.retailerId)
      .orderBy('name')
      .execute();

    let productQuery = this.db
      .selectFrom('products as p')
      .innerJoin('product_categories as c', 'c.category_id', 'p.category_id')
      .select([
        'p.product_id as productId',
        'p.retailer_id as retailerId',
        'p.category_id as categoryId',
        'c.name as categoryName',
        'p.external_sku as externalSku',
        'p.name',
        'p.description',
        'p.image_url as imageUrl',
        'p.unit_price_cents as unitPriceCents',
        'p.currency',
        sql<boolean>`coalesce(p.is_available, false)`.as('isAvailable')
      ])
      .where('p.retailer_id', '=', locationRow.retailerId)
      .where('p.is_available', '=', true);

    if (input.category) {
      productQuery = productQuery.where('c.name', '=', input.category);
    }

    if (input.query) {
      const pattern = `%${input.query.trim()}%`;
      productQuery = productQuery.where((eb) =>
        eb.or([
          eb('p.name', 'ilike', pattern),
          eb('p.description', 'ilike', pattern),
          eb('c.name', 'ilike', pattern)
        ])
      );
    }

    const products = await productQuery.orderBy('p.name').limit(100).execute();

    const cartRow = await this.db
      .selectFrom('carts as c')
      .leftJoin('cart_items as ci', 'ci.cart_id', 'c.cart_id')
      .select([
        'c.cart_id as cartId',
        'c.retailer_id as retailerId',
        'c.retailer_location_id as retailerLocationId',
        'c.status',
        sql<number>`coalesce(count(ci.cart_item_id), 0)`.as('itemCount'),
        sql<number>`coalesce(sum(coalesce(ci.unit_price_cents, 0) * coalesce(ci.quantity, 0)), 0)`.as(
          'subtotalCents'
        )
      ])
      .where('c.customer_id', '=', customerId)
      .where('c.retailer_location_id', '=', input.retailerLocationId)
      .groupBy(['c.cart_id', 'c.retailer_id', 'c.retailer_location_id', 'c.status', 'c.updated_at'])
      .orderBy('c.updated_at desc')
      .executeTakeFirst();

    return {
      location: buildRetailerLocationSummary(locationRow),
      retailer: {
        retailerId: locationRow.retailerId,
        name: locationRow.retailerName ?? 'Retailer'
      },
      categories: categories.map((category) => ({
        categoryId: category.categoryId,
        name: category.name ?? 'Uncategorized'
      })),
      products: products.map((product) => ({
        productId: product.productId,
        retailerId: product.retailerId,
        categoryId: product.categoryId,
        categoryName: product.categoryName ?? 'Uncategorized',
        externalSku: product.externalSku,
        name: product.name ?? 'Item',
        description: product.description,
        imageUrl: product.imageUrl,
        unitPriceCents: toNumber(product.unitPriceCents),
        currency: product.currency ?? 'USD',
        isAvailable: product.isAvailable === true
      })),
      cart: cartRow ? buildCustomerCartSummary(cartRow) : null
    };
  }

  async setRetailerConnection(
    customerId: string,
    retailerId: string,
    isConnected: boolean
  ): Promise<CustomerRetailerConnectionResult> {
    const retailer = await this.db
      .selectFrom('retailers')
      .select('retailer_id')
      .where('retailer_id', '=', retailerId)
      .executeTakeFirst();

    if (!retailer) {
      throw new HttpError(404, 'NOT_FOUND', 'Retailer not found.');
    }

    const now = new Date();

    await this.db
      .insertInto('retailer_accounts')
      .values({
        retailer_account_id: randomUUID(),
        customer_id: customerId,
        retailer_id: retailerId,
        is_connected: isConnected,
        access_token: isConnected ? `mock-${retailerId}-${randomUUID()}` : null,
        refresh_token: isConnected ? `refresh-${retailerId}-${randomUUID()}` : null,
        token_expires_at: isConnected ? new Date(now.getTime() + 12 * 60 * 60 * 1000) : null,
        created_at: now,
        updated_at: now
      })
      .onConflict((oc) =>
        oc.columns(['customer_id', 'retailer_id']).doUpdateSet({
          is_connected: isConnected,
          access_token: isConnected ? `mock-${retailerId}-${randomUUID()}` : null,
          refresh_token: isConnected ? `refresh-${retailerId}-${randomUUID()}` : null,
          token_expires_at: isConnected ? new Date(now.getTime() + 12 * 60 * 60 * 1000) : null,
          updated_at: now
        })
      )
      .execute();

    return {
      retailerId,
      isConnected,
      connectedAt: now.toISOString()
    };
  }

  async checkout(
    customerId: string,
    input: CustomerCheckoutInput
  ): Promise<CustomerCheckoutResult> {
    return this.db.transaction().execute(async (tx) => {
      const cart = await tx
        .selectFrom('carts')
        .select([
          'cart_id as cartId',
          'retailer_id as retailerId',
          'retailer_location_id as retailerLocationId',
          'status'
        ])
        .where('cart_id', '=', input.cartId)
        .where('customer_id', '=', customerId)
        .executeTakeFirst();

      if (!cart) {
        throw new HttpError(404, 'NOT_FOUND', 'Cart not found.');
      }

      if (!cart.retailerLocationId) {
        throw new HttpError(400, 'INVALID_REQUEST', 'Cart is missing a retailer location.');
      }

      const [address, location, connection, cartItems, retailer] = await Promise.all([
        tx
          .selectFrom('addresses')
          .select('address_id')
          .where('address_id', '=', input.addressId)
          .where('customer_id', '=', customerId)
          .executeTakeFirst(),
        tx
          .selectFrom('retailer_locations')
          .select([
            'retailer_location_id as retailerLocationId',
            'name',
            'retailer_id as retailerId'
          ])
          .where('retailer_location_id', '=', cart.retailerLocationId)
          .executeTakeFirst(),
        tx
          .selectFrom('retailer_accounts')
          .select('retailer_account_id')
          .where('customer_id', '=', customerId)
          .where('retailer_id', '=', cart.retailerId)
          .where('is_connected', '=', true)
          .executeTakeFirst(),
        tx
          .selectFrom('cart_items')
          .select([
            'cart_item_id as cartItemId',
            'product_id as productId',
            'external_sku as externalSku',
            'name_snapshot as nameSnapshot',
            'unit_price_cents as unitPriceCents',
            'quantity',
            'notes'
          ])
          .where('cart_id', '=', input.cartId)
          .execute(),
        tx
          .selectFrom('retailers')
          .select(['retailer_id as retailerId', 'name'])
          .where('retailer_id', '=', cart.retailerId)
          .executeTakeFirst()
      ]);

      if (!address) {
        throw new HttpError(404, 'NOT_FOUND', 'Address not found.');
      }

      if (!location) {
        throw new HttpError(404, 'NOT_FOUND', 'Retailer location not found.');
      }

      if (!connection) {
        throw new HttpError(
          400,
          'RETAILER_NOT_CONNECTED',
          'Connect the retailer before checking out.'
        );
      }

      if (cartItems.length === 0) {
        throw new HttpError(400, 'INVALID_REQUEST', 'Cart is empty.');
      }

      const subtotalCents = cartItems.reduce(
        (sum, item) => sum + toNumber(item.unitPriceCents) * toNumber(item.quantity),
        0
      );
      const serviceFeeCents = clamp(Math.round(subtotalCents * 0.06), 199, 1200);
      const deliveryFeeCents = 499;
      const estimatedTaxCents = Math.round(subtotalCents * 0.045);
      const tipCents = input.tipCents ?? 0;
      const totalCents =
        subtotalCents + serviceFeeCents + deliveryFeeCents + estimatedTaxCents + tipCents;
      const now = new Date();
      const orderId = randomUUID();
      const paymentId = randomUUID();
      const deliveryId = randomUUID();
      const externalOrderId = `ORD-${orderId.slice(0, 8).toUpperCase()}`;

      await tx
        .insertInto('orders')
        .values({
          order_id: orderId,
          customer_id: customerId,
          retailer_id: cart.retailerId,
          retailer_location_id: cart.retailerLocationId,
          address_id: input.addressId,
          external_order_id: externalOrderId,
          status: 'SUBMITTED',
          placed_at: now,
          subtotal_cents: subtotalCents,
          fees_cents: serviceFeeCents + deliveryFeeCents + estimatedTaxCents,
          tip_cents: tipCents,
          discount_cents: 0,
          total_cents: totalCents,
          currency: 'USD',
          delivery_notes: input.deliveryNotes ?? null,
          created_at: now,
          updated_at: now
        })
        .execute();

      await tx
        .insertInto('order_items')
        .values(
          cartItems.map((item) => ({
            order_item_id: randomUUID(),
            order_id: orderId,
            product_id: item.productId,
            external_sku: item.externalSku,
            name_snapshot: item.nameSnapshot,
            unit_price_cents: item.unitPriceCents,
            quantity: item.quantity,
            substituted_for_sku: null,
            created_at: now
          }))
        )
        .execute();

      await tx
        .insertInto('order_status_history')
        .values({
          order_status_history_id: randomUUID(),
          order_id: orderId,
          status: 'SUBMITTED',
          status_time: now,
          note: 'Checkout submitted from mobile app.'
        })
        .execute();

      await tx
        .insertInto('payments')
        .values({
          payment_id: paymentId,
          order_id: orderId,
          customer_id: customerId,
          provider: 'mock',
          provider_ref: `pay-${paymentId.slice(0, 8)}`,
          amount_cents: totalCents,
          currency: 'USD',
          status: 'AUTHORIZED',
          created_at: now
        })
        .execute();

      await tx
        .insertInto('delivery_assignments')
        .values({
          delivery_id: deliveryId,
          order_id: orderId,
          driver_id: null,
          status: 'PENDING_ASSIGNMENT',
          pickup_location: location.name ?? 'Partner pickup',
          assigned_at: null,
          picked_up_at: null,
          delivered_at: null
        })
        .execute();

      const onlineDrivers = await tx
        .selectFrom('drivers')
        .select('driver_id')
        .where('is_active', '=', true)
        .where('status', 'in', ['ONLINE', 'AVAILABLE'])
        .execute();

      if (onlineDrivers.length > 0) {
        await tx
          .insertInto('delivery_offers')
          .values(
            onlineDrivers.map((driver) => ({
              offer_id: randomUUID(),
              order_id: orderId,
              delivery_id: deliveryId,
              driver_id: driver.driver_id,
              status: 'OFFERED',
              offered_at: now,
              responded_at: null,
              expires_in_sec: 300,
              decline_reason: null
            }))
          )
          .execute();
      }

      await tx.deleteFrom('cart_items').where('cart_id', '=', input.cartId).execute();
      await tx
        .updateTable('carts')
        .set({
          status: 'CHECKED_OUT',
          updated_at: now
        })
        .where('cart_id', '=', input.cartId)
        .execute();

      return {
        order: {
          orderId,
          externalOrderId,
          retailerId: cart.retailerId,
          retailerName: retailer?.name ?? 'Retailer',
          retailerLocationId: cart.retailerLocationId,
          retailerLocationName: location.name,
          status: 'SUBMITTED',
          placedAt: now.toISOString(),
          totalCents,
          currency: 'USD',
          itemCount: cartItems.length
        },
        pricing: {
          subtotalCents,
          serviceFeeCents,
          deliveryFeeCents,
          estimatedTaxCents,
          tipCents,
          totalCents,
          currency: 'USD'
        },
        payment: {
          paymentId,
          status: 'AUTHORIZED',
          amountCents: totalCents,
          currency: 'USD'
        },
        delivery: {
          deliveryId,
          status: 'PENDING_ASSIGNMENT',
          pickupLocation: location.name ?? 'Partner pickup'
        }
      };
    });
  }

  async getDriverBootstrap(driverId: string): Promise<DriverBootstrapResult> {
    const driver = await this.db
      .selectFrom('drivers')
      .select(['driver_id as id', 'email', 'full_name as fullName', 'status'])
      .where('driver_id', '=', driverId)
      .executeTakeFirst();

    if (!driver) {
      throw new HttpError(404, 'NOT_FOUND', 'Driver not found.');
    }

    const [availableJobs, activeJobs, completedJobs, supportTickets, earningsSummary] =
      await Promise.all([
        this.listAvailableDriverJobs(driverId),
        this.listDriverAssignmentJobs(driverId, ['ASSIGNED', 'OUT_FOR_DELIVERY', 'IN_TRANSIT']),
        this.listDriverAssignmentJobs(driverId, ['DELIVERED']),
        this.listDriverSupportTickets(driverId),
        this.getDriverEarningsSummary(driverId)
      ]);

    return {
      driver,
      availableJobs,
      activeJobs,
      completedJobs,
      supportTickets,
      earningsSummary
    };
  }

  async acceptDelivery(driverId: string, deliveryId: string): Promise<DriverJobSummary> {
    return this.db.transaction().execute(async (tx) => {
      const offer = await tx
        .selectFrom('delivery_offers')
        .select(['offer_id as offerId', 'status'])
        .where('delivery_id', '=', deliveryId)
        .where('driver_id', '=', driverId)
        .executeTakeFirst();

      if (!offer) {
        throw new HttpError(404, 'NOT_FOUND', 'Delivery offer not found.');
      }

      if ((offer.status ?? '').toUpperCase() !== 'OFFERED') {
        throw new HttpError(409, 'CONFLICT', 'Delivery offer is no longer available.');
      }

      const now = new Date();

      await tx
        .updateTable('delivery_offers')
        .set({
          status: 'ACCEPTED',
          responded_at: now
        })
        .where('offer_id', '=', offer.offerId)
        .execute();

      await tx
        .updateTable('delivery_offers')
        .set({
          status: 'EXPIRED',
          responded_at: now
        })
        .where('delivery_id', '=', deliveryId)
        .where('offer_id', '!=', offer.offerId)
        .where('status', '=', 'OFFERED')
        .execute();

      await tx
        .updateTable('delivery_assignments')
        .set({
          driver_id: driverId,
          status: 'ASSIGNED',
          assigned_at: now
        })
        .where('delivery_id', '=', deliveryId)
        .execute();

      await this.insertDriverStatusChange(
        tx,
        deliveryId,
        driverId,
        'ASSIGNED',
        'Driver accepted offer.'
      );

      return this.getDriverAssignmentJob(tx, driverId, deliveryId);
    });
  }

  async pickupDelivery(driverId: string, deliveryId: string): Promise<DriverJobSummary> {
    return this.db.transaction().execute(async (tx) => {
      const assignment = await tx
        .selectFrom('delivery_assignments')
        .innerJoin('orders', 'orders.order_id', 'delivery_assignments.order_id')
        .select([
          'delivery_assignments.order_id as orderId',
          'delivery_assignments.status as status'
        ])
        .where('delivery_assignments.delivery_id', '=', deliveryId)
        .where('delivery_assignments.driver_id', '=', driverId)
        .executeTakeFirst();

      if (!assignment) {
        throw new HttpError(404, 'NOT_FOUND', 'Assigned delivery not found.');
      }

      const normalized = (assignment.status ?? '').toUpperCase();
      if (normalized !== 'ASSIGNED' && normalized !== 'READY_FOR_PICKUP') {
        throw new HttpError(409, 'CONFLICT', 'Delivery is not ready for pickup.');
      }

      const now = new Date();

      await tx
        .updateTable('delivery_assignments')
        .set({
          status: 'OUT_FOR_DELIVERY',
          picked_up_at: now
        })
        .where('delivery_id', '=', deliveryId)
        .execute();

      await this.insertDriverStatusChange(
        tx,
        deliveryId,
        driverId,
        'OUT_FOR_DELIVERY',
        'Driver confirmed pickup.'
      );

      return this.getDriverAssignmentJob(tx, driverId, deliveryId);
    });
  }

  async completeDelivery(driverId: string, deliveryId: string): Promise<DriverJobSummary> {
    return this.db.transaction().execute(async (tx) => {
      const assignment = await tx
        .selectFrom('delivery_assignments as da')
        .innerJoin('orders as o', 'o.order_id', 'da.order_id')
        .select([
          'da.order_id as orderId',
          'da.status',
          'o.tip_cents as tipCents',
          'o.total_cents as totalCents',
          'o.currency'
        ])
        .where('da.delivery_id', '=', deliveryId)
        .where('da.driver_id', '=', driverId)
        .executeTakeFirst();

      if (!assignment) {
        throw new HttpError(404, 'NOT_FOUND', 'Assigned delivery not found.');
      }

      if ((assignment.status ?? '').toUpperCase() !== 'OUT_FOR_DELIVERY') {
        throw new HttpError(409, 'CONFLICT', 'Delivery is not ready to complete.');
      }

      const now = new Date();
      const tipCents = toNumber(assignment.tipCents);
      const basePayCents = estimateBasePay(toNumber(assignment.totalCents));

      await tx
        .updateTable('delivery_assignments')
        .set({
          status: 'DELIVERED',
          delivered_at: now
        })
        .where('delivery_id', '=', deliveryId)
        .execute();

      await this.insertDriverStatusChange(
        tx,
        deliveryId,
        driverId,
        'DELIVERED',
        'Driver completed delivery.'
      );

      const existingEarning = await tx
        .selectFrom('driver_earnings')
        .select('earning_id')
        .where('delivery_id', '=', deliveryId)
        .where('driver_id', '=', driverId)
        .executeTakeFirst();

      if (!existingEarning) {
        await tx
          .insertInto('driver_earnings')
          .values({
            earning_id: randomUUID(),
            driver_id: driverId,
            delivery_id: deliveryId,
            base_pay_cents: basePayCents,
            bonus_cents: 0,
            tip_cents: tipCents,
            adjustments_cents: 0,
            total_pay_cents: basePayCents + tipCents,
            currency: assignment.currency ?? 'USD',
            status: 'PENDING',
            created_at: now
          })
          .execute();
      }

      return this.getDriverAssignmentJob(tx, driverId, deliveryId);
    });
  }

  private async insertDriverStatusChange(
    tx: DbExecutor,
    deliveryId: string,
    driverId: string,
    status: string,
    note: string
  ): Promise<void> {
    const assignment = await tx
      .selectFrom('delivery_assignments')
      .select('order_id')
      .where('delivery_id', '=', deliveryId)
      .executeTakeFirstOrThrow();
    const now = new Date();

    await tx
      .insertInto('delivery_status_events')
      .values({
        event_id: randomUUID(),
        delivery_id: deliveryId,
        driver_id: driverId,
        status,
        event_time: now,
        note,
        lat: null,
        lng: null
      })
      .execute();

    await tx
      .updateTable('orders')
      .set({
        status,
        updated_at: now
      })
      .where('order_id', '=', assignment.order_id)
      .execute();

    await tx
      .insertInto('order_status_history')
      .values({
        order_status_history_id: randomUUID(),
        order_id: assignment.order_id,
        status,
        status_time: now,
        note
      })
      .execute();
  }

  private async listDriverSupportTickets(driverId: string): Promise<DriverSupportTicketSummary[]> {
    const rows = await this.db
      .selectFrom('driver_support_tickets')
      .select([
        'ticket_id as ticketId',
        'delivery_id as deliveryId',
        'issue_type as issueType',
        'status',
        'message'
      ])
      .where('driver_id', '=', driverId)
      .orderBy('updated_at desc')
      .limit(20)
      .execute();

    return rows.map((row) => ({
      ticketId: row.ticketId,
      deliveryId: row.deliveryId,
      title: humanize(row.issueType, 'Support ticket'),
      status: row.status,
      summary: row.message ?? 'No details provided.'
    }));
  }

  private async getDriverEarningsSummary(driverId: string): Promise<DriverEarningsSummary> {
    const todayRows = await this.db
      .selectFrom('driver_earnings')
      .select([
        sql<number>`coalesce(sum(total_pay_cents), 0)`.as('todayGrossCents'),
        sql<number>`coalesce(sum(tip_cents), 0)`.as('tipsCents'),
        sql<number>`coalesce(sum(bonus_cents), 0)`.as('bonusCents')
      ])
      .where('driver_id', '=', driverId)
      .where(sql<boolean>`date(created_at) = current_date`)
      .executeTakeFirstOrThrow();

    const latestPayout = await this.db
      .selectFrom('driver_payouts')
      .select(['status', 'created_at as createdAt'])
      .where('driver_id', '=', driverId)
      .orderBy('created_at desc')
      .executeTakeFirst();

    return {
      todayGrossCents: toNumber(todayRows.todayGrossCents),
      tipsCents: toNumber(todayRows.tipsCents),
      bonusCents: toNumber(todayRows.bonusCents),
      nextPayoutLabel: latestPayout?.status
        ? `${humanize(latestPayout.status, 'Pending')} payout`
        : 'Tomorrow 9:00 AM'
    };
  }

  private async listAvailableDriverJobs(driverId: string): Promise<DriverJobSummary[]> {
    const rows = await this.db
      .selectFrom('delivery_offers as offer')
      .innerJoin('delivery_assignments as da', 'da.delivery_id', 'offer.delivery_id')
      .innerJoin('orders as o', 'o.order_id', 'da.order_id')
      .innerJoin('retailers as r', 'r.retailer_id', 'o.retailer_id')
      .innerJoin('addresses as a', 'a.address_id', 'o.address_id')
      .leftJoin('retailer_locations as rl', 'rl.retailer_location_id', 'o.retailer_location_id')
      .leftJoin('driver_earnings as de', (join) =>
        join.onRef('de.delivery_id', '=', 'da.delivery_id').on('de.driver_id', '=', driverId)
      )
      .select([
        'da.delivery_id as deliveryId',
        'da.order_id as orderId',
        sql<string>`coalesce(rl.name, da.pickup_location, r.name || ' delivery')`.as('title'),
        'rl.retailer_location_id as pickupLocationId',
        sql<string>`coalesce(rl.name, da.pickup_location, r.name)`.as('pickupName'),
        sql<string>`coalesce(
          nullif(concat_ws(', ', rl.address_line1, rl.address_line2, rl.city, rl.state, rl.postal_code), ''),
          da.pickup_location,
          r.name
        )`.as('pickupAddressLine'),
        'rl.lat as pickupLat',
        'rl.lng as pickupLng',
        sql<string>`coalesce(a.label, 'Customer delivery')`.as('dropoffName'),
        sql<string>`coalesce(
          nullif(concat_ws(', ', a.line1, a.line2, a.city, a.state, a.postal_code), ''),
          'Delivery address unavailable'
        )`.as('dropoffAddressLine'),
        sql<string>`coalesce(a.city, 'Service area')`.as('zone'),
        'o.total_cents as totalCents',
        'o.tip_cents as tipCents',
        'de.base_pay_cents as earningBasePayCents',
        'de.tip_cents as earningTipCents',
        'de.total_pay_cents as earningTotalPayCents',
        sql<number>`(
          select count(*)::int
          from order_items oi
          where oi.order_id = o.order_id
        )`.as('itemCount'),
        'da.status as assignmentStatus',
        'o.delivery_notes as deliveryNotes'
      ])
      .where('offer.driver_id', '=', driverId)
      .where('offer.status', '=', 'OFFERED')
      .orderBy('offer.offered_at desc')
      .execute();

    return rows.map((row) =>
      buildDriverJobSummary({
        ...row,
        stage: 'available'
      })
    );
  }

  private async listDriverAssignmentJobs(
    driverId: string,
    statuses: string[]
  ): Promise<DriverJobSummary[]> {
    const rows = await this.db
      .selectFrom('delivery_assignments as da')
      .innerJoin('orders as o', 'o.order_id', 'da.order_id')
      .innerJoin('retailers as r', 'r.retailer_id', 'o.retailer_id')
      .innerJoin('addresses as a', 'a.address_id', 'o.address_id')
      .leftJoin('retailer_locations as rl', 'rl.retailer_location_id', 'o.retailer_location_id')
      .leftJoin('driver_earnings as de', (join) =>
        join.onRef('de.delivery_id', '=', 'da.delivery_id').on('de.driver_id', '=', driverId)
      )
      .select([
        'da.delivery_id as deliveryId',
        'da.order_id as orderId',
        sql<string>`coalesce(rl.name, da.pickup_location, r.name || ' delivery')`.as('title'),
        'rl.retailer_location_id as pickupLocationId',
        sql<string>`coalesce(rl.name, da.pickup_location, r.name)`.as('pickupName'),
        sql<string>`coalesce(
          nullif(concat_ws(', ', rl.address_line1, rl.address_line2, rl.city, rl.state, rl.postal_code), ''),
          da.pickup_location,
          r.name
        )`.as('pickupAddressLine'),
        'rl.lat as pickupLat',
        'rl.lng as pickupLng',
        sql<string>`coalesce(a.label, 'Customer delivery')`.as('dropoffName'),
        sql<string>`coalesce(
          nullif(concat_ws(', ', a.line1, a.line2, a.city, a.state, a.postal_code), ''),
          'Delivery address unavailable'
        )`.as('dropoffAddressLine'),
        sql<string>`coalesce(a.city, 'Service area')`.as('zone'),
        'o.total_cents as totalCents',
        'o.tip_cents as tipCents',
        'de.base_pay_cents as earningBasePayCents',
        'de.tip_cents as earningTipCents',
        'de.total_pay_cents as earningTotalPayCents',
        sql<number>`(
          select count(*)::int
          from order_items oi
          where oi.order_id = o.order_id
        )`.as('itemCount'),
        'da.status as assignmentStatus',
        'o.delivery_notes as deliveryNotes'
      ])
      .where('da.driver_id', '=', driverId)
      .where('da.status', 'in', statuses)
      .orderBy('da.assigned_at desc')
      .orderBy('da.delivered_at desc')
      .execute();

    return rows.map((row) =>
      buildDriverJobSummary({
        ...row,
        stage: stageFromAssignment(row.assignmentStatus)
      })
    );
  }

  private async getDriverAssignmentJob(
    tx: DbExecutor,
    driverId: string,
    deliveryId: string
  ): Promise<DriverJobSummary> {
    const rows = await tx
      .selectFrom('delivery_assignments as da')
      .innerJoin('orders as o', 'o.order_id', 'da.order_id')
      .innerJoin('retailers as r', 'r.retailer_id', 'o.retailer_id')
      .innerJoin('addresses as a', 'a.address_id', 'o.address_id')
      .leftJoin('retailer_locations as rl', 'rl.retailer_location_id', 'o.retailer_location_id')
      .leftJoin('driver_earnings as de', (join) =>
        join.onRef('de.delivery_id', '=', 'da.delivery_id').on('de.driver_id', '=', driverId)
      )
      .select([
        'da.delivery_id as deliveryId',
        'da.order_id as orderId',
        sql<string>`coalesce(rl.name, da.pickup_location, r.name || ' delivery')`.as('title'),
        'rl.retailer_location_id as pickupLocationId',
        sql<string>`coalesce(rl.name, da.pickup_location, r.name)`.as('pickupName'),
        sql<string>`coalesce(
          nullif(concat_ws(', ', rl.address_line1, rl.address_line2, rl.city, rl.state, rl.postal_code), ''),
          da.pickup_location,
          r.name
        )`.as('pickupAddressLine'),
        'rl.lat as pickupLat',
        'rl.lng as pickupLng',
        sql<string>`coalesce(a.label, 'Customer delivery')`.as('dropoffName'),
        sql<string>`coalesce(
          nullif(concat_ws(', ', a.line1, a.line2, a.city, a.state, a.postal_code), ''),
          'Delivery address unavailable'
        )`.as('dropoffAddressLine'),
        sql<string>`coalesce(a.city, 'Service area')`.as('zone'),
        'o.total_cents as totalCents',
        'o.tip_cents as tipCents',
        'de.base_pay_cents as earningBasePayCents',
        'de.tip_cents as earningTipCents',
        'de.total_pay_cents as earningTotalPayCents',
        sql<number>`(
          select count(*)::int
          from order_items oi
          where oi.order_id = o.order_id
        )`.as('itemCount'),
        'da.status as assignmentStatus',
        'o.delivery_notes as deliveryNotes'
      ])
      .where('da.delivery_id', '=', deliveryId)
      .where('da.driver_id', '=', driverId)
      .limit(1)
      .execute();

    const row = rows[0];
    if (!row) {
      throw new HttpError(404, 'NOT_FOUND', 'Driver delivery not found.');
    }

    return buildDriverJobSummary({
      ...row,
      stage: stageFromAssignment(row.assignmentStatus)
    });
  }
}
