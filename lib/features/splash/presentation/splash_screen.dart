import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';

/// 앱 진입 스플래시 — 검은 배경에 MyFIS 워드마크가 떠 있다가 홈으로.
/// (토스·배민식 첫 로딩 화면)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();

  @override
  void initState() {
    super.initState();
    // 잠깐 보여준 뒤 홈으로 (실제 초기화/인증 체크 자리)
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) context.go('/home');
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: FadeTransition(
          opacity: fade,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1).animate(fade),
            child: const Text.rich(
              TextSpan(
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
                children: [
                  TextSpan(
                    text: 'My',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  TextSpan(
                    text: 'FIS',
                    style: TextStyle(color: AppColors.lime),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
