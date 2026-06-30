import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';

/// 앱 진입 스플래시 — MyFIS 워드마크가 가운데서 떠올라 위로 이동하고,
/// 그 아래 슬로건이 페이드 인된 뒤 홈으로. (토스·배민식 첫 로딩 화면)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  )..forward();

  late final Animation<double> _logoIn = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.0, 0.30, curve: Curves.easeOut),
  );
  late final Animation<double> _moveUp = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.34, 0.62, curve: Curves.easeOutCubic),
  );
  late final Animation<double> _tagIn = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.58, 0.92, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    // 애니메이션 보여준 뒤 홈으로 (실제 초기화/인증 체크 자리)
    Future.delayed(const Duration(milliseconds: 2700), () {
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final logoAlign = Alignment.lerp(
            Alignment.center,
            const Alignment(0, -0.45),
            _moveUp.value,
          )!;
          return Stack(
            children: [
              // 워드마크: 가운데서 페이드·스케일 인 → 위로 이동
              Align(
                alignment: logoAlign,
                child: Opacity(
                  opacity: _logoIn.value,
                  child: Transform.scale(
                    scale: 0.92 + 0.08 * _logoIn.value,
                    child: const _Wordmark(),
                  ),
                ),
              ),
              // 슬로건: 워드마크 아래에서 살짝 떠오르며 페이드 인
              Align(
                alignment: const Alignment(0, -0.18),
                child: Opacity(
                  opacity: _tagIn.value,
                  child: Transform.translate(
                    offset: Offset(0, (1 - _tagIn.value) * 10),
                    child: const _Tagline(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return const Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: 42,
          fontWeight: FontWeight.w800,
          letterSpacing: -1,
        ),
        children: [
          TextSpan(text: 'My', style: TextStyle(color: AppColors.textPrimary)),
          TextSpan(text: 'FIS', style: TextStyle(color: AppColors.lime)),
        ],
      ),
    );
  }
}

class _Tagline extends StatelessWidget {
  const _Tagline();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '피트니스스타를',
          style: textTheme.bodyLarge?.copyWith(
            fontSize: 20,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
        ),
        Text.rich(
          TextSpan(
            style: textTheme.bodyLarge?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.5,
            ),
            children: const [
              TextSpan(
                text: 'MyFIS App',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              TextSpan(
                text: ' 하나로',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
