import 'package:flutter/material.dart';

class MetaInfo {
  const MetaInfo({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;
}

class MetaInfoRow extends StatelessWidget {
  const MetaInfoRow({
    super.key,
    required this.items,
  });

  final List<MetaInfo> items;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: const Color(0xFF546269),
          fontWeight: FontWeight.w500,
        );

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        for (final item in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon, size: 14, color: const Color(0xFF667780)),
              const SizedBox(width: 4),
              Text(item.text, style: textStyle),
            ],
          ),
      ],
    );
  }
}
