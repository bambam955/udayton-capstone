import 'package:flutter/material.dart';

import '../../../widgets/meta_info_row.dart';
import '../../../widgets/status_badge.dart';
import '../../../widgets/surface_card.dart';
import '../customer_home_models.dart';

/// Owns Orders tab UI for the customer shell.
class CustomerTabOrders extends StatelessWidget {
  const CustomerTabOrders({
    super.key,
    required this.orders,
    required this.formatPrice,
    required this.orderStatusTone,
    required this.onViewOrder,
  });

  final List<OrderPreview> orders;
  final String Function(double value) formatPrice;
  final StatusBadgeTone Function(String status) orderStatusTone;
  final ValueChanged<OrderPreview> onViewOrder;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      key: const Key('main-tab-orders'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Orders', style: textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(
          'Track order progress and handoff status.',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        for (final order in orders) ...[
          SurfaceCard(
            key: Key('order-card-${order.id}'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(order.id, style: textTheme.titleMedium),
                    ),
                    StatusBadge(
                      label: order.status,
                      tone: orderStatusTone(order.status),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(order.businessName, style: textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(order.storeName, style: textTheme.bodySmall),
                const SizedBox(height: 10),
                MetaInfoRow(
                  items: [
                    MetaInfo(
                      icon: Icons.shopping_bag_outlined,
                      text: '${order.itemCount} items',
                    ),
                    MetaInfo(
                      icon: Icons.attach_money_rounded,
                      text: formatPrice(order.total),
                    ),
                    MetaInfo(
                      icon: Icons.schedule_rounded,
                      text: order.etaText,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  key: Key('order-view-${order.id}'),
                  onPressed: () => onViewOrder(order),
                  child: const Text('View details'),
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
