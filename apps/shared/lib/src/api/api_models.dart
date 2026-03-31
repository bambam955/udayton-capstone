import 'api_json.dart';

enum ApiUserRole { customer, driver, admin }

ApiUserRole apiUserRoleFromWire(String value) {
  return switch (value) {
    'driver' => ApiUserRole.driver,
    'admin' => ApiUserRole.admin,
    _ => ApiUserRole.customer,
  };
}

String apiUserRoleToWire(ApiUserRole value) {
  return switch (value) {
    ApiUserRole.customer => 'customer',
    ApiUserRole.driver => 'driver',
    ApiUserRole.admin => 'admin',
  };
}

class AuthUser {
  const AuthUser({
    required this.id,
    required this.role,
    required this.email,
  });

  final String id;
  final ApiUserRole role;
  final String email;

  factory AuthUser.fromJson(Object? raw) {
    final json = asJsonMap(raw);
    return AuthUser(
      id: readString(json, 'id'),
      role: apiUserRoleFromWire(readString(json, 'role')),
      email: readString(json, 'email'),
    );
  }

  JsonMap toJson() {
    return {
      'id': id,
      'role': apiUserRoleToWire(role),
      'email': email,
    };
  }
}

class AuthResult {
  const AuthResult({
    required this.accessToken,
    required this.expiresAt,
    required this.user,
  });

  final String accessToken;
  final DateTime expiresAt;
  final AuthUser user;

  factory AuthResult.fromJson(Object? raw) {
    final json = asJsonMap(raw);
    return AuthResult(
      accessToken: readString(json, 'accessToken'),
      expiresAt: readDateTime(json, 'expiresAt') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      user: AuthUser.fromJson(json['user']),
    );
  }
}

class ApiSession {
  const ApiSession({
    required this.accessToken,
    required this.expiresAt,
    required this.user,
  });

  final String accessToken;
  final DateTime expiresAt;
  final AuthUser user;

  bool get isExpired => expiresAt.isBefore(DateTime.now().toUtc());

  factory ApiSession.fromAuthResult(AuthResult result) {
    return ApiSession(
      accessToken: result.accessToken,
      expiresAt: result.expiresAt.toUtc(),
      user: result.user,
    );
  }

  factory ApiSession.fromJson(Object? raw) {
    final json = asJsonMap(raw);
    return ApiSession(
      accessToken: readString(json, 'accessToken'),
      expiresAt: readDateTime(json, 'expiresAt') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      user: AuthUser.fromJson(json['user']),
    );
  }

  JsonMap toJson() {
    return {
      'accessToken': accessToken,
      'expiresAt': expiresAt.toUtc().toIso8601String(),
      'user': user.toJson(),
    };
  }
}

class ApiPrincipal {
  const ApiPrincipal({
    required this.userId,
    required this.role,
    required this.sessionId,
  });

  final String userId;
  final ApiUserRole role;
  final String sessionId;

  factory ApiPrincipal.fromJson(Object? raw) {
    final json = asJsonMap(raw);
    return ApiPrincipal(
      userId: readString(json, 'userId'),
      role: apiUserRoleFromWire(readString(json, 'role')),
      sessionId: readString(json, 'sessionId'),
    );
  }
}

class CustomerProfile {
  const CustomerProfile({
    required this.id,
    required this.email,
    required this.fullName,
  });

  final String id;
  final String? email;
  final String? fullName;

  factory CustomerProfile.fromJson(Object? raw) {
    final json = asJsonMap(raw);
    return CustomerProfile(
      id: readString(json, 'id'),
      email: readNullableString(json, 'email'),
      fullName: readNullableString(json, 'fullName'),
    );
  }
}

class DriverProfile {
  const DriverProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.status,
  });

  final String id;
  final String? email;
  final String? fullName;
  final String? status;

  factory DriverProfile.fromJson(Object? raw) {
    final json = asJsonMap(raw);
    return DriverProfile(
      id: readString(json, 'id'),
      email: readNullableString(json, 'email'),
      fullName: readNullableString(json, 'fullName'),
      status: readNullableString(json, 'status'),
    );
  }
}

class RetailerLocation {
  const RetailerLocation({
    required this.retailerLocationId,
    required this.retailerId,
    required this.name,
    required this.addressLine,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.lat,
    required this.lng,
    required this.isActive,
    this.externalStoreId,
  });

