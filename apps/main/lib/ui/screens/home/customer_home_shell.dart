import 'package:flutter/material.dart';

import '../../widgets/customer_top_bar.dart';
import '../../widgets/status_badge.dart';
import 'customer_home_fake_data.dart';
import 'customer_home_models.dart';
import 'customer_order_details_sheet.dart';
import 'tabs/customer_tab_account.dart';
import 'tabs/customer_tab_home.dart';
import 'tabs/customer_tab_orders.dart';
import 'tabs/customer_tab_search.dart';
import 'tabs/customer_tab_support.dart';

/// Owns state coordination for customer home tabs and actions.
class CustomerHomeShell extends StatefulWidget {
  const CustomerHomeShell({super.key});

  @override
  State<CustomerHomeShell> createState() => _CustomerHomeShellState();
}

class _CustomerHomeShellState extends State<CustomerHomeShell> {
  String _selectedStoreId = stores.first.id;
  String _selectedCatalogCategory = catalogCategories.first;
  String _catalogSearchQuery = '';
  int _selectedNavIndex = 0;

  final Map<String, CartLine> _cartByItemId = <String, CartLine>{};

  List<CatalogItem> get _visibleCatalogItems {
    final query = _catalogSearchQuery.trim().toLowerCase();
    return catalog.where((item) {
      final matchesStore = item.storeId == _selectedStoreId;
      final matchesCategory = _selectedCatalogCategory == 'All' ||
          item.category == _selectedCatalogCategory;
      final matchesQuery = query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query) ||
          item.badgeText.toLowerCase().contains(query);
      return matchesStore && matchesCategory && matchesQuery;
    }).toList();
  }

  List<CatalogItem> get _homePreviewItems {
    return catalog
        .where((item) => item.storeId == _selectedStoreId)
        .take(3)
        .toList();
  }

  List<CartLine> get _cartLines {
    return _cartByItemId.values.toList();
  }

  double get _subtotal {
    return _cartLines.fold(
        0, (sum, line) => sum + line.unitPrice * line.quantity);
  }

  double get _serviceFee {
    if (_cartLines.isEmpty) {
      return 0;
    }
    return (_subtotal * 0.06).clamp(1.99, 12.00);
  }

  double get _deliveryFee {
    if (_cartLines.isEmpty) {
      return 0;
    }

    return switch (_selectedStoreId) {
      'target_midtown' => 4.49,
      'walmart_eastgate' => 5.29,
      'target_harbor' => 3.99,
      _ => 4.99,
    };
  }

  double get _estimatedTax {
    if (_cartLines.isEmpty) {
      return 0;
    }
    return _subtotal * 0.045;
  }

  double get _total {
    return _subtotal + _serviceFee + _deliveryFee + _estimatedTax;
  }

  void _onStoreSelected(String storeId) {
    setState(() {
      _selectedStoreId = storeId;
    });
  }

  void _onNavSelected(int index) {
    setState(() {
      _selectedNavIndex = index;
    });
  }

  void _addToCart(CatalogItem item) {
    setState(() {
      final existing = _cartByItemId[item.id];
      if (existing == null) {
        _cartByItemId[item.id] = CartLine(
          itemId: item.id,
          name: item.name,
          unitPrice: item.price,
          quantity: 1,
        );
      } else {
        _cartByItemId[item.id] =
            existing.copyWith(quantity: existing.quantity + 1);
      }
    });
  }

  void _increaseQty(String itemId) {
    final existing = _cartByItemId[itemId];
    if (existing == null) {
      return;
    }

    setState(() {
      _cartByItemId[itemId] =
          existing.copyWith(quantity: existing.quantity + 1);
    });
  }

  void _decreaseQty(String itemId) {
    final existing = _cartByItemId[itemId];
    if (existing == null) {
      return;
    }

    setState(() {
      final nextQty = existing.quantity - 1;
      if (nextQty <= 0) {
        _cartByItemId.remove(itemId);
      } else {
        _cartByItemId[itemId] = existing.copyWith(quantity: nextQty);
      }
    });
  }

  void _removeFromCart(String itemId) {
    setState(() {
      _cartByItemId.remove(itemId);
    });
  }

  void _clearCart() {
    setState(() {
      _cartByItemId.clear();
    });
  }

  void _showCheckoutDemo() {
    if (_cartLines.isEmpty) {
      return;
    }

    final message =
        'Checkout demo only. ${_cartLines.length} item(s), total ${_formatPrice(_total)}.';

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showDemoMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _onProfileAction(String action) {
    final message = switch (action) {
      'view_profile' => 'View profile clicked (demo only)',
      'switch_role' => 'Switch role clicked (demo only)',
      'sign_out' => 'Sign out clicked (demo only)',
      _ => 'Action clicked (demo only)',
    };

    _showDemoMessage(message);
  }

  void _showOrderDetails(OrderPreview order) {
    showCustomerOrderDetailsSheet(
      context: context,
      order: order,
      orderStatusTone: _orderStatusTone,
      formatPrice: _formatPrice,
    );
  }

  static StatusBadgeTone _orderStatusTone(String status) {
    final normalized = status.toUpperCase();
    if (normalized.contains('PICKING') || normalized.contains('SUBMITTED')) {
      return StatusBadgeTone.info;
    }
    if (normalized.contains('READY')) {
      return StatusBadgeTone.warning;
    }
    if (normalized.contains('OUT_FOR_DELIVERY') ||
        normalized.contains('DELIVERED')) {
      return StatusBadgeTone.success;
    }
    return StatusBadgeTone.neutral;
  }

  static StatusBadgeTone _supportStatusTone(String status) {
    final normalized = status.toLowerCase();
    if (normalized.contains('open')) {
      return StatusBadgeTone.warning;
    }
    if (normalized.contains('review')) {
      return StatusBadgeTone.info;
    }
    if (normalized.contains('resolve')) {
      return StatusBadgeTone.success;
    }
    return StatusBadgeTone.neutral;
  }

  static String _formatPrice(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }

  int _quantityInCartForItem(String itemId) {
    return _cartByItemId[itemId]?.quantity ?? 0;
  }

  Widget _buildTabContent() {
    return switch (_selectedNavIndex) {
      0 => CustomerTabHome(
          stores: stores,
          selectedStoreId: _selectedStoreId,
          previewItems: _homePreviewItems,
          cartLines: _cartLines,
          subtotal: _subtotal,
          serviceFee: _serviceFee,
          deliveryFee: _deliveryFee,
          estimatedTax: _estimatedTax,
          total: _total,
          onStoreSelected: _onStoreSelected,
          onAddToCart: _addToCart,
          quantityInCartForItem: _quantityInCartForItem,
          onIncreaseQty: _increaseQty,
          onDecreaseQty: _decreaseQty,
          onRemoveLine: _removeFromCart,
          onClearCart: _clearCart,
          onCheckout: _showCheckoutDemo,
          formatPrice: _formatPrice,
        ),
      1 => CustomerTabSearch(
          stores: stores,
          selectedStoreId: _selectedStoreId,
          categories: catalogCategories,
          selectedCategory: _selectedCatalogCategory,
          visibleItems: _visibleCatalogItems,
          cartItemCount: _cartLines.length,
          cartTotal: _total,
          onStoreSelected: _onStoreSelected,
          onSearchChanged: (value) {
            setState(() {
              _catalogSearchQuery = value;
            });
          },
          onCategorySelected: (category) {
            setState(() {
              _selectedCatalogCategory = category;
            });
          },
          onAddToCart: _addToCart,
          quantityInCartForItem: _quantityInCartForItem,
          onGoToHome: () {
            setState(() {
              _selectedNavIndex = 0;
            });
          },
          formatPrice: _formatPrice,
        ),
      2 => CustomerTabOrders(
          orders: orders,
          formatPrice: _formatPrice,
          orderStatusTone: _orderStatusTone,
          onViewOrder: _showOrderDetails,
        ),
      3 => CustomerTabSupport(
          supportTickets: supportTickets,
          supportStatusTone: _supportStatusTone,
          onQuickAction: _showDemoMessage,
        ),
      _ => CustomerTabAccount(
          stores: stores,
          orders: orders,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            children: [
              CustomerTopBar(onProfileAction: _onProfileAction),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: _buildTabContent(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _BottomNavBar(
        items: customerBottomNavItems,
        selectedIndex: _selectedNavIndex,
        onSelected: _onNavSelected,
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<CustomerNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelected,
      destinations: [
        for (final item in items)
          NavigationDestination(
            icon: Icon(item.icon, key: Key('customer-nav-${item.label}')),
            label: item.label,
          ),
      ],
    );
  }
}
