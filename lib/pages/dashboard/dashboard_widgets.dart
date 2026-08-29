import 'package:flutter/material.dart';

import '../../core/theme.dart';
import 'dashboard_models.dart';

class DashboardStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color:
                AppTheme.primary.withValues(
                  alpha: 0.10,
                ),
                borderRadius:
                BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: AppTheme.primary,
                size: 21,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color:
                      AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight:
                      FontWeight.w700,
                      color:
                      AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardPanel extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? action;

  const DashboardPanel({
    super.key,
    required this.title,
    required this.child,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight:
                      FontWeight.w600,
                      color:
                      AppTheme.textPrimary,
                    ),
                  ),
                ),
                if (action != null) action!,
              ],
            ),
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    );
  }
}

class DashboardNumberPanel
    extends StatelessWidget {
  final String title;
  final int value;
  final String subtitle;
  final VoidCallback? onPressed;
  final String? buttonLabel;

  const DashboardNumberPanel({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    this.onPressed,
    this.buttonLabel,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardPanel(
      title: title,
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppTheme.textSecondary,
            ),
          ),
          if (onPressed != null &&
              buttonLabel != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: onPressed,
              child: Text(buttonLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class PlanDistributionList
    extends StatelessWidget {
  final List<PlanDistribution> items;

  const PlanDistributionList({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyDashboard(
        text: 'No plan data yet.',
      );
    }

    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(
              bottom: 12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item.plan,
                    style: const TextStyle(
                      color:
                      AppTheme.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius:
                    BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.count.toString(),
                    style: const TextStyle(
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class RecentSubscriptionsList
    extends StatelessWidget {
  final List<RecentSubscription> items;

  const RecentSubscriptionsList({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyDashboard(
        text: 'No recent subscriptions.',
      );
    }

    final visible =
    items.take(6).toList();

    return Column(
      children: [
        for (final item in visible)
          Padding(
            padding: const EdgeInsets.only(
              bottom: 12,
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius:
                    BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.business_outlined,
                    size: 17,
                    color:
                    AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _shortId(item.gymId),
                    style: const TextStyle(
                      color:
                      AppTheme.textPrimary,
                      fontWeight:
                      FontWeight.w500,
                    ),
                  ),
                ),
                _StatusText(
                  value: item.status,
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _shortId(String value) {
    if (value.length <= 8) {
      return value;
    }

    return '${value.substring(0, 8)}…';
  }
}

class StaffActivityList
    extends StatelessWidget {
  final List<StaffActivity> items;

  const StaffActivityList({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyDashboard(
        text: 'No recent activity.',
      );
    }

    return Column(
      children: [
        for (final item in items.take(8))
          Padding(
            padding: const EdgeInsets.only(
              bottom: 12,
            ),
            child: Row(
              children: [
                Icon(
                  item.isCheckedIn
                      ? Icons.login_outlined
                      : Icons.logout_outlined,
                  size: 18,
                  color: item.isCheckedIn
                      ? AppTheme.success
                      : AppTheme.textSecondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _shortId(item.memberId),
                    style: const TextStyle(
                      fontWeight:
                      FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  item.isCheckedIn
                      ? 'Checked in'
                      : 'Completed',
                  style: TextStyle(
                    fontSize: 12,
                    color: item.isCheckedIn
                        ? AppTheme.success
                        : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _shortId(String value) {
    if (value.length <= 8) {
      return value;
    }

    return '${value.substring(0, 8)}…';
  }
}

class _StatusText extends StatelessWidget {
  final String value;

  const _StatusText({
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final active = value.toLowerCase() == 'active';

    return Text(
      value.isEmpty ? '—' : value,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: active
            ? AppTheme.success
            : AppTheme.textSecondary,
      ),
    );
  }
}

class _EmptyDashboard
    extends StatelessWidget {
  final String text;

  const _EmptyDashboard({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 24,
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}