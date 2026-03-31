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

class AddressPreview {
  const AddressPreview({
    required this.id,
    required this.label,
    required this.addressLine,
    required this.isDefault,
  });

  final String id;
  final String label;
  final String addressLine;
  final bool isDefault;
}

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

class CustomerNavItem {
  const CustomerNavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

const customerBottomNavItems = <CustomerNavItem>[
  CustomerNavItem(icon: Icons.home_rounded, label: 'Home'),
  CustomerNavItem(icon: Icons.search_rounded, label: 'Search'),
  CustomerNavItem(icon: Icons.receipt_long_rounded, label: 'Orders'),
  CustomerNavItem(icon: Icons.headset_mic_rounded, label: 'Support'),
  CustomerNavItem(icon: Icons.person_outline_rounded, label: 'Account'),
];
