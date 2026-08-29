import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth.dart';
import '../core/theme.dart';

class Sidebar extends StatelessWidget {
  final AuthUser user;
  final VoidCallback? onClose;

  const Sidebar({
    super.key,
    required this.user,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final items = _navigationItems(user);

    final currentLocation =
        GoRouterState.of(context).uri.path;

    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            _buildBrand(),

            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                children: [
                  for (final item in items)
                    _NavigationItem(
                      item: item,
                      selected: _isSelected(
                        currentLocation,
                        item.route,
                      ),
                      onTap: () {
                        onClose?.call();
                        context.go(item.route);
                      },
                    ),
                ],
              ),
            ),

            const Divider(height: 1),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _NavigationItem(
                    item: const NavigationItem(
                      label: 'Support',
                      route: '/support',
                      icon: Icons.help_outline,
                    ),
                    selected: currentLocation == '/support',
                    onTap: () {
                      onClose?.call();
                      context.go('/support');
                    },
                  ),
                  _NavigationItem(
                    item: const NavigationItem(
                      label: 'Sign out',
                      route: '',
                      icon: Icons.logout,
                    ),
                    selected: false,
                    danger: true,
                    onTap: () {
                      _showLogoutDialog(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrand() {
    final roleName = switch (user.role) {
      'saas_admin' => 'SaaS Administrator',
      'gym_admin' => 'Gym Administrator',
      'staff' => 'Staff',
      _ => 'GymFlow Pro',
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        16,
        0,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Text(
              'G',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'GymFlow Pro',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  roleName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<NavigationItem> _navigationItems(
      AuthUser user,
      ) {
    if (user.isSaasAdmin) {
      return const [
        NavigationItem(
          label: 'Dashboard',
          route: '/dashboard',
          icon: Icons.dashboard_outlined,
        ),
        NavigationItem(
          label: 'Gyms',
          route: '/gyms',
          icon: Icons.business_outlined,
        ),
        NavigationItem(
          label: 'SaaS Plans',
          route: '/saas-plans',
          icon: Icons.layers_outlined,
        ),
        NavigationItem(
          label: 'Gym Subscriptions',
          route: '/gym-subscriptions',
          icon: Icons.card_membership_outlined,
        ),
        NavigationItem(
          label: 'Settings',
          route: '/settings',
          icon: Icons.settings_outlined,
        ),
      ];
    }

    if (user.isStaff) {
      return const [
        NavigationItem(
          label: 'Dashboard',
          route: '/dashboard',
          icon: Icons.dashboard_outlined,
        ),
        NavigationItem(
          label: 'Members',
          route: '/members',
          icon: Icons.people_outline,
        ),
        NavigationItem(
          label: 'Subscriptions',
          route: '/subscriptions',
          icon: Icons.card_membership_outlined,
        ),
        NavigationItem(
          label: 'Payments',
          route: '/payments',
          icon: Icons.payments_outlined,
        ),
        NavigationItem(
          label: 'Attendance',
          route: '/attendance',
          icon: Icons.fact_check_outlined,
        ),
        NavigationItem(
          label: 'Measurements',
          route: '/measurements',
          icon: Icons.monitor_weight_outlined,
        ),
      ];
    }

    return const [
      NavigationItem(
        label: 'Dashboard',
        route: '/dashboard',
        icon: Icons.dashboard_outlined,
      ),
      NavigationItem(
        label: 'Staff',
        route: '/staff',
        icon: Icons.badge_outlined,
      ),
      NavigationItem(
        label: 'Members',
        route: '/members',
        icon: Icons.people_outline,
      ),
      NavigationItem(
        label: 'Plans',
        route: '/plans',
        icon: Icons.layers_outlined,
      ),
      NavigationItem(
        label: 'Subscriptions',
        route: '/subscriptions',
        icon: Icons.card_membership_outlined,
      ),
      NavigationItem(
        label: 'Payments',
        route: '/payments',
        icon: Icons.payments_outlined,
      ),
      NavigationItem(
        label: 'Attendance',
        route: '/attendance',
        icon: Icons.fact_check_outlined,
      ),
      NavigationItem(
        label: 'Measurements',
        route: '/measurements',
        icon: Icons.monitor_weight_outlined,
      ),
      NavigationItem(
        label: 'Gym Settings',
        route: '/settings',
        icon: Icons.settings_outlined,
      ),
    ];
  }

  bool _isSelected(
      String current,
      String route,
      ) {
    if (route == '/dashboard') {
      return current == '/dashboard';
    }

    return current == route ||
        current.startsWith('$route/');
  }

  Future<void> _showLogoutDialog(
      BuildContext context,
      ) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sign out'),
          content: const Text(
            'Are you sure you want to sign out?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Sign out'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    // AuthController is accessed from the nearest
    // ProviderScope through the context extension below.
    final container = ProviderScope.containerOf(
      context,
      listen: false,
    );

    await container.read(authProvider.notifier).logout();

    if (!context.mounted) {
      return;
    }

    context.go('/login');
  }
}

class NavigationItem {
  final String label;
  final String route;
  final IconData icon;

  const NavigationItem({
    required this.label,
    required this.route,
    required this.icon,
  });
}

class _NavigationItem extends StatelessWidget {
  final NavigationItem item;
  final bool selected;
  final bool danger;
  final VoidCallback onTap;

  const _NavigationItem({
    required this.item,
    required this.selected,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger
        ? AppTheme.danger
        : selected
        ? AppTheme.primary
        : AppTheme.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected
            ? AppTheme.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 11,
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 20,
                  color: color,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}