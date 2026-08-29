enum DashboardRole {
  saasAdmin,
  gymAdmin,
  staff,
}

DashboardRole dashboardRoleFromString(String role) {
  switch (role) {
    case 'saas_admin':
      return DashboardRole.saasAdmin;

    case 'staff':
      return DashboardRole.staff;

    default:
      return DashboardRole.gymAdmin;
  }
}

// ================================================================
// SaaS Dashboard
// ================================================================

class SaasDashboardData {
  final int totalGyms;
  final int activeGyms;
  final int saasSubscriptions;
  final double saasRevenue;
  final List<PlanDistribution> planDistribution;
  final List<RecentSubscription> recentSubscriptions;

  const SaasDashboardData({
    required this.totalGyms,
    required this.activeGyms,
    required this.saasSubscriptions,
    required this.saasRevenue,
    required this.planDistribution,
    required this.recentSubscriptions,
  });

  factory SaasDashboardData.fromJson(
      Map<String, dynamic> json,
      ) {
    final distribution =
    json['plan_distribution'];

    final subscriptions =
    json['recent_subscriptions'];

    return SaasDashboardData(
      totalGyms: _toInt(json['total_gyms']),
      activeGyms: _toInt(json['active_gyms']),
      saasSubscriptions:
      _toInt(json['saas_subscriptions']),
      saasRevenue:
      _toDouble(json['saas_revenue']),

      planDistribution:
      distribution is List
          ? distribution
          .whereType<Map>()
          .map(
            (item) => PlanDistribution
            .fromJson(
          Map<String, dynamic>.from(
            item,
          ),
        ),
      )
          .toList()
          : [],

      recentSubscriptions:
      subscriptions is List
          ? subscriptions
          .whereType<Map>()
          .map(
            (item) => RecentSubscription
            .fromJson(
          Map<String, dynamic>.from(
            item,
          ),
        ),
      )
          .toList()
          : [],
    );
  }
}

class PlanDistribution {
  final String plan;
  final int count;

  const PlanDistribution({
    required this.plan,
    required this.count,
  });

  factory PlanDistribution.fromJson(
      Map<String, dynamic> json,
      ) {
    return PlanDistribution(
      plan: json['plan']?.toString() ?? 'Unknown',
      count: _toInt(json['count']),
    );
  }
}

class RecentSubscription {
  final String id;
  final String gymId;
  final String saasPlanId;
  final String status;

  const RecentSubscription({
    required this.id,
    required this.gymId,
    required this.saasPlanId,
    required this.status,
  });

  factory RecentSubscription.fromJson(
      Map<String, dynamic> json,
      ) {
    return RecentSubscription(
      id: json['id']?.toString() ?? '',
      gymId: json['gym_id']?.toString() ?? '',
      saasPlanId:
      json['saas_plan_id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }
}

// ================================================================
// Gym Dashboard
// ================================================================

class GymDashboardData {
  final String gymId;
  final int totalMembers;
  final int activeMembers;
  final int activeSubscriptions;
  final double revenue;
  final double subscriptionValue;
  final int payments;
  final int attendance;
  final int expiringSubscriptions;

  const GymDashboardData({
    required this.gymId,
    required this.totalMembers,
    required this.activeMembers,
    required this.activeSubscriptions,
    required this.revenue,
    required this.subscriptionValue,
    required this.payments,
    required this.attendance,
    required this.expiringSubscriptions,
  });

  factory GymDashboardData.fromJson(
      Map<String, dynamic> json,
      ) {
    return GymDashboardData(
      gymId: json['gym_id']?.toString() ?? '',
      totalMembers:
      _toInt(json['total_members']),
      activeMembers:
      _toInt(json['active_members']),
      activeSubscriptions:
      _toInt(json['active_subscriptions']),
      revenue:
      _toDouble(json['revenue']),
      subscriptionValue:
      _toDouble(json['subscription_value']),
      payments:
      _toInt(json['payments']),
      attendance:
      _toInt(json['attendance']),
      expiringSubscriptions:
      _toInt(json['expiring_subscriptions']),
    );
  }
}

// ================================================================
// Staff Dashboard
// ================================================================

class StaffDashboardData {
  final String gymId;
  final int todaysCheckins;
  final int activeMembers;
  final int expiringSubscriptions;
  final List<StaffActivity> recentActivity;

  const StaffDashboardData({
    required this.gymId,
    required this.todaysCheckins,
    required this.activeMembers,
    required this.expiringSubscriptions,
    required this.recentActivity,
  });

  factory StaffDashboardData.fromJson(
      Map<String, dynamic> json,
      ) {
    final activity = json['recent_activity'];

    return StaffDashboardData(
      gymId: json['gym_id']?.toString() ?? '',
      todaysCheckins:
      _toInt(json['todays_checkins']),
      activeMembers:
      _toInt(json['active_members']),
      expiringSubscriptions:
      _toInt(json['expiring_subscriptions']),

      recentActivity:
      activity is List
          ? activity
          .whereType<Map>()
          .map(
            (item) => StaffActivity.fromJson(
          Map<String, dynamic>.from(
            item,
          ),
        ),
      )
          .toList()
          : [],
    );
  }
}

class StaffActivity {
  final String id;
  final String memberId;
  final String? checkInTime;
  final String? checkOutTime;

  const StaffActivity({
    required this.id,
    required this.memberId,
    this.checkInTime,
    this.checkOutTime,
  });

  factory StaffActivity.fromJson(
      Map<String, dynamic> json,
      ) {
    return StaffActivity(
      id: json['id']?.toString() ?? '',
      memberId:
      json['member_id']?.toString() ?? '',
      checkInTime:
      json['check_in_time']?.toString(),
      checkOutTime:
      json['check_out_time']?.toString(),
    );
  }

  bool get isCheckedIn =>
      checkOutTime == null;
}

// ================================================================
// Helpers
// ================================================================

int _toInt(dynamic value) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(
    value?.toString() ?? '',
  ) ??
      0;
}

double _toDouble(dynamic value) {
  if (value is double) {
    return value;
  }

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(
    value?.toString() ?? '',
  ) ??
      0;
}