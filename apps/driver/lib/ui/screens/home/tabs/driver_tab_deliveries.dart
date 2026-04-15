import 'package:flutter/material.dart';

import '../../../widgets/meta_info_row.dart';
import '../../../widgets/status_badge.dart';
import '../../../widgets/surface_card.dart';
import '../driver_home_models.dart';

/// Owns Deliveries tab UI for the driver shell.
class DriverTabDeliveries extends StatelessWidget {
  const DriverTabDeliveries({
    super.key,
    required this.filterIndex,
    required this.activeJobs,
    required this.completedJobs,
    required this.stageLabel,
    required this.stageTone,
    required this.onFilterChanged,
    required this.onConfirmPickup,
    required this.onCompleteDelivery,
    required this.onOpenMap,
    required this.onViewDetails,
    required this.isBusy,
  });

  final int filterIndex;
  final List<DriverJob> activeJobs;
  final List<DriverJob> completedJobs;
  final String Function(DeliveryStage stage) stageLabel;
  final StatusBadgeTone Function(DeliveryStage stage) stageTone;
  final ValueChanged<int> onFilterChanged;
  final ValueChanged<String> onConfirmPickup;
  final ValueChanged<String> onCompleteDelivery;
  final ValueChanged<String> onOpenMap;
  final ValueChanged<DriverJob> onViewDetails;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final showingCompleted = filterIndex == 1;
    // The shell pre-splits active and completed jobs, so the tab only needs a
    // lightweight UI filter toggle.
    final jobs = showingCompleted ? completedJobs : activeJobs;

    return Column(
      key: const Key('driver-tab-deliveries'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Deliveries', style: textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(
          'Track assigned routes and complete delivery steps.',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              key: const Key('driver-deliveries-filter-Active'),
              label: const Text('Active'),
              selected: !showingCompleted,
              onSelected: (_) => onFilterChanged(0),
            ),
            ChoiceChip(
              key: const Key('driver-deliveries-filter-Completed'),
              label: const Text('Completed'),
              selected: showingCompleted,
              onSelected: (_) => onFilterChanged(1),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (jobs.isEmpty)
          SurfaceCard(
            child: Text(
              showingCompleted
                  ? 'No completed deliveries yet.'
                  : 'No active deliveries right now.',
            ),
          )
        else
          for (final job in jobs) ...[
            _DeliveryCard(
              key: Key('driver-delivery-card-${job.id}'),
              job: job,
              stageLabel: stageLabel(job.stage),
              stageTone: stageTone(job.stage),
              onConfirmPickup: () => onConfirmPickup(job.id),
              onCompleteDelivery: () => onCompleteDelivery(job.id),
              onOpenMap: () => onOpenMap(job.id),
              onViewDetails: () => onViewDetails(job),
              isBusy: isBusy,
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard({
    super.key,
    required this.job,
    required this.stageLabel,
    required this.stageTone,
    required this.onConfirmPickup,
    required this.onCompleteDelivery,
    required this.onOpenMap,
    required this.onViewDetails,
    required this.isBusy,
  });

  final DriverJob job;
  final String stageLabel;
  final StatusBadgeTone stageTone;
  final VoidCallback onConfirmPickup;
  final VoidCallback onCompleteDelivery;
  final VoidCallback onOpenMap;
  final VoidCallback onViewDetails;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final primaryAction = switch (job.stage) {
      DeliveryStage.assigned => (
          label: 'Confirm pickup',
          key: Key('driver-confirm-pickup-${job.id}'),
          onPressed: onConfirmPickup,
        ),
      DeliveryStage.outForDelivery => (
          label: 'Complete delivery',
          key: Key('driver-complete-delivery-${job.id}'),
          onPressed: onCompleteDelivery,
        ),
      _ => null,
    };

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(job.title, style: textTheme.titleMedium)),
              StatusBadge(label: stageLabel, tone: stageTone),
            ],
          ),
          const SizedBox(height: 6),
          Text('${job.pickup} → ${job.dropoff}', style: textTheme.bodySmall),
          const SizedBox(height: 10),
          MetaInfoRow(
            items: [
              MetaInfo(
                icon: Icons.attach_money_rounded,
                text: job.payEstimateText,
              ),
              MetaInfo(icon: Icons.route_rounded, text: job.distanceText),
              MetaInfo(icon: Icons.schedule_rounded, text: job.etaText),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // The primary action changes with delivery stage so the tab can
              // advance the workflow without exposing invalid actions.
              if (primaryAction != null)
                OutlinedButton(
                  key: primaryAction.key,
                  onPressed: isBusy ? null : primaryAction.onPressed,
                  child: Text(primaryAction.label),
                ),
              if (job.stage == DeliveryStage.assigned ||
                  job.stage == DeliveryStage.outForDelivery)
                OutlinedButton(
                  key: Key('driver-open-map-${job.id}'),
                  onPressed: onOpenMap,
                  child: const Text('Open map'),
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
    );
  }
}
