import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/cardio/presentation/cardio_screen.dart';
import '../../features/checkin/presentation/checkin_barcode_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/membership/presentation/membership_screen.dart';
import '../../features/notification/presentation/notification_screen.dart';
import '../../features/profile/presentation/my_page_screen.dart';
import '../../features/ranking/presentation/ranking_screen.dart';
import '../../features/weight/presentation/weight_screen.dart';
import '../../shared/widgets/main_shell.dart';

// 루트 및 각 탭 브랜치의 네비게이터 키
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>();
final _weightNavigatorKey = GlobalKey<NavigatorState>();
final _cardioNavigatorKey = GlobalKey<NavigatorState>();
final _rankingNavigatorKey = GlobalKey<NavigatorState>();
final _myNavigatorKey = GlobalKey<NavigatorState>();

/// 오른쪽→왼쪽 슬라이드 전환 페이지 (네비게이션 진입 공통).
/// 알림·출석 바코드 등 풀스크린 진입 화면에서 사용.
CustomTransitionPage<void> _slideFromRight(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: animation.drive(
          Tween(
            begin: const Offset(1, 0), // 오른쪽에서
            end: Offset.zero, // 왼쪽으로(제자리)
          ).chain(CurveTween(curve: Curves.easeInOut)),
        ),
        child: child,
      );
    },
  );
}

/// 앱 라우터 provider.
/// 인증 상태 등에 따라 redirect를 추가하려면 여기에서 처리한다.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      // 알림 — 탭 위로 풀스크린, 오른쪽→왼쪽 슬라이드 진입
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _slideFromRight(state, const NotificationScreen()),
      ),

      // 출석 바코드 — 알림과 동일하게 오른쪽→왼쪽 슬라이드
      GoRoute(
        path: '/check-in',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _slideFromRight(state, const CheckinBarcodeScreen()),
      ),

      // 멤버십 관리 — 오른쪽→왼쪽 슬라이드
      GoRoute(
        path: '/membership',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _slideFromRight(state, const MembershipScreen()),
      ),

      // 하단 5탭을 유지하는 StatefulShellRoute
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
            navigatorKey: _weightNavigatorKey,
            routes: [
              GoRoute(
                path: '/weight',
                builder: (context, state) => const WeightScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _cardioNavigatorKey,
            routes: [
              GoRoute(
                path: '/cardio',
                builder: (context, state) => const CardioScreen(),
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
