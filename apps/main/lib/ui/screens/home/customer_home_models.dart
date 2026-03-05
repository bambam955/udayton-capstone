import 'package:flutter/material.dart';

/// Owns data types used by the customer home shell and tab sections.
class StoreOption {
  const StoreOption({
    required this.id,
    required this.name,
    required this.etaText,
    required this.ratingText,
  });

  final String id;
  final String name;
  final String etaText;
  final String ratingText;
}

class CatalogItem {
  const CatalogItem({
    required this.id,
    required this.storeId,
    required this.name,
    required this.category,
    required this.price,
    required this.unit,
    required this.badgeText,
    required this.gradient,
  });

  final String id;
  final String storeId;
  final String name;
  final String category;
  final double price;
  final String unit;
  final String badgeText;
  final List<Color> gradient;
}

class CartLine {
  const CartLine({
    required this.itemId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
  });

  final String itemId;
  final String name;
  final double unitPrice;
  final int quantity;

  CartLine copyWith({
    String? itemId,
    String? name,
    double? unitPrice,
    int? quantity,
  }) {
    return CartLine(
      itemId: itemId ?? this.itemId,
      name: name ?? this.name,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
    );
  }
}

class OrderPreview {
  const OrderPreview({
    required this.id,
    required this.businessName,
    required this.storeName,
    required this.status,
    required this.etaText,
    required this.total,
    required this.itemCount,
  });

  final String id;
  final String businessName;
  final String storeName;
  final String status;
  final String etaText;
  final double total;
  final int itemCount;
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

class CustomerNavItem {
  const CustomerNavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}
