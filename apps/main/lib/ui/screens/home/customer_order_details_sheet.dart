import 'package:flutter/material.dart';

import '../../widgets/details_sheet_scaffold.dart';
import '../../widgets/meta_info_row.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/surface_card.dart';
import 'customer_home_models.dart';

/// Owns details-sheet UI for a customer order record.
void showCustomerOrderDetailsSheet({
  required BuildContext context,
  required OrderPreview order,
  required Future<List<OrderTimelineEntry>> Function(String orderId)
      loadTimeline,
  required StatusBadgeTone Function(String status) orderStatusTone,
  required String Function(int cents) formatPrice,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      // Load order history only when the sheet is opened so bootstrap stays
      // small and the orders tab can remain responsive.
      return FutureBuilder<List<OrderTimelineEntry>>(
        future: loadTimeline(order.id),
        builder: (context, snapshot) {
          return DetailsSheetScaffold(
            title: 'Order details',
            subtitle: order.id,
            badge: StatusBadge(
              label: order.status,
              tone: orderStatusTone(order.status),
            ),
            sections: [
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.retailerName,
                        style: Theme.of(context).textTheme.titleMedium),
                    if (order.storeName != null) ...[
                      const SizedBox(height: 4),
                      Text('Store: ${order.storeName}'),
                    ],
                  ],
                ),
              ),
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order metrics',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    MetaInfoRow(
                      items: [
                        MetaInfo(
                          icon: Icons.shopping_bag_outlined,
                          text: '${order.itemCount} items',
                        ),
                        MetaInfo(
                          icon: Icons.attach_money_rounded,
                          text: formatPrice(order.totalCents),
                        ),
                        MetaInfo(
                          icon: Icons.schedule_rounded,
                          text: order.etaText,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildTimelineSection(
                context: context,
                snapshot: snapshot,
                orderStatusTone: orderStatusTone,
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
    },
  );
}

Widget _buildTimelineSection({
  required BuildContext context,
  required AsyncSnapshot<List<OrderTimelineEntry>> snapshot,
  required StatusBadgeTone Function(String status) orderStatusTone,
}) {
  final textTheme = Theme.of(context).textTheme;

  return SurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Status timeline', style: textTheme.titleMedium),
        const SizedBox(height: 8),
        if (snapshot.connectionState == ConnectionState.waiting) ...[
          const SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(height: 8),
          const Text(
            'Loading fulfillment timeline...',
            key: Key('order-timeline-loading'),
          ),
        ] else if (snapshot.hasError) ...[
          const Text(
            'Unable to load order timeline right now.',
            key: Key('order-timeline-error'),
          ),
        ] else if ((snapshot.data ?? const <OrderTimelineEntry>[]).isEmpty) ...[
          const Text(
            'No status history has been recorded for this order yet.',
            key: Key('order-timeline-empty'),
          ),
        ] else ...[
          for (final entry in snapshot.data!)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.circle,
                      size: 10,
                      color: _timelineToneColor(
                        context,
                        orderStatusTone(entry.status),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _timelineStatusLabel(entry.status),
                          key: Key('order-timeline-status-${entry.id}'),
                          style: textTheme.titleSmall,
                        ),
                        if (entry.occurredAt != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            _formatTimelineTime(context, entry.occurredAt!),
                            style: textTheme.bodySmall,
                          ),
                        ],
                        if (entry.note != null && entry.note!.trim().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              entry.note!,
                              style: textTheme.bodyMedium,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    ),
  );
}

String _timelineStatusLabel(String status) {
  return status.toLowerCase().split('_').map((segment) {
    if (segment.isEmpty) {
      return segment;
    }

    return '${segment[0].toUpperCase()}${segment.substring(1)}';
  }).join(' ');
}

String _formatTimelineTime(BuildContext context, DateTime value) {
  final local = value.toLocal();
  final localizations = MaterialLocalizations.of(context);
  final date = localizations.formatShortDate(local);
  final time = localizations.formatTimeOfDay(TimeOfDay.fromDateTime(local));
  return '$date at $time';
}

Color _timelineToneColor(BuildContext context, StatusBadgeTone tone) {
  return switch (tone) {
    StatusBadgeTone.info => Theme.of(context).colorScheme.primary,
    StatusBadgeTone.warning => Theme.of(context).colorScheme.tertiary,
    StatusBadgeTone.success => Colors.green.shade700,
    StatusBadgeTone.neutral => Theme.of(context).colorScheme.outline,
  };
}
