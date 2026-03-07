import 'package:flutter/material.dart';

class DriverTopBar extends StatelessWidget {
  const DriverTopBar({
    super.key,
    required this.onProfileAction,
  });

  final ValueChanged<String> onProfileAction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          Expanded(
            child: Image.asset(
              'assets/images/bizrushdriverlogo.png',
              key: const Key('driver-logo'),
              height: 34,
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
              errorBuilder: (_, __, ___) => const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'BizRush Driver',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          PopupMenuButton<String>(
            key: const Key('driver-profile-menu'),
            onSelected: onProfileAction,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'view_profile',
                child: Text('View profile'),
              ),
              PopupMenuItem(
                value: 'switch_role',
                child: Text('Switch role'),
              ),
              PopupMenuItem(
                value: 'sign_out',
                child: Text('Sign out'),
              ),
            ],
            icon: const Icon(Icons.person_outline_rounded),
          ),
        ],
      ),
    );
  }
}
