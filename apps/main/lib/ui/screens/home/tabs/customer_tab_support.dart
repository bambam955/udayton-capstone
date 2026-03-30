import 'package:flutter/material.dart';

import '../../../widgets/status_badge.dart';
import '../../../widgets/surface_card.dart';
import '../customer_home_models.dart';

/// Owns Support tab UI for the customer shell.
class CustomerTabSupport extends StatelessWidget {
  const CustomerTabSupport({
    super.key,
    required this.supportTickets,
    required this.supportStatusTone,
    required this.onCreateTicket,
    required this.isSubmitting,
  });

  final List<SupportTicket> supportTickets;
  final StatusBadgeTone Function(String status) supportStatusTone;
  final ValueChanged<String> onCreateTicket;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      key: const Key('main-tab-support'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Support', style: textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text('Quick help actions and active tickets.',
            style: textTheme.bodyMedium),
        const SizedBox(height: 12),
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              OutlinedButton(
                onPressed:
                    isSubmitting ? null : () => onCreateTicket('MISSING_ITEM'),
                style: OutlinedButton.styleFrom(shape: const StadiumBorder()),
                child: const Text('Missing item'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed:
                    isSubmitting ? null : () => onCreateTicket('LATE_DELIVERY'),
                style: OutlinedButton.styleFrom(shape: const StadiumBorder()),
                child: const Text('Late delivery'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed:
                    isSubmitting ? null : () => onCreateTicket('DAMAGED_ITEM'),
                style: OutlinedButton.styleFrom(shape: const StadiumBorder()),
                child: const Text('Damaged item'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (supportTickets.isEmpty)
          const SurfaceCard(
            child: Text('No active support tickets.'),
          ),
        for (final ticket in supportTickets) ...[
          SurfaceCard(
            key: Key('support-ticket-${ticket.id}'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(ticket.title, style: textTheme.titleMedium),
                    ),
                    StatusBadge(
                      label: ticket.status.toUpperCase(),
                      tone: supportStatusTone(ticket.status),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(ticket.summary),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
