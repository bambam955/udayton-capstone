import 'package:flutter/material.dart';

import '../../../widgets/surface_card.dart';
import '../customer_home_models.dart';
import '../widgets/catalog_item_card.dart';
import '../widgets/store_selector_section.dart';

/// Owns Search tab UI for the customer shell.
class CustomerTabSearch extends StatelessWidget {
  const CustomerTabSearch({
    super.key,
    required this.stores,
    required this.selectedStoreId,
    required this.categories,
    required this.selectedCategory,
    required this.visibleItems,
    required this.cartItemCount,
    required this.cartTotal,
    required this.onStoreSelected,
    required this.onSearchChanged,
    required this.onCategorySelected,
    required this.onAddToCart,
    required this.quantityInCartForItem,
    required this.onGoToHome,
    required this.formatPrice,
  });

  final List<StoreOption> stores;
  final String? selectedStoreId;
  final List<String> categories;
  final String selectedCategory;
  final List<CatalogItem> visibleItems;
  final int cartItemCount;
  final int cartTotal;
  final ValueChanged<String> onStoreSelected;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onCategorySelected;
  final ValueChanged<CatalogItem> onAddToCart;
  final int Function(String itemId) quantityInCartForItem;
  final VoidCallback onGoToHome;
  final String Function(int cents) formatPrice;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    StoreOption? selectedStore;
    for (final store in stores) {
      if (store.id == selectedStoreId) {
        selectedStore = store;
        break;
      }
    }

    return Column(
      key: const Key('main-tab-search'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Search', style: textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(
          'Filter by store, category, and keyword to browse live catalog items.',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        StoreSelectorSection(
          stores: stores,
          selectedStoreId: selectedStoreId,
          onStoreSelected: onStoreSelected,
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('customer-search-field'),
          onChanged: onSearchChanged,
          decoration: const InputDecoration(
            hintText: 'Search items, categories, or descriptions',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final category = categories[index];
              return ChoiceChip(
                key: Key('customer-category-$category'),
                selected: category == selectedCategory,
                onSelected: (_) => onCategorySelected(category),
                label: Text(category),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemCount: categories.length,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Store: ${selectedStore?.name ?? 'No store selected'}',
          key: const Key('selected-store-label'),
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        if (visibleItems.isEmpty)
          const SurfaceCard(
            child: Text('No matching items found.'),
          )
        else
          for (final item in visibleItems) ...[
            CatalogItemCard(
              item: item,
              quantityInCart: quantityInCartForItem(item.id),
              onAdd: () => onAddToCart(item),
              formatPrice: formatPrice,
            ),
            const SizedBox(height: 10),
          ],
        const SizedBox(height: 12),
        SurfaceCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Cart summary ($cartItemCount items)'),
            subtitle: Text('Current total ${formatPrice(cartTotal)}'),
            trailing: TextButton(
              onPressed: onGoToHome,
              child: const Text('Go to Home'),
            ),
          ),
        ),
      ],
    );
  }
}
