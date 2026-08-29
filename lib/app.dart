import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/auth.dart';
import 'core/theme.dart';

import 'pages/activation/activation_page.dart';
import 'pages/attendance/attendance_page.dart';
import 'pages/dashboard/dashboard_page.dart';
import 'pages/gym_settings/gym_settings_page.dart';
import 'pages/gym_subscriptions/gym_subscriptions_page.dart';
import 'pages/gyms/gyms_page.dart';
import 'pages/login/login_page.dart';
import 'pages/measurements/measurements_page.dart';
import 'pages/members/member_profile_page.dart';
import 'pages/members/members_page.dart';
import 'pages/payments/payments_page.dart';
import 'pages/plans/plans_page.dart';
import 'pages/saas_plans/saas_plans_page.dart';
import 'pages/settings/settings_page.dart';
import 'pages/staff/staff_page.dart';
import 'pages/subscriptions/subscriptions_page.dart';
import 'pages/support/support_page.dart';

import 'shell/app_shell.dart';

class GymFlowApp extends ConsumerStatefulWidget {
  const GymFlowApp({super.key});

  @override
  ConsumerState<GymFlowApp> createState() =>
      _GymFlowAppState();
}

class _GymFlowAppState
    extends ConsumerState<GymFlowApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    _router = GoRouter(
      initialLocation: '/dashboard',

      refreshListenable:
      GoRouterRefreshStream(
        ref.read(authProvider.notifier).stream,
      ),

      redirect: _redirect,

      routes: [
        // ------------------------------------------------------
        // PUBLIC
        // ------------------------------------------------------

        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) {
            return const LoginPage();
          },
        ),

        GoRoute(
          path: '/activation',
          name: 'activation',
          builder: (context, state) {
            return const ActivationPage();
          },
        ),

        // ------------------------------------------------------
        // AUTHENTICATED APP
        // ------------------------------------------------------

        ShellRoute(
          builder: (
              context,
              state,
              child,
              ) {
            return AppShell(
              child: child,
            );
          },
          routes: [
            // Dashboard
            GoRoute(
              path: '/dashboard',
              name: 'dashboard',
              builder: (
                  context,
                  state,
                  ) {
                return const DashboardPage();
              },
            ),

            // --------------------------------------------------
            // SAAS ADMIN
            // --------------------------------------------------

            GoRoute(
              path: '/gyms',
              name: 'gyms',
              builder: (
                  context,
                  state,
                  ) {
                return const GymsPage();
              },
            ),

            GoRoute(
              path: '/saas-plans',
              name: 'saas-plans',
              builder: (
                  context,
                  state,
                  ) {
                return const SaasPlansPage();
              },
            ),

            GoRoute(
              path: '/gym-subscriptions',
              name: 'gym-subscriptions',
              builder: (
                  context,
                  state,
                  ) {
                return const GymSubscriptionsPage();
              },
            ),

            // --------------------------------------------------
            // GYM ADMIN / STAFF
            // --------------------------------------------------

            GoRoute(
              path: '/members',
              name: 'members',
              builder: (
                  context,
                  state,
                  ) {
                return const MembersPage();
              },
            ),

            GoRoute(
              path: '/members/:memberId',
              name: 'member-profile',
              builder: (
                  context,
                  state,
                  ) {
                final memberId =
                state.pathParameters[
                'memberId']!;

                return MemberProfilePage(
                  memberId: memberId,
                );
              },
            ),

            GoRoute(
              path: '/staff',
              name: 'staff',
              builder: (
                  context,
                  state,
                  ) {
                return const StaffPage();
              },
            ),

            GoRoute(
              path: '/plans',
              name: 'plans',
              builder: (
                  context,
                  state,
                  ) {
                return const PlansPage();
              },
            ),

            GoRoute(
              path: '/subscriptions',
              name: 'subscriptions',
              builder: (
                  context,
                  state,
                  ) {
                return const SubscriptionsPage();
              },
            ),

            GoRoute(
              path: '/payments',
              name: 'payments',
              builder: (
                  context,
                  state,
                  ) {
                return const PaymentsPage();
              },
            ),

            GoRoute(
              path: '/attendance',
              name: 'attendance',
              builder: (
                  context,
                  state,
                  ) {
                return const AttendancePage();
              },
            ),

            GoRoute(
              path: '/measurements',
              name: 'measurements',
              builder: (
                  context,
                  state,
                  ) {
                return const MeasurementsPage();
              },
            ),

            // --------------------------------------------------
            // SETTINGS
            // --------------------------------------------------

            GoRoute(
              path: '/settings',
              name: 'settings',
              builder: (
                  context,
                  state,
                  ) {
                final user =
                    ref.read(authProvider).user;

                if (user?.isSaasAdmin == true) {
                  return const SettingsPage();
                }

                return const GymSettingsPage(
                  role: 'gym_admin',
                );
              },
            ),

            // --------------------------------------------------
            // SUPPORT
            // --------------------------------------------------

            GoRoute(
              path: '/support',
              name: 'support',
              builder: (
                  context,
                  state,
                  ) {
                return const SupportPage();
              },
            ),
          ],
        ),
      ],
    );
  }

  String? _redirect(
      BuildContext context,
      GoRouterState state,
      ) {
    final auth =
    ref.read(authProvider);

    final location =
        state.uri.path;

    final isLogin =
        location == '/login';

    final isActivation =
        location == '/activation';

    // Auth is still being restored.
    if (auth.status ==
        AuthStatus.unknown ||
        auth.status ==
            AuthStatus.loading) {
      return null;
    }

    // ----------------------------------------------------------
    // NOT AUTHENTICATED
    // ----------------------------------------------------------

    if (!auth.isAuthenticated) {
      if (isLogin ||
          isActivation) {
        return null;
      }

      return '/login';
    }

    // ----------------------------------------------------------
    // ALREADY AUTHENTICATED
    // ----------------------------------------------------------

    if (isLogin ||
        isActivation) {
      return '/dashboard';
    }

    // ----------------------------------------------------------
    // ROLE PROTECTION
    // ----------------------------------------------------------

    final user = auth.user;

    if (user == null) {
      return '/login';
    }

    // SaaS-only pages.
    final saasOnly =
        location == '/gyms' ||
            location == '/saas-plans' ||
            location ==
                '/gym-subscriptions';

    if (saasOnly &&
        !user.isSaasAdmin) {
      return '/dashboard';
    }

    // Gym admin-only page.
    if (location == '/staff' &&
        !user.isGymAdmin) {
      return '/dashboard';
    }

    // Gym settings.
    if (location == '/settings' &&
        user.isStaff) {
      return '/dashboard';
    }

    return null;
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return MaterialApp.router(
      title: 'GymFlow Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}

/// Refreshes GoRouter when Riverpod auth changes.
class GoRouterRefreshStream
    extends ChangeNotifier {
  GoRouterRefreshStream(
      Stream<dynamic> stream,
      ) {
    _subscription =
        stream.asBroadcastStream().listen(
              (_) {
            notifyListeners();
          },
        );
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