  final String retailerLocationId;
  final String retailerId;
  final String? externalStoreId;
  final String name;
  final String addressLine;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final double? lat;
  final double? lng;
  final bool isActive;

  factory RetailerLocation.fromJson(Object? raw) {
    final json = asJsonMap(raw);
    return RetailerLocation(
      retailerLocationId: readString(json, 'retailerLocationId'),
      retailerId: readString(json, 'retailerId'),
      externalStoreId: readNullableString(json, 'externalStoreId'),
      name: readString(json, 'name'),
      addressLine: readString(json, 'addressLine'),
      city: readNullableString(json, 'city'),
      state: readNullableString(json, 'state'),
      postalCode: readNullableString(json, 'postalCode'),
      country: readNullableString(json, 'country'),
      lat: json['lat'] == null ? null : readDouble(json, 'lat'),
      lng: json['lng'] == null ? null : readDouble(json, 'lng'),
      isActive: readBool(json, 'isActive'),
    );
  }
}

class CustomerRetailerSummary {
  const CustomerRetailerSummary({
    required this.retailerId,
    required this.name,
    required this.website,
    required this.isEnabled,
    required this.isConnected,
    required this.locations,
  });

  final String retailerId;
  final String name;
  final String? website;
  final bool isEnabled;
  final bool isConnected;
  final List<RetailerLocation> locations;

  factory CustomerRetailerSummary.fromJson(Object? raw) {
    final json = asJsonMap(raw);
    return CustomerRetailerSummary(
      retailerId: readString(json, 'retailerId'),
      name: readString(json, 'name'),
      website: readNullableString(json, 'website'),
      isEnabled: readBool(json, 'isEnabled'),
      isConnected: readBool(json, 'isConnected'),
      locations: [
        for (final location in asJsonList(json['locations']))
          RetailerLocation.fromJson(location),
      ],
    );
  }
}

class CustomerAddressSummary {
  const CustomerAddressSummary({
    required this.addressId,
    required this.label,
    required this.addressLine,
    required this.instructions,
    required this.isDefault,
    this.line1,
    this.line2,
    this.city,
    this.state,
    this.postalCode,
    this.country,
  });

  final String addressId;
  final String? label;
  final String? line1;
  final String? line2;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final String? instructions;
  final String addressLine;
  final bool isDefault;

  factory CustomerAddressSummary.fromJson(Object? raw) {
    final json = asJsonMap(raw);
    return CustomerAddressSummary(
      addressId: readString(json, 'addressId'),
      label: readNullableString(json, 'label'),
      line1: readNullableString(json, 'line1'),
      line2: readNullableString(json, 'line2'),
      city: readNullableString(json, 'city'),
      state: readNullableString(json, 'state'),
      postalCode: readNullableString(json, 'postalCode'),
      country: readNullableString(json, 'country'),
      instructions: readNullableString(json, 'instructions'),
      addressLine: readString(json, 'addressLine'),
      isDefault: readBool(json, 'isDefault'),
    );
  }
}

class CustomerCartSummary {
  const CustomerCartSummary({
    required this.cartId,
    required this.retailerId,
    required this.retailerLocationId,
    required this.status,
    required this.itemCount,
    required this.subtotalCents,
  });

  final String cartId;
  final String retailerId;
  final String? retailerLocationId;
  final String? status;
  final int itemCount;
  final int subtotalCents;

  factory CustomerCartSummary.fromJson(Object? raw) {
    final json = asJsonMap(raw);
    return CustomerCartSummary(
      cartId: readString(json, 'cartId'),
      retailerId: readString(json, 'retailerId'),
      retailerLocationId: readNullableString(json, 'retailerLocationId'),
      status: readNullableString(json, 'status'),
      itemCount: readInt(json, 'itemCount'),
      subtotalCents: readInt(json, 'subtotalCents'),
    );
  }
}

class CustomerOrderSummary {
  const CustomerOrderSummary({
    required this.orderId,
    required this.retailerId,
    required this.retailerName,
    required this.status,
    required this.placedAt,
    required this.totalCents,
    required this.currency,
    required this.itemCount,
    this.externalOrderId,
    this.retailerLocationId,
    this.retailerLocationName,
  });

  final String orderId;
  final String? externalOrderId;
  final String retailerId;
  final String retailerName;
  final String? retailerLocationId;
  final String? retailerLocationName;
  final String? status;
  final DateTime? placedAt;
  final int totalCents;
  final String? currency;
  final int itemCount;

