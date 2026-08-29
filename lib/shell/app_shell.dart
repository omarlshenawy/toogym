import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/auth.dart';
import '../core/responsive.dart';
import 'sidebar.dart';
import 'top_bar.dart';

class AppShell extends ConsumerStatefulWidget {
  final Widget child;

  const AppShell({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<AppShell> createState() =>
      _AppShellState();
}

class _AppShellState
    extends ConsumerState<AppShell> {
  final GlobalKey<ScaffoldState>
  _scaffoldKey =
  GlobalKey<ScaffoldState>();

  @override
  Widget build(
      BuildContext context,
      ) {
    final auth =
    ref.watch(authProvider);

    final user = auth.user;

    if (user == null) {
      return const Scaffold(
        body: SizedBox.shrink(),
      );
    }

    final desktop =
    Responsive.isDesktop(context);

    return Scaffold(
      key: _scaffoldKey,

      drawer: desktop
          ? null
          : Drawer(
        width: 280,
        child: Sidebar(
          user: user,
          onClose: () {
            Navigator.of(
              context,
            ).pop();
          },
        ),
      ),

      body: Row(
        children: [
          if (desktop)
            const SizedBox(
              width: 250,
              child: _DesktopSidebar(),
            ),

          Expanded(
            child: Column(
              children: [
                TopBar(
                  user: user,
                  onMenuPressed:
                  desktop
                      ? null
                      : () {
                    _scaffoldKey
                        .currentState
                        ?.openDrawer();
                  },
                ),

                Expanded(
                  child: widget.child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopSidebar
    extends ConsumerWidget {
  const _DesktopSidebar();

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final user =
        ref.watch(authProvider).user;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return Sidebar(
      user: user,
    );
  }
}