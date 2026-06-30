import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'shared/widgets/stiff_bounce_physics.dart';

void main() {
  runApp(
    // Riverpod 전역 상태 컨테이너
    const ProviderScope(child: MyFisApp()),
  );
}

class MyFisApp extends ConsumerWidget {
  const MyFisApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'MyFIS',
      debugShowCheckedModeBanner: false,
      // 전역 오버스크롤 억제 — 모든 스크롤뷰가 덜 끌리게
      scrollBehavior: const StiffBounceScrollBehavior(),
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark, // 다크 토스 — 기본 다크
      routerConfig: router,
    );
  }
}
