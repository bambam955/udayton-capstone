import { HttpError } from '../../app/errors.js';
import type { AuthPrincipal } from '../../app/types.js';
import type { OrdersRepository } from './repository.js';
import type { OrderListItem } from './types.js';

export class OrdersService {
  constructor(private readonly repo: OrdersRepository) {}

  async listMyOrders(principal: AuthPrincipal, limit: number): Promise<OrderListItem[]> {
    // This endpoint is currently customer-only by product design.
    if (principal.role !== 'customer') {
      throw new HttpError(403, 'FORBIDDEN', 'Only customer accounts can list customer orders.');
    }

    // Enforce a bounded query window to protect DB and API latency.
    const normalizedLimit = Math.min(Math.max(limit, 1), 100);
    return this.repo.listByCustomer(principal.userId, normalizedLimit);
  }
}
