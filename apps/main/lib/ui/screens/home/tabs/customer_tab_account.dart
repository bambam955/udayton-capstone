import 'package:flutter/material.dart';

import '../../../widgets/stat_tile.dart';
import '../../../widgets/surface_card.dart';
import '../customer_home_models.dart';

/// Owns Account tab UI for the customer shell.
class CustomerTabAccount extends StatelessWidget {
  const CustomerTabAccount({
    super.key,
    required this.stores,
    required this.orders,
  });

  final List<StoreOption> stores;
  final List<OrderPreview> orders;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      key: const Key('main-tab-account'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Account', style: textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(
          'Business profile, payment setup, and connected stores.',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.45,
          children: [
            StatTile(
              icon: Icons.storefront_rounded,
              label: 'Stores linked',
              value: '${stores.length}',
            ),
            StatTile(
              icon: Icons.receipt_long_rounded,
              label: 'Tracked orders',
              value: '${orders.length}',
            ),
          ],
        ),
        const SizedBox(height: 12),
        const SurfaceCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Northside Deli'),
            subtitle: Text('owner@northsidedeli.co • Profile completeness 92%'),
          ),
        ),
        const SizedBox(height: 8),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Connected stores', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              for (final store in stores)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('• ${store.name} (${store.ratingText})'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const SurfaceCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Payment methods'),
            subtitle: Text('Visa •••• 2481, Business ACH ****9012'),
          ),
        ),
      ],
    );
  }
}
