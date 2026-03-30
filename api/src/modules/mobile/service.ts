import { HttpError } from '../../app/errors.js';
import type { AuthPrincipal } from '../../app/types.js';
import type {
  CustomerCatalogInput,
  CustomerCatalogResult,
  CustomerCheckoutInput,
  CustomerCheckoutResult,
  CustomerRetailerConnectionResult,
  DriverBootstrapResult,
  DriverJobSummary,
  MobileRepository,
  MobileServiceContract,
  CustomerBootstrapResult
} from './types.js';

function requireRole(principal: AuthPrincipal, role: AuthPrincipal['role']): void {
  if (principal.role !== role) {
    throw new HttpError(403, 'FORBIDDEN', 'You do not have access to this resource.');
  }
}

export class MobileService implements MobileServiceContract {
  constructor(private readonly repository: MobileRepository) {}

  async getCustomerBootstrap(principal: AuthPrincipal): Promise<CustomerBootstrapResult> {
    requireRole(principal, 'customer');
    return this.repository.getCustomerBootstrap(principal.userId);
  }

  async getCustomerCatalog(
    principal: AuthPrincipal,
    input: CustomerCatalogInput
  ): Promise<CustomerCatalogResult> {
    requireRole(principal, 'customer');
    return this.repository.getCustomerCatalog(principal.userId, input);
  }

  async connectRetailer(
    principal: AuthPrincipal,
    retailerId: string
  ): Promise<CustomerRetailerConnectionResult> {
    requireRole(principal, 'customer');
    return this.repository.setRetailerConnection(principal.userId, retailerId, true);
  }

  async disconnectRetailer(
    principal: AuthPrincipal,
    retailerId: string
  ): Promise<CustomerRetailerConnectionResult> {
    requireRole(principal, 'customer');
    return this.repository.setRetailerConnection(principal.userId, retailerId, false);
  }

  async checkout(
    principal: AuthPrincipal,
    input: CustomerCheckoutInput
  ): Promise<CustomerCheckoutResult> {
    requireRole(principal, 'customer');
    return this.repository.checkout(principal.userId, input);
  }

  async getDriverBootstrap(principal: AuthPrincipal): Promise<DriverBootstrapResult> {
    requireRole(principal, 'driver');
    return this.repository.getDriverBootstrap(principal.userId);
  }

  async acceptDelivery(principal: AuthPrincipal, deliveryId: string): Promise<DriverJobSummary> {
    requireRole(principal, 'driver');
    return this.repository.acceptDelivery(principal.userId, deliveryId);
  }

  async pickupDelivery(principal: AuthPrincipal, deliveryId: string): Promise<DriverJobSummary> {
    requireRole(principal, 'driver');
    return this.repository.pickupDelivery(principal.userId, deliveryId);
  }

  async completeDelivery(principal: AuthPrincipal, deliveryId: string): Promise<DriverJobSummary> {
    requireRole(principal, 'driver');
    return this.repository.completeDelivery(principal.userId, deliveryId);
  }
}
