import type { Kysely } from 'kysely';

import type { Database } from '../../platform/db/types.js';
import type { OrderListItem } from './types.js';

export interface OrdersRepository {
  listByCustomer(customerId: string, limit: number): Promise<OrderListItem[]>;
  listRecent(limit: number): Promise<OrderListItem[]>;
}

export class KyselyOrdersRepository implements OrdersRepository {
  constructor(private readonly db: Kysely<Database>) {}

  async listByCustomer(customerId: string, limit: number): Promise<OrderListItem[]> {
    // Read model keeps response compact for mobile order history screens.
    const rows = await this.db
      .selectFrom('orders')
      .select([
        'order_id',
        'customer_id',
        'retailer_id',
        'status',
        'total_cents',
        'currency',
        'placed_at'
      ])
      .where('customer_id', '=', customerId)
      .orderBy('created_at', 'desc')
      .limit(limit)
      .execute();

    return rows.map(mapOrderListItem);
  }

  async listRecent(limit: number): Promise<OrderListItem[]> {
    const rows = await this.db
      .selectFrom('orders')
      .select([
        'order_id',
        'customer_id',
        'retailer_id',
        'status',
        'total_cents',
        'currency',
        'placed_at'
      ])
      .orderBy('created_at', 'desc')
      .limit(limit)
      .execute();

    return rows.map(mapOrderListItem);
  }
}

function mapOrderListItem(row: {
  order_id: string;
  customer_id: string;
  retailer_id: string;
  status: string | null;
  total_cents: number | null;
  currency: string | null;
  placed_at: Date | string | null;
}): OrderListItem {
  return {
    orderId: row.order_id,
    customerId: row.customer_id,
    retailerId: row.retailer_id,
    // Defaults guard older/partial records from breaking the API contract.
    status: row.status ?? 'UNKNOWN',
    totalCents: row.total_cents ?? 0,
    currency: row.currency ?? 'USD',
    placedAt: row.placed_at ? new Date(row.placed_at) : null
  };
}
