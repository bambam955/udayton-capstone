import 'package:flutter/material.dart';

enum StatusBadgeTone { assigned, outForDelivery, completed, neutral }

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, required this.tone});

  final String label;
  final StatusBadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (tone) {
      StatusBadgeTone.assigned => (
          const Color(0xFFE7F0FF),
          const Color(0xFF1F5FBF),
        ),
      StatusBadgeTone.outForDelivery => (
          const Color(0xFFFFF0E3),
          const Color(0xFFB65A0A),
        ),
      StatusBadgeTone.completed => (
          const Color(0xFFE6F6EB),
          const Color(0xFF1B7F39),
        ),
      StatusBadgeTone.neutral => (
          const Color(0xFFF1F3F5),
          const Color(0xFF4A5560),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
