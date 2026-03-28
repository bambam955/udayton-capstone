import { HttpError } from '../../app/errors.js';
import type { AuthPrincipal } from '../../app/types.js';
import type { OrdersRepository } from './repository.js';
import type { ListOrdersInput, OrderListItem } from './types.js';

export class OrdersService {
  constructor(private readonly repo: OrdersRepository) {}

  async listOrders(principal: AuthPrincipal, input: ListOrdersInput): Promise<OrderListItem[]> {
    // Enforce a bounded query window to protect DB and API latency.
    const normalizedLimit = Math.min(Math.max(input.limit, 1), 100);

    // Customers are not allowed to see orders for other customers. They can only see their own orders.
    if (principal.role === 'customer') {
      if (input.customerId && input.customerId !== principal.userId) {
        throw new HttpError(403, 'FORBIDDEN', 'Customers can only access their own orders.');
      }

      return this.repo.listByCustomer(principal.userId, normalizedLimit);
    }

    // Admins have two options: they can either see all recent orders with no customerId parameter,
    // or they can pass a customerId to see all the recent orders for that customer.
    if (principal.role === 'admin') {
      if (input.customerId) {
        return this.repo.listByCustomer(input.customerId, normalizedLimit);
      }

      return this.repo.listRecent(normalizedLimit);
    }

    // Drivers are not allowed to see orders at all.
    throw new HttpError(403, 'FORBIDDEN', 'Only customer and admin accounts can list orders.');
  }
}