  factory CustomerOrderSummary.fromJson(Object? raw) {
    final json = asJsonMap(raw);
    return CustomerOrderSummary(
      orderId: readString(json, 'orderId'),
      externalOrderId: readNullableString(json, 'externalOrderId'),
      retailerId: readString(json, 'retailerId'),
      retailerName: readString(json, 'retailerName'),
      retailerLocationId: readNullableString(json, 'retailerLocationId'),
      retailerLocationName: readNullableString(json, 'retailerLocationName'),
      status: readNullableString(json, 'status'),
      placedAt: readDateTime(json, 'placedAt'),
      totalCents: readInt(json, 'totalCents'),
      currency: readNullableString(json, 'currency'),
      itemCount: readInt(json, 'itemCount'),
    );
  }
}

class CustomerSupportTicketSummary {
  const CustomerSupportTicketSummary({
    required this.ticketId,
    required this.title,
    required this.status,
    required this.summary,
    this.orderId,
  });

  final String ticketId;
  final String? orderId;
  final String title;
  final String? status;
  final String summary;

  factory CustomerSupportTicketSummary.fromJson(Object? raw) {
    final json = asJsonMap(raw);
    return CustomerSupportTicketSummary(
      ticketId: readString(json, 'ticketId'),
      orderId: readNullableString(json, 'orderId'),
      title: readString(json, 'title'),
      status: readNullableString(json, 'status'),
      summary: readString(json, 'summary'),
    );
  }
}

class CustomerBootstrap {
  const CustomerBootstrap({
    required this.customer,
    required this.retailers,
    required this.addresses,
    required this.carts,
    required this.orders,
    required this.supportTickets,
    required this.defaultAddressId,
  });

  final CustomerProfile customer;
  final List<CustomerRetailerSummary> retailers;
  final List<CustomerAddressSummary> addresses;
  final List<CustomerCartSummary> carts;
  final List<CustomerOrderSummary> orders;
  final List<CustomerSupportTicketSummary> supportTickets;
  final String? defaultAddressId;

  factory CustomerBootstrap.fromJson(Object? raw) {
    final json = asJsonMap(raw);
    return CustomerBootstrap(
      customer: CustomerProfile.fromJson(json['customer']),
      retailers: [
        for (final retailer in asJsonList(json['retailers']))
          CustomerRetailerSummary.fromJson(retailer),
      ],
      addresses: [
        for (final address in asJsonList(json['addresses']))
          CustomerAddressSummary.fromJson(address),
      ],
      carts: [
        for (final cart in asJsonList(json['carts']))
          CustomerCartSummary.fromJson(cart)
      ],
      orders: [
        for (final order in asJsonList(json['orders']))
          CustomerOrderSummary.fromJson(order)
      ],
      supportTickets: [
        for (final ticket in asJsonList(json['supportTickets']))
          CustomerSupportTicketSummary.fromJson(ticket),
      ],
      defaultAddressId: readNullableString(json, 'defaultAddressId'),
    );
  }
}

class CustomerCatalogCategory {
  const CustomerCatalogCategory({
    required this.categoryId,
    required this.name,
  });

  final String categoryId;
  final String name;

  factory CustomerCatalogCategory.fromJson(Object? raw) {
    final json = asJsonMap(raw);
    return CustomerCatalogCategory(
      categoryId: readString(json, 'categoryId'),
      name: readString(json, 'name'),
    );
  }
}

class CustomerCatalogProduct {
  const CustomerCatalogProduct({
    required this.productId,
    required this.retailerId,
    required this.categoryId,
    required this.categoryName,
    required this.name,
    required this.unitPriceCents,
    required this.currency,
    required this.isAvailable,
    this.externalSku,
    this.description,
    this.imageUrl,
  });

  final String productId;
  final String retailerId;
  final String categoryId;
  final String categoryName;
  final String? externalSku;
  final String name;
  final String? description;
  final String? imageUrl;
  final int unitPriceCents;
  final String currency;
  final bool isAvailable;

