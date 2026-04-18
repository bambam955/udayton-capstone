import type { AuthPrincipal } from '../../app/types.js';

// These contracts deliberately model the mobile apps' aggregated read models
// rather than the raw relational schema. The repository shapes SQL rows into
// these view-oriented payloads so Flutter screens can stay focused on display
// logic instead of backend table details.
export interface CustomerBootstrapResult {
  customer: {
    id: string;
    email: string | null;
    fullName: string | null;
  };
  retailers: CustomerRetailerSummary[];
  addresses: CustomerAddressSummary[];
  carts: CustomerCartSummary[];
  orders: CustomerOrderSummary[];
  supportTickets: CustomerSupportTicketSummary[];
  defaultAddressId: string | null;
}

export interface CustomerRetailerSummary {
  retailerId: string;
  name: string;
  website: string | null;
  isEnabled: boolean;
  isConnected: boolean;
  locations: RetailerLocationSummary[];
}

export interface RetailerLocationSummary {
  retailerLocationId: string;
  retailerId: string;
  externalStoreId: string | null;
  name: string;
  addressLine: string;
  city: string | null;
  state: string | null;
  postalCode: string | null;
  country: string | null;
  lat: number | null;
  lng: number | null;
  isActive: boolean;
}

export interface CustomerAddressSummary {
  addressId: string;
  label: string | null;
  line1: string | null;
  line2: string | null;
  city: string | null;
  state: string | null;
  postalCode: string | null;
  country: string | null;
  instructions: string | null;
  isDefault: boolean;
  addressLine: string;
}

export interface CustomerCartSummary {
  cartId: string;
  retailerId: string;
  retailerLocationId: string | null;
  status: string | null;
  itemCount: number;
  subtotalCents: number;
}

export interface CustomerOrderSummary {
  orderId: string;
  externalOrderId: string | null;
  retailerId: string;
  retailerName: string;
  retailerLocationId: string | null;
  retailerLocationName: string | null;
  status: string | null;
  placedAt: string | null;
  totalCents: number;
  currency: string | null;
  itemCount: number;
}

export interface CustomerSupportTicketSummary {
  ticketId: string;
  orderId: string | null;
  title: string;
  status: string | null;
  summary: string;
}

export interface CustomerCatalogInput {
  retailerLocationId: string;
  category?: string;
  query?: string;
}

export interface CustomerCatalogResult {
  location: RetailerLocationSummary;
  retailer: {
    retailerId: string;
    name: string;
  };
  categories: CustomerCatalogCategory[];
  products: CustomerCatalogProduct[];
  cart: CustomerCartSummary | null;
}

export interface CustomerCatalogCategory {
  categoryId: string;
  name: string;
}

export interface CustomerCatalogProduct {
  productId: string;
  retailerId: string;
  categoryId: string;
  categoryName: string;
  externalSku: string | null;
  name: string;
  description: string | null;
  imageUrl: string | null;
  unitPriceCents: number;
  currency: string;
  isAvailable: boolean;
}

export interface CustomerCheckoutInput {
  cartId: string;
  addressId: string;
  deliveryNotes?: string;
  tipCents?: number;
}

export interface CustomerRetailerConnectionResult {
  retailerId: string;
  isConnected: boolean;
  connectedAt: string;
}

export interface CustomerCheckoutResult {
  order: CustomerOrderSummary;
  pricing: {
    subtotalCents: number;
    serviceFeeCents: number;
    deliveryFeeCents: number;
    estimatedTaxCents: number;
    tipCents: number;
    totalCents: number;
    currency: string;
  };
  payment: {
    paymentId: string;
    status: string;
    amountCents: number;
    currency: string;
  };
  delivery: {
    deliveryId: string;
    status: string;
    pickupLocation: string;
  };
}

export interface DriverBootstrapResult {
  driver: {
    id: string;
    email: string | null;
    fullName: string | null;
    status: string | null;
  };
  availableJobs: DriverJobSummary[];
  activeJobs: DriverJobSummary[];
  completedJobs: DriverJobSummary[];
  supportTickets: DriverSupportTicketSummary[];
  earningsSummary: DriverEarningsSummary;
}

export interface DriverJobSummary {
  deliveryId: string;
  orderId: string;
  title: string;
  pickupLocationId: string | null;
  pickupName: string;
  pickupAddressLine: string;
  pickupLat: number | null;
  pickupLng: number | null;
  dropoffName: string;
  dropoffAddressLine: string;
  zone: string;
  payoutEstimateCents: number;
  distanceMiles: number;
  etaMinutes: number;
  stage: 'available' | 'assigned' | 'out_for_delivery' | 'delivered';
  detailLines: string[];
  basePayCents: number;
  tipCents: number;
}

export interface DriverSupportTicketSummary {
  ticketId: string;
  deliveryId: string | null;
  title: string;
  status: string | null;
  summary: string;
}

export interface DriverEarningsSummary {
  todayGrossCents: number;
  tipsCents: number;
  bonusCents: number;
  nextPayoutLabel: string;
}

export interface MobileRepository {
  // Customer-facing aggregated reads and mutations.
  getCustomerBootstrap(customerId: string): Promise<CustomerBootstrapResult>;
  getCustomerCatalog(
    customerId: string,
    input: CustomerCatalogInput
  ): Promise<CustomerCatalogResult>;
  setRetailerConnection(
    customerId: string,
    retailerId: string,
    isConnected: boolean
  ): Promise<CustomerRetailerConnectionResult>;
  cancelOrder(customerId: string, orderId: string): Promise<CustomerOrderSummary>;
  checkout(customerId: string, input: CustomerCheckoutInput): Promise<CustomerCheckoutResult>;
  // Driver-facing aggregated reads and delivery lifecycle transitions.
  getDriverBootstrap(driverId: string): Promise<DriverBootstrapResult>;
  acceptDelivery(driverId: string, deliveryId: string): Promise<DriverJobSummary>;
  pickupDelivery(driverId: string, deliveryId: string): Promise<DriverJobSummary>;
  completeDelivery(driverId: string, deliveryId: string): Promise<DriverJobSummary>;
}

export interface MobileServiceContract {
  // Service methods receive the authenticated principal so role checks happen
  // before any repository work starts.
  getCustomerBootstrap(principal: AuthPrincipal): Promise<CustomerBootstrapResult>;
  getCustomerCatalog(
    principal: AuthPrincipal,
    input: CustomerCatalogInput
  ): Promise<CustomerCatalogResult>;
  connectRetailer(
    principal: AuthPrincipal,
    retailerId: string
  ): Promise<CustomerRetailerConnectionResult>;
  disconnectRetailer(
    principal: AuthPrincipal,
    retailerId: string
  ): Promise<CustomerRetailerConnectionResult>;
  cancelOrder(principal: AuthPrincipal, orderId: string): Promise<CustomerOrderSummary>;
  checkout(principal: AuthPrincipal, input: CustomerCheckoutInput): Promise<CustomerCheckoutResult>;
  getDriverBootstrap(principal: AuthPrincipal): Promise<DriverBootstrapResult>;
  acceptDelivery(principal: AuthPrincipal, deliveryId: string): Promise<DriverJobSummary>;
  pickupDelivery(principal: AuthPrincipal, deliveryId: string): Promise<DriverJobSummary>;
  completeDelivery(principal: AuthPrincipal, deliveryId: string): Promise<DriverJobSummary>;
}
