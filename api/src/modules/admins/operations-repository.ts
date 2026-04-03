import { randomUUID } from 'node:crypto';

import type { Kysely } from 'kysely';

import type { AuthPrincipal } from '../../app/types.js';
import type { Database } from '../../platform/db/types.js';
import type {
  AdminOperationsRepository,
  DashboardResult,
  IssueRefundInput,
  IssueRefundResult,
  UpdateOrderStatusInput,
  UpdateOrderStatusResult
} from './operations-types.js';

async function countValue(query: Promise<{ count: string | number | bigint | null } | undefined>) {
  const row = await query;
  return Number(row?.count ?? 0);
}

export class KyselyAdminOperationsRepository implements AdminOperationsRepository {
  constructor(private readonly db: Kysely<Database>) {}

  async getDashboard(): Promise<DashboardResult> {
    const [
      totalOrders,
      activeDrivers,
      readyForPickupOrders,
      integrationIssues,
      recentOrders,
      integrationHealth
    ] = await Promise.all([
      countValue(
        this.db
          .selectFrom('orders')
          .select((eb) => eb.fn.count('order_id').as('count'))
          .executeTakeFirst()
      ),
      countValue(
        this.db
          .selectFrom('drivers')
          .select((eb) => eb.fn.count('driver_id').as('count'))
          .where('is_active', '=', true)
          .where('status', '!=', 'OFFLINE')
          .executeTakeFirst()
      ),
      countValue(
        this.db
          .selectFrom('orders')
          .select((eb) => eb.fn.count('order_id').as('count'))
          .where('status', '=', 'READY_FOR_PICKUP')
          .executeTakeFirst()
      ),
      countValue(
        this.db
          .selectFrom('integration_health')
          .select((eb) => eb.fn.count('health_id').as('count'))
          .where('status', 'is not', null)
          .where('status', 'not in', ['HEALTHY', 'OK'])
          .executeTakeFirst()
      ),
      this.db
        .selectFrom('orders')
        .select([
          'order_id',
          'customer_id',
          'retailer_id',
          'status',
          'total_cents',
          'currency',
          'placed_at',
          'updated_at'
        ])
        .orderBy('updated_at', 'desc')
        .limit(5)
        .execute(),
      this.db
        .selectFrom('integration_health')
        .selectAll()
        .orderBy('last_checked_at', 'desc')
        .limit(6)
        .execute()
    ]);

    return {
      metrics: {
        totalOrders,
        activeDrivers,
        readyForPickupOrders,
        integrationIssues
      },
      recentOrders,
      integrationHealth
    };
  }

  async findOrderById(orderId: string): Promise<Record<string, unknown> | null> {
    const order = await this.db
      .selectFrom('orders')
      .selectAll()
      .where('order_id', '=', orderId)
      .executeTakeFirst();

    return order ?? null;
  }

  async updateOrderStatus(
    _principal: AuthPrincipal,
    orderId: string,
    input: UpdateOrderStatusInput
  ): Promise<UpdateOrderStatusResult> {
    return this.db.transaction().execute(async (trx) => {
      const now = new Date();
      const order = await trx
        .updateTable('orders')
        .set({
          status: input.status,
          updated_at: now
        })
        .where('order_id', '=', orderId)
        .returningAll()
        .executeTakeFirst();

      if (!order) {
        throw new Error('ORDER_NOT_FOUND');
      }

      const historyEntry = await trx
        .insertInto('order_status_history')
        .values({
          order_status_history_id: randomUUID(),
          order_id: orderId,
          status: input.status,
          status_time: now,
          note: input.note?.trim() || null
        })
        .returningAll()
        .executeTakeFirstOrThrow();

      return {
        order,
        historyEntry
      };
    });
  }

  async findLatestPaymentForOrder(orderId: string): Promise<Record<string, unknown> | null> {
    const payment = await this.db
      .selectFrom('payments')
      .selectAll()
      .where('order_id', '=', orderId)
      .orderBy('created_at', 'desc')
      .limit(1)
      .executeTakeFirst();

    return payment ?? null;
  }

  async getRefundedAmount(paymentId: string): Promise<number> {
    const refunds = await this.db
      .selectFrom('refunds')
      .select('amount_cents')
      .where('payment_id', '=', paymentId)
      .execute();

    return refunds.reduce((total, refund) => total + Number(refund.amount_cents ?? 0), 0);
  }

  async createRefund(
    _principal: AuthPrincipal,
    orderId: string,
    paymentId: string,
    input: IssueRefundInput
  ): Promise<IssueRefundResult> {
    const refund = await this.db
      .insertInto('refunds')
      .values({
        refund_id: randomUUID(),
        payment_id: paymentId,
        order_id: orderId,
        amount_cents: input.amountCents,
        reason: input.reason.trim(),
        status: 'COMPLETED',
        created_at: new Date()
      })
      .returningAll()
      .executeTakeFirstOrThrow();

    return {
      refund
    };
  }
}
