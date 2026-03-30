import 'package:flutter/material.dart';

import '../../../widgets/surface_card.dart';
import '../customer_home_models.dart';

/// Owns reusable store-selector UI for customer home/search tabs.
class StoreSelectorSection extends StatelessWidget {
  const StoreSelectorSection({
    super.key,
    required this.stores,
    required this.selectedStoreId,
    required this.onStoreSelected,
  });

  final List<StoreOption> stores;
  final String? selectedStoreId;
  final ValueChanged<String> onStoreSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Choose a store', style: textTheme.titleMedium),
        const SizedBox(height: 8),
        if (stores.isEmpty)
          const SurfaceCard(
            child: Text('No partnered stores are available yet.'),
          )
        else
          SizedBox(
            height: 148,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final store = stores[index];
                final selected = store.id == selectedStoreId;
                return SizedBox(
                  width: 220,
                  child: SurfaceCard(
                    key: Key('store-${store.id}'),
                    onTap: () => onStoreSelected(store.id),
                    color: selected ? const Color(0xFFE7F4F2) : null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store.name,
                          style: textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          store.subtitle,
                          style: textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(store.etaText, style: textTheme.bodySmall),
                        const SizedBox(height: 4),
                        Text(
                          '${store.isConnected ? 'Connected' : 'Connect in Account'} • ★ ${store.ratingText}',
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemCount: stores.length,
            ),
          ),
      ],
    );
  }
}
