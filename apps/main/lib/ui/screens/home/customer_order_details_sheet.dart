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
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status timeline',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                const Text('• Order submitted'),
                const SizedBox(height: 4),
                const Text(
                    '• Backend status history is available through the API'),
                const SizedBox(height: 4),
                Text('• Current: ${order.status}'),
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