  factory CustomerCatalogProduct.fromJson(Object? raw) {
    final json = asJsonMap(raw);
    return CustomerCatalogProduct(
      productId: readString(json, 'productId'),
      retailerId: readString(json, 'retailerId'),
      categoryId: readString(json, 'categoryId'),
      categoryName: readString(json, 'categoryName'),
      externalSku: readNullableString(json, 'externalSku'),
      name: readString(json, 'name'),
      description: readNullableString(json, 'description'),
      imageUrl: readNullableString(json, 'imageUrl'),
      unitPriceCents: readInt(json, 'unitPriceCents'),
      currency: readString(json, 'currency', fallback: 'USD'),
      isAvailable: readBool(json, 'isAvailable'),
    );
  }
}

class CustomerCatalog {
  const CustomerCatalog({
    required this.location,
    required this.retailerId,
    required this.retailerName,
    required this.categories,
    required this.products,
    required this.cart,
  });

  final RetailerLocation location;
  final String retailerId;
  final String retailerName;
  final List<CustomerCatalogCategory> categories;
  final List<CustomerCatalogProduct> products;
  final CustomerCartSummary? cart;

  factory CustomerCatalog.fromJson(Object? raw) {
    final json = asJsonMap(raw);
    final retailer = asJsonMap(json['retailer']);
    return CustomerCatalog(
      location: RetailerLocation.fromJson(json['location']),
      retailerId: readString(retailer, 'retailerId'),
      retailerName: readString(retailer, 'name'),
      categories: [
        for (final category in asJsonList(json['categories']))
          CustomerCatalogCategory.fromJson(category),
      ],
      products: [
        for (final product in asJsonList(json['products']))
          CustomerCatalogProduct.fromJson(product),
      ],
      cart: json['cart'] == null
          ? null
          : CustomerCartSummary.fromJson(json['cart']),
    );
  }
}

class CustomerRetailerConnection {
  const CustomerRetailerConnection({
    required this.retailerId,
    required this.isConnected,
    required this.connectedAt,
  });

  final String retailerId;
  final bool isConnected;
  final DateTime connectedAt;

