import 'package:flutter/material.dart';

import '../customer_home_models.dart';
import '../widgets/cart_section.dart';
import '../widgets/catalog_item_card.dart';
import '../widgets/store_selector_section.dart';

/// Owns Home tab UI for the customer shell.
class CustomerTabHome extends StatelessWidget {
  const CustomerTabHome({
    super.key,
    required this.stores,
    required this.selectedStoreId,
    required this.previewItems,
    required this.cartLines,
    required this.subtotal,
    required this.serviceFee,
    required this.deliveryFee,
    required this.estimatedTax,
    required this.total,
    required this.onStoreSelected,
    required this.onAddToCart,
    required this.quantityInCartForItem,
    required this.onIncreaseQty,
    required this.onDecreaseQty,
    required this.onRemoveLine,
    required this.onClearCart,
    required this.onCheckout,
    required this.formatPrice,
  });

  final List<StoreOption> stores;
  final String selectedStoreId;
  final List<CatalogItem> previewItems;
  final List<CartLine> cartLines;
  final double subtotal;
  final double serviceFee;
  final double deliveryFee;
  final double estimatedTax;
  final double total;
  final ValueChanged<String> onStoreSelected;
  final ValueChanged<CatalogItem> onAddToCart;
  final int Function(String itemId) quantityInCartForItem;
  final ValueChanged<String> onIncreaseQty;
  final ValueChanged<String> onDecreaseQty;
  final ValueChanged<String> onRemoveLine;
  final VoidCallback onClearCart;
  final VoidCallback onCheckout;
  final String Function(double value) formatPrice;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      key: const Key('main-tab-home'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Home', style: textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(
          'Choose your store, add items, and review cart totals.',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        StoreSelectorSection(
          stores: stores,
          selectedStoreId: selectedStoreId,
          onStoreSelected: onStoreSelected,
        ),
        const SizedBox(height: 18),
        Text('Recommended items', style: textTheme.titleMedium),
        const SizedBox(height: 10),
        for (final item in previewItems) ...[
          CatalogItemCard(
            item: item,
            quantityInCart: quantityInCartForItem(item.id),
            onAdd: () => onAddToCart(item),
            formatPrice: formatPrice,
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 14),
        CartSection(
          cartLines: cartLines,
          subtotal: subtotal,
          serviceFee: serviceFee,
          deliveryFee: deliveryFee,
          estimatedTax: estimatedTax,
          total: total,
          onIncreaseQty: onIncreaseQty,
          onDecreaseQty: onDecreaseQty,
          onRemoveLine: onRemoveLine,
          onClearCart: onClearCart,
          onCheckout: onCheckout,
          formatPrice: formatPrice,
        ),
      ],
    );
  }
}
