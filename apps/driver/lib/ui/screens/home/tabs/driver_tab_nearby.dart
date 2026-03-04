import 'package:flutter/material.dart';

import '../../../widgets/meta_info_row.dart';
import '../../../widgets/surface_card.dart';
import '../driver_home_models.dart';

/// Owns Nearby tab UI for the driver shell.
class DriverTabNearby extends StatelessWidget {
  const DriverTabNearby({
    super.key,
    required this.availableJobs,
    required this.onSearchChanged,
    required this.onAccept,
    required this.onViewDetails,
  });

  final List<DriverJob> availableJobs;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onAccept;
  final ValueChanged<DriverJob> onViewDetails;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      key: const Key('driver-tab-nearby'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nearby Offers', style: textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(
          'Find the best nearby route and tap to accept.',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('driver-nearby-search-field'),
          onChanged: onSearchChanged,
          decoration: const InputDecoration(
            hintText: 'Search by zone, pickup, or drop-off',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(height: 14),
        if (availableJobs.isEmpty)
          const SurfaceCard(
            child: Text('No available demo offers'),
          )
        else
          for (final job in availableJobs) ...[
            _OfferCard(
              key: Key('driver-nearby-card-${job.id}'),
              job: job,
              onAccept: () => onAccept(job.id),
              onViewDetails: () => onViewDetails(job),
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({
    super.key,
    required this.job,
    required this.onAccept,
    required this.onViewDetails,
  });

  final DriverJob job;
  final VoidCallback onAccept;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SurfaceCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                colors: job.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.local_shipping_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(job.title, style: textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('${job.pickup} → ${job.dropoff}',
                    style: textTheme.bodySmall),
                const SizedBox(height: 10),
                MetaInfoRow(
                  items: [
                    MetaInfo(
                      icon: Icons.attach_money_rounded,
                      text: job.payEstimateText,
                    ),
                    MetaInfo(
                      icon: Icons.straighten_rounded,
                      text: job.distanceText,
                    ),
                    MetaInfo(
                      icon: Icons.schedule_rounded,
                      text: job.etaText,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton(
                      key: Key('driver-accept-${job.id}'),
                      onPressed: onAccept,
                      child: const Text('Accept'),
                    ),
                    OutlinedButton(
                      key: Key('driver-view-details-${job.id}'),
                      onPressed: onViewDetails,
                      child: const Text('View details'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
