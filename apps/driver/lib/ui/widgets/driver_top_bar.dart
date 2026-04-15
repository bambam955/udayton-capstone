import 'package:flutter/material.dart';

/// Compact top bar shared across the driver's authenticated screens.
class DriverTopBar extends StatelessWidget {
  const DriverTopBar({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isOnline,
    required this.isAvailabilityBusy,
    required this.onAvailabilityChanged,
    required this.onProfileAction,
  });

  final String title;
  final String subtitle;
  final bool isOnline;
  final bool isAvailabilityBusy;
  final ValueChanged<bool> onAvailabilityChanged;
  final ValueChanged<String> onProfileAction;

  @override
  Widget build(BuildContext context) {
    final availabilityIcon = isAvailabilityBusy
        ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Icon(
            isOnline ? Icons.toggle_on_rounded : Icons.toggle_off_outlined,
            size: 18,
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
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
                          key: const Key('driver-status-subtitle'),
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
        const SizedBox(height: 8),
        OutlinedButton.icon(
          key: const Key('driver-availability-toggle'),
          onPressed: isAvailabilityBusy
              ? null
              : () => onAvailabilityChanged(!isOnline),
          icon: availabilityIcon,
          label: Text(isOnline ? 'Go offline' : 'Go online'),
        ),
      ],
    );
  }
}
