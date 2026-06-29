import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/home_screen.dart';
import '../../features/membership/presentation/membership_screen.dart';
import '../../features/routine/presentation/routine_screen.dart';

// 각 탭 브랜치의 네비게이터 키
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _routineNavigatorKey = GlobalKey<NavigatorState>();
final _membershipNavigatorKey = GlobalKey<NavigatorState>();

/// 앱 라우터 provider.
/// 인증 상태 등에 따라 redirect를 추가하려면 여기에서 처리한다.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/routine',
    routes: [
      // 하단 탭을 유지하는 StatefulShellRoute
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _routineNavigatorKey,
            routes: [
              GoRoute(
                path: '/routine',
                builder: (context, state) => const RoutineScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _membershipNavigatorKey,
            routes: [
              GoRoute(
                path: '/membership',
                builder: (context, state) => const MembershipScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
