import 'package:flutter/material.dart';

import '../../../widgets/meta_info_row.dart';
import '../../../widgets/stat_tile.dart';
import '../../../widgets/surface_card.dart';
import '../driver_home_models.dart';

/// Owns Home tab UI for the driver shell.
class DriverTabHome extends StatelessWidget {
  const DriverTabHome({
    super.key,
    required this.availableJobs,
    required this.activeJobs,
    required this.completedJobs,
    required this.payout,
    required this.onGoToDeliveries,
    required this.onGoToNearby,
    required this.formatMoney,
  });

  final List<DriverJob> availableJobs;
  final List<DriverJob> activeJobs;
  final List<DriverJob> completedJobs;
  final DriverPayoutSummary payout;
  final VoidCallback onGoToDeliveries;
  final VoidCallback onGoToNearby;
  final String Function(double value) formatMoney;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final currentActive = activeJobs.isNotEmpty ? activeJobs.first : null;
    final firstOffer = availableJobs.isNotEmpty ? availableJobs.first : null;
    final focusJob = currentActive ?? firstOffer;

    return Column(
      key: const Key('driver-tab-home'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Driver Dashboard', style: textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(
          'command center for your current shift.',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current Focus', style: textTheme.titleMedium),
              const SizedBox(height: 10),
              if (focusJob == null)
                Text(
                  'No active routes right now. Check nearby offers to start.',
                  style: textTheme.bodyMedium,
                )
              else ...[
                Text(
                  focusJob.title,
                  style: textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  '${focusJob.pickup} → ${focusJob.dropoff}',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 10),
                MetaInfoRow(
                  items: [
                    MetaInfo(
                      icon: Icons.attach_money_rounded,
                      text: focusJob.payEstimateText,
                    ),
                    MetaInfo(
                      icon: Icons.route_rounded,
                      text: focusJob.distanceText,
                    ),
                    MetaInfo(
                      icon: Icons.schedule_rounded,
                      text: focusJob.etaText,
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton(
                    key: const Key('driver-home-go-deliveries'),
                    onPressed: onGoToDeliveries,
                    child: const Text('Go to Deliveries'),
                  ),
                  OutlinedButton(
                    key: const Key('driver-home-go-nearby'),
                    onPressed: onGoToNearby,
                    child: const Text('Go to Nearby'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.35,
          children: [
            StatTile(
              key: const Key('driver-metric-available'),
              icon: Icons.local_fire_department_rounded,
              label: 'Available Offers',
              value: '${availableJobs.length}',
            ),
            StatTile(
              key: const Key('driver-metric-active'),
              icon: Icons.local_shipping_rounded,
              label: 'Active Deliveries',
              value: '${activeJobs.length}',
            ),
            StatTile(
              key: const Key('driver-metric-completed'),
              icon: Icons.check_circle_outline_rounded,
              label: 'Completed Today',
              value: '${completedJobs.length}',
            ),
            StatTile(
              key: const Key('driver-metric-earnings'),
              icon: Icons.payments_rounded,
              label: 'Estimated Earnings',
              value: formatMoney(payout.todayGross),
            ),
          ],
        ),
      ],
    );
  }
}
