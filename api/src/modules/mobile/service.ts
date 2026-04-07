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

// Mobile endpoints are role-partitioned even though they live under the same
// router tree. Centralizing the check here keeps route handlers thin and gives
// repository methods a trusted caller contract.
function requireRole(principal: AuthPrincipal, role: AuthPrincipal['role']): void {
  if (principal.role !== role) {
    throw new HttpError(403, 'FORBIDDEN', 'You do not have access to this resource.');
  }
}

/**
 * Thin application-service layer for the mobile API surface.
 *
 * The service mostly enforces authorization boundaries and forwards to the
 * repository, but keeping that boundary explicit makes it easy to add richer
 * orchestration later without pushing auth logic into route handlers or SQL.
 */
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
