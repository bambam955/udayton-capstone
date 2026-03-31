import 'package:flutter/material.dart';

import '../../../widgets/status_badge.dart';
import '../../../widgets/surface_card.dart';
import '../driver_home_models.dart';

/// Owns Support tab UI for the driver shell.
class DriverTabSupport extends StatelessWidget {
  const DriverTabSupport({
    super.key,
    required this.supportCases,
    required this.onCreateTicket,
    required this.isSubmitting,
  });

  final List<DriverSupportCase> supportCases;
  final ValueChanged<String> onCreateTicket;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      key: const Key('driver-tab-support'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Support', style: textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(
          'Quick issue actions and your active ticket queue.',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Match the quick action issue codes expected by the support
              // resource rows created from the shell.
              OutlinedButton(
                key: const Key('driver-support-quick-pickup'),
                onPressed:
                    isSubmitting ? null : () => onCreateTicket('PICKUP_ISSUE'),
                style: OutlinedButton.styleFrom(shape: const StadiumBorder()),
                child: const Text('Pickup Issue'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                key: const Key('driver-support-quick-delivery'),
                onPressed: isSubmitting
                    ? null
                    : () => onCreateTicket('DELIVERY_ISSUE'),
                style: OutlinedButton.styleFrom(shape: const StadiumBorder()),
                child: const Text('Delivery Issue'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                key: const Key('driver-support-quick-payment'),
                onPressed: isSubmitting
                    ? null
                    : () => onCreateTicket('PAYMENT_QUESTION'),
                style: OutlinedButton.styleFrom(shape: const StadiumBorder()),
                child: const Text('Payment Question'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (supportCases.isEmpty)
          const SurfaceCard(
            child: Text('No active support tickets.'),
          ),
        for (final supportCase in supportCases) ...[
          SurfaceCard(
            key: Key('driver-support-case-${supportCase.id}'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        supportCase.title,
                        style: textTheme.titleMedium,
                      ),
                    ),
                    StatusBadge(
                      label: supportCase.status.toUpperCase(),
                      tone: _supportStatusTone(supportCase.status),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(supportCase.summary, style: textTheme.bodyMedium),
                if (supportCase.linkedDeliveryId != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Linked: ${supportCase.linkedDeliveryId}',
                    style: textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  StatusBadgeTone _supportStatusTone(String status) {
    final normalized = status.toLowerCase();
    if (normalized.contains('open')) {
      return StatusBadgeTone.outForDelivery;
    }
    if (normalized.contains('review')) {
      return StatusBadgeTone.assigned;
    }
    // Treat any other state as completed/closed to keep the badge mapping
    // stable even if the backend introduces more specific resolved values.
    return StatusBadgeTone.completed;
  }
}
