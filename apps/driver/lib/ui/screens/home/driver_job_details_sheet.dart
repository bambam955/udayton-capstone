import 'package:flutter/material.dart';

import '../../widgets/details_sheet_scaffold.dart';
import '../../widgets/meta_info_row.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/surface_card.dart';
import 'driver_home_models.dart';

/// Owns details-sheet UI for a driver delivery record.
Future<void> showDriverJobDetailsSheet({
  required BuildContext context,
  required DriverJob job,
  required String stageLabel,
  required StatusBadgeTone stageTone,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return DetailsSheetScaffold(
        title: 'Delivery details',
        subtitle: job.title,
        badge: StatusBadge(
          label: stageLabel,
          tone: stageTone,
        ),
        sections: [
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Route summary',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('${job.pickup} → ${job.dropoff}'),
              ],
            ),
          ),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Trip metrics',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                MetaInfoRow(
                  items: [
                    MetaInfo(
                      icon: Icons.attach_money_rounded,
                      text: job.payEstimateText,
                    ),
                    MetaInfo(
                      icon: Icons.route_rounded,
                      text: job.distanceText,
                    ),
                    MetaInfo(
                      icon: Icons.schedule_rounded,
                      text: job.etaText,
                    ),
                    MetaInfo(
                      icon: Icons.place_rounded,
                      text: job.zone,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Detail notes',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final line in job.detailLines)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('• $line'),
                  ),
              ],
            ),
          ),
        ],
        onClose: () => Navigator.of(context).pop(),
        footer: SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ),
      );
    },
  );
}
