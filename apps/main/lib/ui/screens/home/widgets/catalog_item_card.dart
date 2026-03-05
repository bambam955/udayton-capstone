import 'package:flutter/material.dart';

import '../../../widgets/meta_info_row.dart';
import '../../../widgets/surface_card.dart';
import '../customer_home_models.dart';

/// Owns reusable catalog item card for customer home/search tabs.
class CatalogItemCard extends StatelessWidget {
  const CatalogItemCard({
    super.key,
    required this.item,
    required this.quantityInCart,
    required this.onAdd,
    required this.formatPrice,
  });

  final CatalogItem item;
  final int quantityInCart;
  final VoidCallback onAdd;
  final String Function(double value) formatPrice;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SurfaceCard(
      key: Key('catalog-item-${item.id}'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                colors: item.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('${item.category} • ${item.unit}',
                    style: textTheme.bodySmall),
                const SizedBox(height: 8),
                MetaInfoRow(
                  items: [
                    MetaInfo(icon: Icons.sell_outlined, text: item.badgeText),
                    MetaInfo(
                      icon: Icons.attach_money_rounded,
                      text: formatPrice(item.price),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FilledButton(
                key: Key('add-to-cart-${item.id}'),
                onPressed: onAdd,
                child: const Text('Add'),
              ),
              const SizedBox(height: 6),
              Text(
                quantityInCart > 0 ? 'In cart: $quantityInCart' : 'In cart: 0',
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
