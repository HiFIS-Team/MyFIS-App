import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/benefit/presentation/benefit_screen.dart';
import '../../features/cardio/presentation/cardio_screen.dart';
import '../../features/checkin/presentation/checkin_barcode_screen.dart';
import '../../features/coupon/presentation/coupon_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/membership/domain/branch.dart';
import '../../features/membership/presentation/branch_detail_screen.dart';
import '../../features/membership/presentation/branch_list_screen.dart';
import '../../features/membership/presentation/membership_screen.dart';
import '../../features/notification/presentation/notification_screen.dart';
import '../../features/profile/presentation/my_page_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/ranking/presentation/ranking_full_screen.dart';
import '../../features/ranking/presentation/ranking_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/store/domain/product.dart';
import '../../features/store/presentation/cart_screen.dart';
import '../../features/store/presentation/exchange_complete_screen.dart';
import '../../features/store/presentation/product_detail_screen.dart';
import '../../features/store/presentation/search_screen.dart';
import '../../features/store/presentation/store_screen.dart';
import '../../features/store/presentation/wishlist_screen.dart';
import '../../features/weight/presentation/weight_screen.dart';
import '../../shared/widgets/main_shell.dart';

// 루트 및 각 탭 브랜치의 네비게이터 키 (MainShell 인덱스 순서와 동일)
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>();
final _storeNavigatorKey = GlobalKey<NavigatorState>();
final _weightNavigatorKey = GlobalKey<NavigatorState>();
final _cardioNavigatorKey = GlobalKey<NavigatorState>();
final _rankingNavigatorKey = GlobalKey<NavigatorState>();
final _myNavigatorKey = GlobalKey<NavigatorState>();
final _benefitNavigatorKey = GlobalKey<NavigatorState>();

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

/// 상단 드롭다운 시트 페이지 (출석 바코드 — 위에서 바코드까지만 내려옴).
/// 투명 오버레이라 패널이 안 덮은 아래쪽은 뒤 화면(홈)이 비친다.
/// 슬라이드·스크림 애니메이션은 화면이 ModalRoute.animation으로 직접 처리.
CustomTransitionPage<void> _topSheetPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    opaque: false,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 340),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    child: child,
    transitionsBuilder: (_, _, _, child) => child,
  );
}

/// 페이드 전환 페이지 (교환 완료 등 결과 화면용).
CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 280),
    child: child,
    transitionsBuilder: (_, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

/// 앱 라우터 provider.
/// 인증 상태 등에 따라 redirect를 추가하려면 여기에서 처리한다.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      // 스플래시 — 앱 진입 시 MyFIS 로고 후 홈으로
      GoRoute(
        path: '/splash',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SplashScreen(),
      ),

      // 알림 — 탭 위로 풀스크린, 오른쪽→왼쪽 슬라이드 진입
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _slideFromRight(state, const NotificationScreen()),
      ),

      // 출석 바코드 — 위에서 바코드까지 내려오는 드롭다운 시트
      GoRoute(
        path: '/check-in',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _topSheetPage(state, const CheckinBarcodeScreen()),
      ),

      // 멤버십 관리 — 오른쪽→왼쪽 슬라이드
      GoRoute(
        path: '/membership',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _slideFromRight(state, const MembershipScreen()),
      ),

      // 지점 안내(목록) — 멤버십 관리에서 오른쪽→왼쪽 슬라이드
      GoRoute(
        path: '/branches',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _slideFromRight(state, const BranchListScreen()),
      ),

      // 지점 상세 — 지점 안내 목록에서 오른쪽→왼쪽 슬라이드
      GoRoute(
        path: '/branch',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _slideFromRight(
          state,
          BranchDetailScreen(branch: state.extra as Branch),
        ),
      ),

      // 프로필 상세 — 마이페이지 프로필 카드에서 오른쪽→왼쪽 슬라이드
      GoRoute(
        path: '/profile',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _slideFromRight(state, const ProfileScreen()),
      ),

      // 상품 상세 — 스토어 카드에서 오른쪽→왼쪽 슬라이드 진입
      GoRoute(
        path: '/product',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _slideFromRight(
          state,
          ProductDetailScreen(product: state.extra as Product),
        ),
      ),

      // 검색 — 검색창이 Hero로 모핑되도록 배경은 페이드
      GoRoute(
        path: '/search',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _fadePage(state, const SearchScreen()),
      ),

      // 장바구니 — 오른쪽→왼쪽 슬라이드
      GoRoute(
        path: '/cart',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _slideFromRight(state, const CartScreen()),
      ),

      // 쿠폰함 — 오른쪽→왼쪽 슬라이드
      GoRoute(
        path: '/coupon',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _slideFromRight(state, const CouponScreen()),
      ),

      // 전체 랭킹 — 홈 랭킹 더 보기에서 진입(오른쪽→왼쪽 슬라이드)
      GoRoute(
        path: '/ranking-full',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _slideFromRight(
          state,
          RankingFullScreen(initialTab: state.extra as int? ?? 0),
        ),
      ),

      // 찜한 상품 — 오른쪽→왼쪽 슬라이드
      GoRoute(
        path: '/wishlist',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _slideFromRight(state, const WishlistScreen()),
      ),

      // 교환 완료 — 장바구니에서 교환 후 풀스크린 페이드 진입
      GoRoute(
        path: '/exchange-complete',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final args = state.extra as ({String summary, int totalPoints});
          return _fadePage(
            state,
            ExchangeCompleteScreen(
              summary: args.summary,
              totalPoints: args.totalPoints,
            ),
          );
        },
      ),

      // 하단 탭 — 탭 전환 시 부드러운 크로스페이드 (상태 보존)
      StatefulShellRoute(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        navigatorContainerBuilder: (context, navigationShell, children) {
          return AnimatedBranchContainer(
            currentIndex: navigationShell.currentIndex,
            children: children,
          );
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
            navigatorKey: _storeNavigatorKey,
            routes: [
              GoRoute(
                path: '/store',
                builder: (context, state) => const StoreScreen(),
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
          // 혜택 — 브랜치 인덱스 6 (하단바에선 홈과 스토어 사이에 표시)
          StatefulShellBranch(
            navigatorKey: _benefitNavigatorKey,
            routes: [
              GoRoute(
                path: '/benefit',
                builder: (context, state) => const BenefitScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
