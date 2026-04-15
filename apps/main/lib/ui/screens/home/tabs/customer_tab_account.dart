import 'package:flutter/material.dart';

import '../../../widgets/stat_tile.dart';
import '../../../widgets/surface_card.dart';
import '../customer_home_models.dart';

/// Owns Account tab UI for the customer shell.
class CustomerTabAccount extends StatelessWidget {
  const CustomerTabAccount({
    super.key,
    required this.overview,
    required this.onToggleStoreConnection,
    required this.onAddAddress,
    required this.isBusy,
  });

  final CustomerAccountOverview overview;
  final ValueChanged<StoreOption> onToggleStoreConnection;
  final VoidCallback onAddAddress;
  final bool isBusy;

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
          'Business profile, connected stores, and saved delivery addresses.',
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
              value: '${overview.connectedStoreCount}',
            ),
            StatTile(
              icon: Icons.receipt_long_rounded,
              label: 'Tracked orders',
              value: '${overview.trackedOrderCount}',
            ),
          ],
        ),
        const SizedBox(height: 12),
        SurfaceCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(overview.customerName),
            subtitle: Text(overview.customerEmail),
          ),
        ),
        const SizedBox(height: 8),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Stores', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              // Store connection controls live here because connection state is
              // account-level rather than catalog-level.
              for (final store in overview.stores)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(store.name),
                            Text(
                              store.subtitle,
                              style: textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: isBusy
                            ? null
                            : () => onToggleStoreConnection(store),
                        child:
                            Text(store.isConnected ? 'Disconnect' : 'Connect'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Delivery addresses',
                        style: textTheme.titleMedium),
                  ),
                  TextButton(
                    onPressed: isBusy ? null : onAddAddress,
                    child: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (overview.addresses.isEmpty)
                const Text('No saved addresses yet.')
              else
                // Addresses are rendered as plain summaries because creation
                // and selection happen elsewhere in the shell.
                for (final address in overview.addresses)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '${address.isDefault ? 'Default • ' : ''}${address.label}: ${address.addressLine}',
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}
