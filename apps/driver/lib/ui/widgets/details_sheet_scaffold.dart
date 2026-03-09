import 'package:flutter/material.dart';

class DetailsSheetScaffold extends StatelessWidget {
  const DetailsSheetScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.badge,
    required this.sections,
    required this.onClose,
    this.footer,
  });

  final String title;
  final String? subtitle;
  final Widget? badge;
  final List<Widget> sections;
  final VoidCallback onClose;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      top: false,
      child: FractionallySizedBox(
        heightFactor: 0.86,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Material(
            color: Colors.white,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          key: const Key('details-sheet-title'),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: textTheme.titleLarge),
                            if (subtitle != null) ...[
                              const SizedBox(height: 4),
                              Text(subtitle!, style: textTheme.bodyMedium),
                            ],
                          ],
                        ),
                      ),
                      if (badge != null) ...[const SizedBox(width: 8), badge!],
                      const SizedBox(width: 4),
                      IconButton(
                        key: const Key('details-sheet-close'),
                        onPressed: onClose,
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    key: const Key('details-sheet-body'),
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    children: [
                      for (final section in sections) ...[
                        section,
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
                ),
                if (footer != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: footer,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
