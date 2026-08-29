import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../core/auth.dart';
import '../core/theme.dart';

class TopBar extends ConsumerStatefulWidget {
  final AuthUser user;
  final VoidCallback? onMenuPressed;

  const TopBar({
    super.key,
    required this.user,
    this.onMenuPressed,
  });

  @override
  ConsumerState<TopBar> createState() => _TopBarState();
}

class _TopBarState extends ConsumerState<TopBar> {
  String? systemStatus;
  bool checkingStatus = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.border,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Row(
        children: [
          if (widget.onMenuPressed != null) ...[
            IconButton(
              onPressed: widget.onMenuPressed,
              icon: const Icon(Icons.menu),
              tooltip: 'Menu',
            ),
            const SizedBox(width: 8),
          ],

          Expanded(
            child: _buildBreadcrumb(context),
          ),

          _buildStatusButton(),

          const SizedBox(width: 8),

          IconButton(
            onPressed: () {
              _showLanguageMessage(context);
            },
            tooltip: 'Language',
            icon: const Icon(
              Icons.language_outlined,
            ),
          ),

          IconButton(
            onPressed: () {
              _showNotificationMessage(context);
            },
            tooltip: 'Notifications',
            icon: const Icon(
              Icons.notifications_none_outlined,
            ),
          ),

          const SizedBox(width: 8),

          _buildAvatar(context),
        ],
      ),
    );
  }

  Widget _buildBreadcrumb(BuildContext context) {
    return Text(
      _pageName(context),
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppTheme.textSecondary,
      ),
    );
  }

  String _pageName(BuildContext context) {
    final route = ModalRoute.of(context)
        ?.settings
        .name;

    if (route == null || route.isEmpty) {
      return 'Dashboard';
    }

    final value = route
        .replaceFirst('/', '')
        .replaceAll('-', ' ');

    if (value.isEmpty) {
      return 'Dashboard';
    }

    return value
        .split(' ')
        .map(
          (word) => word.isEmpty
          ? word
          : '${word[0].toUpperCase()}${word.substring(1)}',
    )
        .join(' ');
  }

  Widget _buildStatusButton() {
    return TextButton.icon(
      onPressed: checkingStatus
          ? null
          : _checkSystemStatus,
      icon: Icon(
        Icons.circle,
        size: 9,
        color: _statusColor(),
      ),
      label: Text(
        checkingStatus
            ? 'Checking...'
            : systemStatus ?? 'System Status',
        style: const TextStyle(
          fontSize: 12,
        ),
      ),
    );
  }

  Color _statusColor() {
    if (systemStatus == 'Online') {
      return AppTheme.success;
    }

    if (systemStatus == 'Offline') {
      return AppTheme.danger;
    }

    return AppTheme.textSecondary;
  }

  Widget _buildAvatar(BuildContext context) {
    final initial = (
        widget.user.firstName?.isNotEmpty == true
            ? widget.user.firstName!
            : widget.user.username
    )[0].toUpperCase();

    return PopupMenuButton<String>(
      tooltip: 'Account',
      onSelected: (value) {
        if (value == 'profile') {
          _showProfile(context);
        }
      },
      itemBuilder: (context) {
        return const [
          PopupMenuItem(
            value: 'profile',
            child: Row(
              children: [
                Icon(Icons.person_outline),
                SizedBox(width: 10),
                Text('Profile'),
              ],
            ),
          ),
        ];
      },
      child: CircleAvatar(
        radius: 19,
        backgroundColor:
        AppTheme.primary.withValues(alpha: 0.10),
        child: Text(
          initial,
          style: const TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Future<void> _checkSystemStatus() async {
    setState(() {
      checkingStatus = true;
    });

    try {
      await ApiClient.get('/health');

      if (!mounted) return;

      setState(() {
        systemStatus = 'Online';
        checkingStatus = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        systemStatus = 'Offline';
        checkingStatus = false;
      });
    }
  }

  void _showLanguageMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Language switching will be added later.',
        ),
      ),
    );
  }

  void _showNotificationMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'No new notifications.',
        ),
      ),
    );
  }

  void _showProfile(BuildContext context) {
    final user = widget.user;

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              _profileRow(
                'Name',
                user.displayName,
              ),
              _profileRow(
                'Username',
                user.username,
              ),
              _profileRow(
                'Role',
                user.role,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _profileRow(
      String label,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}