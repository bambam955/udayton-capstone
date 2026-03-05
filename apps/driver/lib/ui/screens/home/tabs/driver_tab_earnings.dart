import 'package:flutter/material.dart';

import '../../../widgets/stat_tile.dart';
import '../../../widgets/surface_card.dart';
import '../driver_home_models.dart';

/// Owns Earnings tab UI for the driver shell.
class DriverTabEarnings extends StatelessWidget {
  const DriverTabEarnings({
    super.key,
    required this.payout,
    required this.completedJobs,
    required this.formatMoney,
  });

  final DriverPayoutSummary payout;
  final List<DriverJob> completedJobs;
  final String Function(double value) formatMoney;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      key: const Key('driver-tab-earnings'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Earnings', style: textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(
          'Financial snapshot and payout timeline for this shift.',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Today\'s Earnings', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                formatMoney(payout.todayGross),
                key: const Key('driver-earnings-today-gross'),
                style: textTheme.headlineSmall?.copyWith(
                  fontSize: 34,
                  color: const Color(0xFF0F6F66),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.35,
          children: [
            StatTile(
              icon: Icons.account_balance_wallet_rounded,
              label: 'Today Gross',
              value: formatMoney(payout.todayGross),
            ),
            StatTile(
              key: const Key('driver-earnings-tips'),
              icon: Icons.volunteer_activism_rounded,
              label: 'Tips',
              value: formatMoney(payout.tips),
            ),
            StatTile(
              key: const Key('driver-earnings-bonus'),
              icon: Icons.bolt_rounded,
              label: 'Bonus',
              value: formatMoney(payout.bonus),
            ),
            StatTile(
              key: const Key('driver-earnings-next-payout'),
              icon: Icons.schedule_send_rounded,
              label: 'Next Payout',
              value: payout.nextPayoutText,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Recent completed deliveries', style: textTheme.titleMedium),
        const SizedBox(height: 10),
        if (completedJobs.isEmpty)
          const SurfaceCard(
            child: Text('No completed deliveries yet'),
          )
        else
          for (final job in completedJobs) ...[
            SurfaceCard(
              key: Key('driver-earnings-row-${job.id}'),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${job.pickup} → ${job.dropoff}',
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    formatMoney(job.basePay + job.tipAmount),
                    style: textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}