  factory CustomerRetailerConnection.fromJson(Object? raw) {
    final json = asJsonMap(raw);
    return CustomerRetailerConnection(
      retailerId: readString(json, 'retailerId'),
      isConnected: readBool(json, 'isConnected'),
      connectedAt: readDateTime(json, 'connectedAt') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class CheckoutPricing {
  const CheckoutPricing({
    required this.subtotalCents,
    required this.serviceFeeCents,
    required this.deliveryFeeCents,
    required this.estimatedTaxCents,
    required this.tipCents,
    required this.totalCents,
    required this.currency,
  });

  final int subtotalCents;
  final int serviceFeeCents;
  final int deliveryFeeCents;
  final int estimatedTaxCents;
  final int tipCents;
  final int totalCents;
  final String currency;

  factory CheckoutPricing.fromJson(Object? raw) {
    final json = asJsonMap(raw);
    return CheckoutPricing(
      subtotalCents: readInt(json, 'subtotalCents'),
      serviceFeeCents: readInt(json, 'serviceFeeCents'),
      deliveryFeeCents: readInt(json, 'deliveryFeeCents'),
      estimatedTaxCents: readInt(json, 'estimatedTaxCents'),
      tipCents: readInt(json, 'tipCents'),
      totalCents: readInt(json, 'totalCents'),
      currency: readString(json, 'currency', fallback: 'USD'),
    );
  }
}

class CheckoutPayment {
  const CheckoutPayment({
    required this.paymentId,
    required this.status,
    required this.amountCents,
    required this.currency,
  });

  final String paymentId;
  final String status;
  final int amountCents;
  final String currency;

  factory CheckoutPayment.fromJson(Object? raw) {
    final json = asJsonMap(raw);
    return CheckoutPayment(
      paymentId: readString(json, 'paymentId'),
      status: readString(json, 'status'),
      amountCents: readInt(json, 'amountCents'),
      currency: readString(json, 'currency', fallback: 'USD'),
    );
  }
}

class CheckoutDelivery {
  const CheckoutDelivery({
    required this.deliveryId,
    required this.status,
    required this.pickupLocation,
  });

  final String deliveryId;
  final String status;
  final String pickupLocation;

  factory CheckoutDelivery.fromJson(Object? raw) {
    final json = asJsonMap(raw);
    return CheckoutDelivery(
      deliveryId: readString(json, 'deliveryId'),
      status: readString(json, 'status'),
      pickupLocation: readString(json, 'pickupLocation'),
    );
  }
}

class CustomerCheckout {
  const CustomerCheckout({
    required this.order,
    required this.pricing,
    required this.payment,
    required this.delivery,
  });

  final CustomerOrderSummary order;
  final CheckoutPricing pricing;
  final CheckoutPayment payment;
  final CheckoutDelivery delivery;

  factory CustomerCheckout.fromJson(Object? raw) {
    final json = asJsonMap(raw);
    return CustomerCheckout(
      order: CustomerOrderSummary.fromJson(json['order']),
      pricing: CheckoutPricing.fromJson(json['pricing']),
      payment: CheckoutPayment.fromJson(json['payment']),
      delivery: CheckoutDelivery.fromJson(json['delivery']),
    );
  }
}

class DriverJobSummary {
  const DriverJobSummary({
    required this.deliveryId,
    required this.orderId,
    required this.title,
    required this.pickupLocationId,
    required this.pickupName,
    required this.pickupAddressLine,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffName,
    required this.dropoffAddressLine,
    required this.zone,
    required this.payoutEstimateCents,
    required this.distanceMiles,
    required this.etaMinutes,
    required this.stage,
    required this.detailLines,
    required this.basePayCents,
    required this.tipCents,
  });

  final String deliveryId;
  final String orderId;
  final String title;
  final String? pickupLocationId;
  final String pickupName;
  final String pickupAddressLine;
  final double? pickupLat;
  final double? pickupLng;
  final String dropoffName;
  final String dropoffAddressLine;
  final String zone;
  final int payoutEstimateCents;
  final double distanceMiles;
  final int etaMinutes;
  final String stage;
  final List<String> detailLines;
  final int basePayCents;
  final int tipCents;

  factory DriverJobSummary.fromJson(Object? raw) {
    final json = asJsonMap(raw);
    return DriverJobSummary(
      deliveryId: readString(json, 'deliveryId'),
      orderId: readString(json, 'orderId'),
      title: readString(json, 'title'),
      pickupLocationId: readNullableString(json, 'pickupLocationId'),
      pickupName: readString(json, 'pickupName'),
      pickupAddressLine: readString(json, 'pickupAddressLine'),
      pickupLat:
          json['pickupLat'] == null ? null : readDouble(json, 'pickupLat'),
      pickupLng:
          json['pickupLng'] == null ? null : readDouble(json, 'pickupLng'),
      dropoffName: readString(json, 'dropoffName'),
      dropoffAddressLine: readString(json, 'dropoffAddressLine'),
      zone: readString(json, 'zone'),
      payoutEstimateCents: readInt(json, 'payoutEstimateCents'),
      distanceMiles: readDouble(json, 'distanceMiles'),
      etaMinutes: readInt(json, 'etaMinutes'),
      stage: readString(json, 'stage'),
      detailLines: [
        for (final value in asJsonList(json['detailLines'])) value.toString(),
      ],
      basePayCents: readInt(json, 'basePayCents'),
      tipCents: readInt(json, 'tipCents'),
    );
  }
}

class DriverSupportTicketSummary {
  const DriverSupportTicketSummary({
    required this.ticketId,
    required this.deliveryId,
    required this.title,
    required this.status,
    required this.summary,
  });

  final String ticketId;
  final String? deliveryId;
  final String title;
  final String? status;
  final String summary;

  factory DriverSupportTicketSummary.fromJson(Object? raw) {
    final json = asJsonMap(raw);
    return DriverSupportTicketSummary(
      ticketId: readString(json, 'ticketId'),
      deliveryId: readNullableString(json, 'deliveryId'),
      title: readString(json, 'title'),
      status: readNullableString(json, 'status'),
      summary: readString(json, 'summary'),
    );
  }
}

class DriverEarningsSummary {
  const DriverEarningsSummary({
    required this.todayGrossCents,
    required this.tipsCents,
    required this.bonusCents,
    required this.nextPayoutLabel,
  });

  final int todayGrossCents;
  final int tipsCents;
  final int bonusCents;
  final String nextPayoutLabel;

  factory DriverEarningsSummary.fromJson(Object? raw) {
    final json = asJsonMap(raw);
    return DriverEarningsSummary(
      todayGrossCents: readInt(json, 'todayGrossCents'),
      tipsCents: readInt(json, 'tipsCents'),
      bonusCents: readInt(json, 'bonusCents'),
      nextPayoutLabel: readString(json, 'nextPayoutLabel'),
    );
  }
}

class DriverBootstrap {
  const DriverBootstrap({
    required this.driver,
    required this.availableJobs,
    required this.activeJobs,
    required this.completedJobs,
    required this.supportTickets,
    required this.earningsSummary,
  });

  final DriverProfile driver;
  final List<DriverJobSummary> availableJobs;
  final List<DriverJobSummary> activeJobs;
  final List<DriverJobSummary> completedJobs;
  final List<DriverSupportTicketSummary> supportTickets;
  final DriverEarningsSummary earningsSummary;

  factory DriverBootstrap.fromJson(Object? raw) {
    final json = asJsonMap(raw);
    return DriverBootstrap(
      driver: DriverProfile.fromJson(json['driver']),
      availableJobs: [
        for (final value in asJsonList(json['availableJobs']))
          DriverJobSummary.fromJson(value),
      ],
      activeJobs: [
        for (final value in asJsonList(json['activeJobs']))
          DriverJobSummary.fromJson(value),
      ],
      completedJobs: [
        for (final value in asJsonList(json['completedJobs']))
          DriverJobSummary.fromJson(value),
      ],
      supportTickets: [
        for (final value in asJsonList(json['supportTickets']))
          DriverSupportTicketSummary.fromJson(value),
      ],
      earningsSummary: DriverEarningsSummary.fromJson(json['earningsSummary']),
    );
  }
}

class ResourceAddress {
  const ResourceAddress({
    required this.addressId,
    required this.customerId,
    required this.label,
    required this.line1,
    required this.line2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.instructions,
    required this.isDefault,
  });

  final String addressId;
  final String customerId;
  final String? label;
  final String? line1;
  final String? line2;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final String? instructions;
  final bool isDefault;

  factory ResourceAddress.fromJson(Object? raw) {
    final json = asJsonMap(raw);
    return ResourceAddress(
      addressId: readString(json, 'address_id'),
      customerId: readString(json, 'customer_id'),
      label: readNullableString(json, 'label'),
      line1: readNullableString(json, 'line1'),
      line2: readNullableString(json, 'line2'),
      city: readNullableString(json, 'city'),
      state: readNullableString(json, 'state'),
      postalCode: readNullableString(json, 'postal_code'),
      country: readNullableString(json, 'country'),
      instructions: readNullableString(json, 'instructions'),
      isDefault: readBool(json, 'is_default'),
    );
  }
}

class ResourceCart {
  const ResourceCart({
    required this.cartId,
    required this.customerId,
    required this.retailerId,
    required this.retailerLocationId,
    required this.status,
  });

  final String cartId;
  final String customerId;
  final String retailerId;
  final String? retailerLocationId;
  final String? status;

  factory ResourceCart.fromJson(Object? raw) {
    final json = asJsonMap(raw);
    return ResourceCart(
      cartId: readString(json, 'cart_id'),
      customerId: readString(json, 'customer_id'),
      retailerId: readString(json, 'retailer_id'),
      retailerLocationId: readNullableString(json, 'retailer_location_id'),
      status: readNullableString(json, 'status'),
    );
  }
}

class ResourceCartItem {
  const ResourceCartItem({
    required this.cartItemId,
    required this.cartId,
    required this.productId,
    required this.externalSku,
    required this.nameSnapshot,
    required this.unitPriceCents,
    required this.quantity,
    required this.substitutionAllowed,
    required this.notes,
  });

  final String cartItemId;
  final String cartId;
  final String productId;
  final String? externalSku;
  final String? nameSnapshot;
  final int unitPriceCents;
  final int quantity;
  final bool substitutionAllowed;
  final String? notes;

  factory ResourceCartItem.fromJson(Object? raw) {
    final json = asJsonMap(raw);
    return ResourceCartItem(
      cartItemId: readString(json, 'cart_item_id'),
      cartId: readString(json, 'cart_id'),
      productId: readString(json, 'product_id'),
      externalSku: readNullableString(json, 'external_sku'),
      nameSnapshot: readNullableString(json, 'name_snapshot'),
      unitPriceCents: readInt(json, 'unit_price_cents'),
      quantity: readInt(json, 'quantity'),
      substitutionAllowed: readBool(json, 'substitution_allowed'),
      notes: readNullableString(json, 'notes'),
    );
  }
}

class ResourceSupportTicket {
  const ResourceSupportTicket({
    required this.ticketId,
    required this.customerId,
    required this.orderId,
    required this.issueType,
    required this.message,
    required this.status,
  });

  final String ticketId;
  final String customerId;
  final String? orderId;
  final String? issueType;
  final String? message;
  final String? status;

  factory ResourceSupportTicket.fromJson(Object? raw) {
    final json = asJsonMap(raw);
    return ResourceSupportTicket(
      ticketId: readString(json, 'ticket_id'),
      customerId: readString(json, 'customer_id'),
      orderId: readNullableString(json, 'order_id'),
      issueType: readNullableString(json, 'issue_type'),
      message: readNullableString(json, 'message'),
      status: readNullableString(json, 'status'),
    );
  }
}

class ResourceOrderStatusHistory {
  const ResourceOrderStatusHistory({
    required this.orderStatusHistoryId,
    required this.orderId,
    required this.status,
    required this.statusTime,
    required this.note,
  });

  final String orderStatusHistoryId;
  final String orderId;
  final String? status;
  final DateTime? statusTime;
  final String? note;

  factory ResourceOrderStatusHistory.fromJson(Object? raw) {
    final json = asJsonMap(raw);
    return ResourceOrderStatusHistory(
      orderStatusHistoryId: readString(json, 'order_status_history_id'),
      orderId: readString(json, 'order_id'),
      status: readNullableString(json, 'status'),
      statusTime: readDateTime(json, 'status_time'),
      note: readNullableString(json, 'note'),
    );
  }
}

class ResourceDriverSupportTicket {
  const ResourceDriverSupportTicket({
    required this.ticketId,
    required this.driverId,
    required this.deliveryId,
    required this.orderId,
    required this.issueType,
    required this.message,
    required this.status,
  });

  final String ticketId;
  final String driverId;
  final String? deliveryId;
  final String? orderId;
  final String? issueType;
  final String? message;
  final String? status;

  factory ResourceDriverSupportTicket.fromJson(Object? raw) {
    final json = asJsonMap(raw);
    return ResourceDriverSupportTicket(
      ticketId: readString(json, 'ticket_id'),
      driverId: readString(json, 'driver_id'),
      deliveryId: readNullableString(json, 'delivery_id'),
      orderId: readNullableString(json, 'order_id'),
      issueType: readNullableString(json, 'issue_type'),
      message: readNullableString(json, 'message'),
      status: readNullableString(json, 'status'),
    );
  }
}

class ResourceDriverEarning {
  const ResourceDriverEarning({
    required this.earningId,
    required this.driverId,
    required this.deliveryId,
    required this.basePayCents,
    required this.bonusCents,
    required this.tipCents,
    required this.totalPayCents,
    required this.currency,
    required this.status,
  });

  final String earningId;
  final String driverId;
  final String deliveryId;
  final int basePayCents;
  final int bonusCents;
  final int tipCents;
  final int totalPayCents;
  final String? currency;
  final String? status;

  factory ResourceDriverEarning.fromJson(Object? raw) {
    final json = asJsonMap(raw);
    return ResourceDriverEarning(
      earningId: readString(json, 'earning_id'),
      driverId: readString(json, 'driver_id'),
      deliveryId: readString(json, 'delivery_id'),
      basePayCents: readInt(json, 'base_pay_cents'),
      bonusCents: readInt(json, 'bonus_cents'),
      tipCents: readInt(json, 'tip_cents'),
      totalPayCents: readInt(json, 'total_pay_cents'),
      currency: readNullableString(json, 'currency'),
      status: readNullableString(json, 'status'),
    );
  }
}

class ResourceDriverPayout {
  const ResourceDriverPayout({
    required this.payoutId,
    required this.driverId,
    required this.amountCents,
    required this.currency,
    required this.status,
    required this.provider,
    required this.providerRef,
  });

  final String payoutId;
  final String driverId;
  final int amountCents;
  final String? currency;
  final String? status;
  final String? provider;
  final String? providerRef;

  factory ResourceDriverPayout.fromJson(Object? raw) {
    final json = asJsonMap(raw);
    return ResourceDriverPayout(
      payoutId: readString(json, 'payout_id'),
      driverId: readString(json, 'driver_id'),
      amountCents: readInt(json, 'amount_cents'),
      currency: readNullableString(json, 'currency'),
      status: readNullableString(json, 'status'),
      provider: readNullableString(json, 'provider'),
      providerRef: readNullableString(json, 'provider_ref'),
    );
  }
}
