import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/dashboard_api.dart';
import '../../core/auth.dart';
import '../../core/common_widgets.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';
import 'dashboard_models.dart';
import 'dashboard_widgets.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({
    super.key,
  });

  @override
  ConsumerState<DashboardPage> createState() =>
      _DashboardPageState();
}

class _DashboardPageState
    extends ConsumerState<DashboardPage> {
  bool _loading = true;
  String? _error;

  DashboardRole? _role;

  SaasDashboardData? _saasData;
  GymDashboardData? _gymData;
  StaffDashboardData? _staffData;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
          (_) {
        _loadDashboard();
      },
    );
  }

  Future<void> _loadDashboard() async {
    final auth = ref.read(authProvider);
    final user = auth.user;

    if (user == null) {
      return;
    }

    final role = dashboardRoleFromString(
      user.role,
    );

    setState(() {
      _loading = true;
      _error = null;
      _role = role;
    });

    try {
      final data = await DashboardApi.getForRole(
        user.role,
      );

      if (!mounted) {
        return;
      }

      switch (role) {
        case DashboardRole.saasAdmin:
          _saasData =
              SaasDashboardData.fromJson(data);
          break;

        case DashboardRole.gymAdmin:
          _gymData =
              GymDashboardData.fromJson(data);
          break;

        case DashboardRole.staff:
          _staffData =
              StaffDashboardData.fromJson(data);
          break;
      }

      setState(() {
        _loading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _error = _cleanError(e.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const AppLoading(
        message: 'Loading dashboard...',
      );
    }

    if (_error != null) {
      return AppErrorState(
        message: _error!,
        onRetry: _loadDashboard,
      );
    }

    switch (_role) {
      case DashboardRole.saasAdmin:
        return _buildSaasDashboard();

      case DashboardRole.staff:
        return _buildStaffDashboard();

      case DashboardRole.gymAdmin:
        return _buildGymDashboard();

      case null:
        return const AppErrorState(
          message: 'Unable to determine user role.',
        );
    }
  }

  // ============================================================
  // SaaS Admin
  // ============================================================

  Widget _buildSaasDashboard() {
    final data = _saasData;

    if (data == null) {
      return const AppErrorState(
        message: 'Dashboard data is unavailable.',
      );
    }

    return _DashboardLayout(
      title: 'Dashboard',
      subtitle:
      'Platform overview and SaaS performance.',
      actions: [
        ElevatedButton.icon(
          onPressed: () {
            // Navigation will be connected when
            // the Gyms page is added to the router.
          },
          icon: const Icon(Icons.add),
          label: const Text('New Gym'),
        ),
      ],
      children: [
        _buildStats([
          DashboardStatCard(
            title: 'Total Gyms',
            value: data.totalGyms.toString(),
            icon: Icons.business_outlined,
          ),
          DashboardStatCard(
            title: 'Active Gyms',
            value: data.activeGyms.toString(),
            icon: Icons.check_circle_outline,
          ),
          DashboardStatCard(
            title: 'SaaS Subscriptions',
            value:
            data.saasSubscriptions.toString(),
            icon: Icons.layers_outlined,
          ),
          DashboardStatCard(
            title: 'SaaS Revenue',
            value: _money(data.saasRevenue),
            icon: Icons.payments_outlined,
          ),
        ]),
        const SizedBox(height: 20),
        _responsivePanels(
          DashboardPanel(
            title: 'Plan Distribution',
            child: PlanDistributionList(
              items: data.planDistribution,
            ),
          ),
          DashboardPanel(
            title: 'Recent Subscriptions',
            child: RecentSubscriptionsList(
              items: data.recentSubscriptions,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // Gym Admin
  // ============================================================

  Widget _buildGymDashboard() {
    final data = _gymData;

    if (data == null) {
      return const AppErrorState(
        message: 'Dashboard data is unavailable.',
      );
    }

    return _DashboardLayout(
      title: 'Gym Dashboard',
      subtitle:
      'A real-time overview of your gym.',
      actions: [
        OutlinedButton.icon(
          onPressed: _downloadReport,
          icon: const Icon(
            Icons.download_outlined,
          ),
          label: const Text('Download Report'),
        ),
      ],
      children: [
        _buildStats([
          DashboardStatCard(
            title: 'Total Members',
            value:
            data.totalMembers.toString(),
            icon: Icons.people_outline,
          ),
          DashboardStatCard(
            title: 'Active Members',
            value:
            data.activeMembers.toString(),
            icon: Icons.person_outline,
          ),
          DashboardStatCard(
            title: 'Active Subscriptions',
            value: data.activeSubscriptions
                .toString(),
            icon: Icons.layers_outlined,
          ),
          DashboardStatCard(
            title: 'Revenue',
            value: _money(data.revenue),
            icon: Icons.payments_outlined,
          ),
        ]),
        const SizedBox(height: 20),
        _responsivePanels(
          DashboardNumberPanel(
            title: 'Attendance',
            value: data.attendance,
            subtitle: 'Check-ins recorded',
            buttonLabel: 'View attendance →',
            onPressed: () {
              // Router will be connected later.
            },
          ),
          DashboardNumberPanel(
            title: 'Expiring Subscriptions',
            value:
            data.expiringSubscriptions,
            subtitle: 'Need attention soon',
            buttonLabel:
            'View subscriptions →',
            onPressed: () {
              // Router will be connected later.
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // Staff
  // ============================================================

  Widget _buildStaffDashboard() {
    final data = _staffData;

    if (data == null) {
      return const AppErrorState(
        message: 'Dashboard data is unavailable.',
      );
    }

    return _DashboardLayout(
      title: 'Operational Dashboard',
      subtitle:
      "Today's operations at a glance.",
      actions: [
        OutlinedButton.icon(
          onPressed: _downloadReport,
          icon: const Icon(
            Icons.download_outlined,
          ),
          label: const Text('Download Report'),
        ),
      ],
      children: [
        _buildStats([
          DashboardStatCard(
            title: "Today's Check-ins",
            value:
            data.todaysCheckins.toString(),
            icon: Icons.check_circle_outline,
          ),
          DashboardStatCard(
            title: 'Active Members',
            value:
            data.activeMembers.toString(),
            icon: Icons.people_outline,
          ),
          DashboardStatCard(
            title: 'Expiring Subscriptions',
            value: data.expiringSubscriptions
                .toString(),
            icon: Icons.access_time_outlined,
          ),
          DashboardStatCard(
            title: 'Recent Activity',
            value:
            data.recentActivity.length
                .toString(),
            icon: Icons.history_outlined,
          ),
        ]),
        const SizedBox(height: 20),
        DashboardPanel(
          title: 'Recent Activity',
          child: StaffActivityList(
            items: data.recentActivity,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // Shared
  // ============================================================

  Widget _buildStats(
      List<Widget> cards,
      ) {
    final mobile =
    Responsive.isMobile(context);

    final tablet =
    Responsive.isTablet(context);

    if (mobile) {
      return Column(
        children: [
          for (final card in cards) ...[
            card,
            const SizedBox(height: 12),
          ],
        ],
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics:
      const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate:
      SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: tablet ? 2 : 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 120,
      ),
      itemBuilder: (context, index) {
        return cards[index];
      },
    );
  }

  Widget _responsivePanels(
      Widget first,
      Widget second,
      ) {
    if (Responsive.isMobile(context)) {
      return Column(
        children: [
          first,
          const SizedBox(height: 16),
          second,
        ],
      );
    }

    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Expanded(
          child: first,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: second,
        ),
      ],
    );
  }

  Future<void> _downloadReport() async {
    // We will connect the real Flutter Web
    // file download later.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Report download will be connected next.',
        ),
      ),
    );
  }

  String _money(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }

  String _cleanError(String error) {
    if (error.startsWith('Exception: ')) {
      return error.substring(11);
    }

    return error;
  }
}

// ================================================================
// Dashboard page layout
// ================================================================

class _DashboardLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget>? actions;
  final List<Widget> children;

  const _DashboardLayout({
    required this.title,
    required this.subtitle,
    required this.children,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final mobile =
    Responsive.isMobile(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(
        mobile ? 16 : 24,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppPageHeader(
                  title: title,
                  subtitle: subtitle,
                ),
              ),

              if (actions != null &&
                  !mobile) ...[
                const SizedBox(width: 16),
                Row(
                  children: actions!,
                ),
              ],
            ],
          ),

          if (actions != null &&
              mobile) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: actions!,
            ),
          ],

          const SizedBox(height: 24),

          ...children,
        ],
      ),
    );
  }
}

