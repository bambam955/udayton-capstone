import 'package:flutter/material.dart';

/// Owns view models used by the customer home shell and tab sections.
class StoreOption {
  const StoreOption({
    required this.id,
    required this.retailerId,
    required this.name,
    required this.subtitle,
    required this.isConnected,
  });

  final String id;
  final String retailerId;
  final String name;
  final String subtitle;
  final bool isConnected;
}

/// Presentation model for products displayed in home/search cards.
class CatalogItem {
  const CatalogItem({
    required this.id,
    required this.name,
    required this.category,
    required this.unitPriceCents,
    required this.badgeText,
    required this.gradient,
    required this.isAvailable,
    this.description,
    this.externalSku,
  });

  final String id;
  final String name;
  final String category;
  final String? description;
  final String? externalSku;
  final int unitPriceCents;
  final String badgeText;
  final List<Color> gradient;
  final bool isAvailable;
}

/// Flattened cart item model tailored to the customer cart UI.
class CartLine {
  const CartLine({
    required this.cartItemId,
    required this.productId,
    required this.name,
    required this.unitPriceCents,
    required this.quantity,
  });

  final String cartItemId;
  final String productId;
  final String name;
  final int unitPriceCents;
  final int quantity;
}

/// Order summary shown in the orders tab and details sheet launcher.
class OrderPreview {
  const OrderPreview({
    required this.id,
    required this.retailerName,
    required this.storeName,
    required this.status,
    required this.etaText,
    required this.totalCents,
    required this.itemCount,
  });

  final String id;
  final String retailerName;
  final String? storeName;
  final String status;
  final String etaText;
  final int totalCents;
  final int itemCount;
}

/// Timeline row loaded lazily when opening order details.
class OrderTimelineEntry {
  const OrderTimelineEntry({
    required this.id,
    required this.status,
    required this.occurredAt,
    required this.note,
  });

  final String id;
  final String status;
  final DateTime? occurredAt;
  final String? note;
}

/// Support summary shown in the support tab.
class SupportTicket {
  const SupportTicket({
    required this.id,
    required this.title,
    required this.status,
    required this.summary,
  });

  final String id;
  final String title;
  final String status;
  final String summary;
}

/// Compact address summary rendered on the account tab.
class AddressPreview {
  const AddressPreview({
    required this.id,
    required this.label,
    required this.line1,
    required this.line2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.instructions,
    required this.addressLine,
    required this.isDefault,
  });

  final String id;
  final String label;
  final String line1;
  final String line2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String instructions;
  final String addressLine;
  final bool isDefault;
}

/// Account tab aggregate that combines customer identity, addresses, and store
/// connection state into one render-friendly object.
class CustomerAccountOverview {
  const CustomerAccountOverview({
    required this.customerName,
    required this.customerEmail,
    required this.connectedStoreCount,
    required this.trackedOrderCount,
    required this.addresses,
    required this.stores,
  });

  final String customerName;
  final String customerEmail;
  final int connectedStoreCount;
  final int trackedOrderCount;
  final List<AddressPreview> addresses;
  final List<StoreOption> stores;
}

/// Navigation item backing the customer's bottom navigation bar.
class CustomerNavItem {
  const CustomerNavItem({
    required this.icon,
    required this.label,
    required this.routePath,
  });

  final IconData icon;
  final String label;
  final String routePath;
}

const String customerDefaultRoutePath = '/home';

/// Shared nav configuration so labels/icons stay aligned across shell and tests.
const customerBottomNavItems = <CustomerNavItem>[
  CustomerNavItem(
    icon: Icons.home_rounded,
    label: 'Home',
    routePath: customerDefaultRoutePath,
  ),
  CustomerNavItem(
    icon: Icons.search_rounded,
    label: 'Search',
    routePath: '/search',
  ),
  CustomerNavItem(
    icon: Icons.receipt_long_rounded,
    label: 'Orders',
    routePath: '/orders',
  ),
  CustomerNavItem(
    icon: Icons.headset_mic_rounded,
    label: 'Support',
    routePath: '/support',
  ),
  CustomerNavItem(
    icon: Icons.person_outline_rounded,
    label: 'Account',
    routePath: '/account',
  ),
];

/// Keeps browser URLs, startup routes, and tab indexes aligned.
String customerNormalizeRoutePath(String? routePath) {
  final path = routePath == null ? '' : Uri.tryParse(routePath)?.path ?? '';
  if (path.isEmpty || path == '/') {
    return customerDefaultRoutePath;
  }

  for (final item in customerBottomNavItems) {
    if (item.routePath == path) {
      return path;
    }
  }

  // Unknown app routes should land on a useful page instead of a blank shell.
  return customerDefaultRoutePath;
}

int customerNavIndexForRoutePath(String? routePath) {
  final normalizedRoutePath = customerNormalizeRoutePath(routePath);
  for (var index = 0; index < customerBottomNavItems.length; index += 1) {
    if (customerBottomNavItems[index].routePath == normalizedRoutePath) {
      return index;
    }
  }

  return 0;
}
