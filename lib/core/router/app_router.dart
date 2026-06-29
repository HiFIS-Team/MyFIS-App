import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/home_screen.dart';
import '../../features/profile/presentation/my_page_screen.dart';
import '../../features/ranking/presentation/ranking_screen.dart';
import '../../features/routine/presentation/routine_screen.dart';
import '../../shared/widgets/main_shell.dart';

// 루트 및 각 탭 브랜치의 네비게이터 키
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>();
final _routineNavigatorKey = GlobalKey<NavigatorState>();
final _rankingNavigatorKey = GlobalKey<NavigatorState>();
final _myNavigatorKey = GlobalKey<NavigatorState>();

/// 앱 라우터 provider.
/// 인증 상태 등에 따라 redirect를 추가하려면 여기에서 처리한다.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      // 하단 4탭을 유지하는 StatefulShellRoute
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
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
            navigatorKey: _rankingNavigatorKey,
            routes: [
              GoRoute(
                path: '/ranking',
                builder: (context, state) => const RankingScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _myNavigatorKey,
            routes: [
              GoRoute(
                path: '/my',
                builder: (context, state) => const MyPageScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
