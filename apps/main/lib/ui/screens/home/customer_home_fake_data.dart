import 'package:flutter/material.dart';

import 'customer_home_models.dart';

/// Owns static demo data used by the customer home shell.
const catalogCategories = [
  'All',
  'Pantry',
  'Produce',
  'Beverages',
  'Cleaning',
];

const customerBottomNavItems = [
  CustomerNavItem(icon: Icons.home_rounded, label: 'Home'),
  CustomerNavItem(icon: Icons.search_rounded, label: 'Search'),
  CustomerNavItem(icon: Icons.receipt_long_rounded, label: 'Orders'),
  CustomerNavItem(icon: Icons.headset_mic_rounded, label: 'Support'),
  CustomerNavItem(icon: Icons.person_outline_rounded, label: 'Account'),
];

const stores = [
  StoreOption(
    id: 'target_midtown',
    name: 'Target Midtown',
    etaText: 'Ready in ~22 min',
    ratingText: '4.9',
  ),
  StoreOption(
    id: 'walmart_eastgate',
    name: 'Walmart Eastgate',
    etaText: 'Ready in ~28 min',
    ratingText: '4.8',
  ),
  StoreOption(
    id: 'target_harbor',
    name: 'Target Harbor',
    etaText: 'Ready in ~19 min',
    ratingText: '4.7',
  ),
];

const catalog = [
  CatalogItem(
    id: 'item_101',
    storeId: 'target_midtown',
    name: 'Premium Olive Oil',
    category: 'Pantry',
    price: 12.99,
    unit: '750ml',
    badgeText: 'Popular',
    gradient: [Color(0xFF98D8D6), Color(0xFFC8E3AF)],
  ),
  CatalogItem(
    id: 'item_102',
    storeId: 'target_midtown',
    name: 'All-Purpose Flour',
    category: 'Pantry',
    price: 4.49,
    unit: '5 lb',
    badgeText: 'Value',
    gradient: [Color(0xFFB1D7EF), Color(0xFFC9E8CF)],
  ),
  CatalogItem(
    id: 'item_103',
    storeId: 'target_midtown',
    name: 'Fresh Roma Tomatoes',
    category: 'Produce',
    price: 3.29,
    unit: '1 lb',
    badgeText: 'Fresh',
    gradient: [Color(0xFFAAD8B4), Color(0xFFE3E5BE)],
  ),
  CatalogItem(
    id: 'item_201',
    storeId: 'walmart_eastgate',
    name: 'Whole Milk',
    category: 'Beverages',
    price: 3.99,
    unit: '1 gal',
    badgeText: 'Top seller',
    gradient: [Color(0xFFA2D1E2), Color(0xFFC9E1BC)],
  ),
  CatalogItem(
    id: 'item_202',
    storeId: 'walmart_eastgate',
    name: 'Paper Towels Pack',
    category: 'Cleaning',
    price: 10.59,
    unit: '6 rolls',
    badgeText: 'Bulk',
    gradient: [Color(0xFFBDD9E9), Color(0xFFDCE9C2)],
  ),
  CatalogItem(
    id: 'item_203',
    storeId: 'walmart_eastgate',
    name: 'Sparkling Water Case',
    category: 'Beverages',
    price: 8.99,
    unit: '12 cans',
    badgeText: 'Low stock',
    gradient: [Color(0xFF9CD2D0), Color(0xFFCEE6BD)],
  ),
  CatalogItem(
    id: 'item_301',
    storeId: 'target_harbor',
    name: 'Dish Soap Refill',
    category: 'Cleaning',
    price: 5.99,
    unit: '32 oz',
    badgeText: 'Eco',
    gradient: [Color(0xFFB7D2DE), Color(0xFFD5E8C3)],
  ),
  CatalogItem(
    id: 'item_302',
    storeId: 'target_harbor',
    name: 'Bananas',
    category: 'Produce',
    price: 1.79,
    unit: '1 bunch',
    badgeText: 'Fresh',
    gradient: [Color(0xFFAED7B2), Color(0xFFE3E4B7)],
  ),
  CatalogItem(
    id: 'item_303',
    storeId: 'target_harbor',
    name: 'Cold Brew Coffee',
    category: 'Beverages',
    price: 6.49,
    unit: '48 oz',
    badgeText: 'New',
    gradient: [Color(0xFF9FCFDF), Color(0xFFC7E3BE)],
  ),
];

const orders = [
  OrderPreview(
    id: 'ord_1001',
    businessName: 'Northside Deli',
    storeName: 'Target Midtown',
    status: 'READY_FOR_PICKUP',
    etaText: 'Driver assignment in ~6 min',
    total: 128.40,
    itemCount: 19,
  ),
  OrderPreview(
    id: 'ord_1002',
    businessName: 'Elm Street Cafe',
    storeName: 'Walmart Eastgate',
    status: 'PICKING',
    etaText: 'Expected ready in ~14 min',
    total: 92.10,
    itemCount: 11,
  ),
  OrderPreview(
    id: 'ord_1003',
    businessName: 'Harbor Print Shop',
    storeName: 'Target Harbor',
    status: 'OUT_FOR_DELIVERY',
    etaText: 'ETA 24 min',
    total: 64.80,
    itemCount: 8,
  ),
];

const supportTickets = [
  SupportTicket(
    id: 'tk_771',
    title: 'Missing item follow-up',
    status: 'Open',
    summary: 'Linked to order ord_1002. Awaiting store confirmation.',
  ),
  SupportTicket(
    id: 'tk_782',
    title: 'Late delivery inquiry',
    status: 'In review',
    summary: 'Driver delay reported for Harbor corridor due to traffic.',
  ),
  SupportTicket(
    id: 'tk_790',
    title: 'Substitution dispute',
    status: 'Resolved',
    summary: 'Customer accepted replacement and ticket closed.',
  ),
];
