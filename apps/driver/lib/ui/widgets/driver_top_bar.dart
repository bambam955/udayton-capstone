import 'package:flutter/material.dart';

/// Compact top bar shared across the driver's authenticated screens.
class DriverTopBar extends StatelessWidget {
  const DriverTopBar({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onProfileAction,
  });

  final String title;
  final String subtitle;
  final ValueChanged<String> onProfileAction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Image.asset(
                  'assets/images/bizrushdriverlogo.png',
                  key: const Key('driver-logo'),
                  height: 34,
                  fit: BoxFit.contain,
                  alignment: Alignment.centerLeft,
                  errorBuilder: (_, __, ___) => const Text(
                    // Fall back to text branding when the asset is unavailable
                    // in tests or partial builds.
                    'BizRush Driver',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            key: const Key('driver-profile-menu'),
            onSelected: onProfileAction,
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'sign_out', child: Text('Sign out')),
            ],
            icon: const Icon(Icons.person_outline_rounded),
          ),
        ],
      ),
    );
  }
}
