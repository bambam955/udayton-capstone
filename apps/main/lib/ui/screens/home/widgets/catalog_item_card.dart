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
  final String Function(int cents) formatPrice;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SurfaceCard(
      key: Key('catalog-item-${item.id}'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            // The branch removed fake image assets from this flow, so use a
            // generated gradient block to keep catalog cards visually distinct.
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
                Text(item.category, style: textTheme.bodySmall),
                if (item.description != null &&
                    item.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 8),
                MetaInfoRow(
                  items: [
                    MetaInfo(icon: Icons.sell_outlined, text: item.badgeText),
                    MetaInfo(
                      icon: Icons.attach_money_rounded,
                      text: formatPrice(item.unitPriceCents),
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
                // Availability is enforced server-side too, but disabling the
                // button makes the current product state obvious immediately.
                onPressed: item.isAvailable ? onAdd : null,
                child: Text(item.isAvailable ? 'Add' : 'Unavailable'),
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
