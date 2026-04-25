import 'package:flutter/material.dart';

import '../../widgets/details_sheet_scaffold.dart';
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
  required bool canCancel,
  required bool isBusy,
  required Future<bool> Function() onCancel,
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
      return _CustomerOrderDetailsSheet(
        order: order,
        loadTimeline: loadTimeline,
        orderStatusTone: orderStatusTone,
        formatPrice: formatPrice,
        canCancel: canCancel,
        isBusy: isBusy,
        onCancel: onCancel,
      );
    },
  );
}

class _CustomerOrderDetailsSheet extends StatefulWidget {
  const _CustomerOrderDetailsSheet({
    required this.order,
    required this.loadTimeline,
    required this.orderStatusTone,
    required this.formatPrice,
    required this.canCancel,
    required this.isBusy,
    required this.onCancel,
  });

  final OrderPreview order;
  final Future<List<OrderTimelineEntry>> Function(String orderId) loadTimeline;
  final StatusBadgeTone Function(String status) orderStatusTone;
  final String Function(int cents) formatPrice;
  final bool canCancel;
  final bool isBusy;
  final Future<bool> Function() onCancel;

  @override
  State<_CustomerOrderDetailsSheet> createState() =>
      _CustomerOrderDetailsSheetState();
}

class _CustomerOrderDetailsSheetState
    extends State<_CustomerOrderDetailsSheet> {
  late final Future<List<OrderTimelineEntry>> _timelineFuture;
  late bool _isBusy;

  @override
  void initState() {
    super.initState();
    // Load order history only when the sheet is opened so bootstrap stays
    // small and the orders tab can remain responsive.
    _timelineFuture = widget.loadTimeline(widget.order.id);
    _isBusy = widget.isBusy;
  }

  Future<void> _handleCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel order?'),
        content: const Text(
          'You can only cancel before a driver accepts the delivery.',
        ),
        actions: [
          TextButton(
            key: const Key('order-cancel-dismiss'),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep order'),
          ),
          FilledButton(
            key: const Key('order-cancel-confirm'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cancel order'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }

    setState(() {
      _isBusy = true;
    });

    final shouldClose = await widget.onCancel();
    if (!mounted) {
      return;
    }

    if (shouldClose) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _isBusy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<OrderTimelineEntry>>(
      future: _timelineFuture,
      builder: (context, snapshot) {
        return DetailsSheetScaffold(
          title: 'Order details',
          subtitle: widget.order.id,
          badge: StatusBadge(
            label: widget.order.status,
            tone: widget.orderStatusTone(widget.order.status),
          ),
          sections: [
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.order.retailerName,
                      style: Theme.of(context).textTheme.titleMedium),
                  if (widget.order.storeName != null) ...[
                    const SizedBox(height: 4),
                    Text('Store: ${widget.order.storeName}'),
                  ],
                ],
              ),
            ),
            SurfaceCard(
              key: const Key('order-receipt-section'),
              child: _buildReceiptSection(
                context: context,
                order: widget.order,
                formatPrice: widget.formatPrice,
              ),
            ),
            _buildTimelineSection(
              context: context,
              snapshot: snapshot,
              orderStatusTone: widget.orderStatusTone,
            ),
          ],
          onClose: () => Navigator.of(context).pop(),
          footer: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isBusy ? null : () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
              if (widget.canCancel) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    key: const Key('order-cancel-action'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFB3261E),
                    ),
                    onPressed: _isBusy ? null : _handleCancel,
                    child: _isBusy
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Cancel order'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

Widget _buildReceiptSection({
  required BuildContext context,
  required OrderPreview order,
  required String Function(int cents) formatPrice,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Receipt', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 10),
      _ReceiptRow(
        label: 'Items',
        value: '${order.itemCount} items',
        valueKey: const Key('order-receipt-items'),
      ),
      const SizedBox(height: 8),
      _ReceiptRow(
        label: 'Order total',
        value: formatPrice(order.totalCents),
        valueKey: const Key('order-receipt-total'),
      ),
      const SizedBox(height: 8),
      _ReceiptRow(
        label: 'Status',
        value: order.status,
        valueKey: const Key('order-receipt-status'),
      ),
      if (order.storeName != null) ...[
        const SizedBox(height: 8),
        _ReceiptRow(label: 'Store', value: order.storeName!),
      ],
    ],
  );
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
    required this.label,
    required this.value,
    this.valueKey,
  });

  final String label;
  final String value;
  final Key? valueKey;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF546269),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            key: valueKey,
            textAlign: TextAlign.end,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
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
          // The timeline rows are already sorted by the caller, so rendering can
          // stay a straightforward chronological list.
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

// Convert enum-like backend status codes into a title-cased UI label.
String _timelineStatusLabel(String status) {
  return status.toLowerCase().split('_').map((segment) {
    if (segment.isEmpty) {
      return segment;
    }

    return '${segment[0].toUpperCase()}${segment.substring(1)}';
  }).join(' ');
}

// Use Material localizations so the bottom sheet follows the device locale
// without adding a separate date-formatting dependency.
String _formatTimelineTime(BuildContext context, DateTime value) {
  final local = value.toLocal();
  final localizations = MaterialLocalizations.of(context);
  final date = localizations.formatShortDate(local);
  final time = localizations.formatTimeOfDay(TimeOfDay.fromDateTime(local));
  return '$date at $time';
}

// Reuse the same badge tone mapping colors so the detail sheet visually matches
// the rest of the order UI.
Color _timelineToneColor(BuildContext context, StatusBadgeTone tone) {
  return switch (tone) {
    StatusBadgeTone.info => Theme.of(context).colorScheme.primary,
    StatusBadgeTone.warning => Theme.of(context).colorScheme.tertiary,
    StatusBadgeTone.success => Colors.green.shade700,
    StatusBadgeTone.neutral => Theme.of(context).colorScheme.outline,
  };
}
