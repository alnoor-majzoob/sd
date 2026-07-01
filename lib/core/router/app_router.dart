import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/app_sidebar.dart';
import '../../shared/widgets/app_topbar.dart';
import '../../features/workspace_hub/workspace_hub_screen.dart';
import '../../features/data_management/data_management_screen.dart';
import '../../features/ga_runner/ga_runner_screen.dart';
import '../../features/schedule_view/schedule_view_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/hub',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return Scaffold(
          body: Row(
            children: [
              const AppSidebar(),
              Expanded(
                child: Column(
                  children: [
                    const AppTopBar(),
                    Expanded(child: child),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      routes: [
        GoRoute(
          path: '/hub',
          builder: (context, state) => const WorkspaceHubScreen(),
        ),
        GoRoute(
          path: '/data',
          builder: (context, state) => const DataManagementScreen(),
        ),
        GoRoute(
          path: '/runner',
          builder: (context, state) => const GaRunnerScreen(),
        ),
        GoRoute(
          path: '/schedule',
          builder: (context, state) => const ScheduleViewScreen(),
        ),
      ],
    ),
  ],
);
