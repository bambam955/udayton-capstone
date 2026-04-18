import { HttpError } from '../../app/errors.js';
import type { AuthPrincipal } from '../../app/types.js';
import { orderStatuses } from '../orders/statuses.js';
import type {
  AdminOperationsRepository,
  DashboardResult,
  IssueRefundInput,
  IssueRefundResult,
  UpdateOrderStatusInput,
  UpdateOrderStatusResult
} from './operations-types.js';

export class AdminOperationsService {
  constructor(private readonly repository: AdminOperationsRepository) {}

  private requireAdmin(principal: AuthPrincipal) {
    if (principal.role !== 'admin') {
      throw new HttpError(403, 'FORBIDDEN', 'You do not have access to this resource.');
    }
  }

  async getDashboard(principal: AuthPrincipal): Promise<DashboardResult> {
    this.requireAdmin(principal);
    return this.repository.getDashboard();
  }

  async updateOrderStatus(
    principal: AuthPrincipal,
    orderId: string,
    input: UpdateOrderStatusInput
  ): Promise<UpdateOrderStatusResult> {
    this.requireAdmin(principal);

    if (!orderStatuses.includes(input.status)) {
      throw new HttpError(400, 'INVALID_REQUEST', 'Unsupported order status.');
    }

    const order = await this.repository.findOrderById(orderId);
    if (!order) {
      throw new HttpError(404, 'NOT_FOUND', 'Order not found.');
    }

    return this.repository.updateOrderStatus(principal, orderId, input);
  }

  async issueRefund(
    principal: AuthPrincipal,
    orderId: string,
    input: IssueRefundInput
  ): Promise<IssueRefundResult> {
    this.requireAdmin(principal);

    if (!Number.isInteger(input.amountCents) || input.amountCents <= 0) {
      throw new HttpError(400, 'INVALID_REQUEST', 'Refund amount must be a positive integer.');
    }

    if (input.reason.trim().length === 0) {
      throw new HttpError(400, 'INVALID_REQUEST', 'Refund reason is required.');
    }

    const order = await this.repository.findOrderById(orderId);
    if (!order) {
      throw new HttpError(404, 'NOT_FOUND', 'Order not found.');
    }

    const payment = await this.repository.findLatestPaymentForOrder(orderId);
    if (!payment || typeof payment.payment_id !== 'string') {
      throw new HttpError(404, 'NOT_FOUND', 'No payment record exists for that order.');
    }

    const paidAmount = Number(payment.amount_cents ?? 0);
    if (input.amountCents > paidAmount) {
      throw new HttpError(
        400,
        'INVALID_REQUEST',
        'Refund amount cannot exceed the captured payment amount.'
      );
    }

    const refundedAmount = await this.repository.getRefundedAmount(payment.payment_id);
    if (input.amountCents + refundedAmount > paidAmount) {
      throw new HttpError(
        400,
        'INVALID_REQUEST',
        'Refund amount exceeds the remaining refundable balance.'
      );
    }

    return this.repository.createRefund(principal, orderId, payment.payment_id, input);
  }
}
