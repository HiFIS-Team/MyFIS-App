import 'package:flutter/material.dart';

import 'app_colors.dart';

/// 앱 전역 테마. 다크 토스(Dark Toss) 방향.
/// - 검정 베이스 + 라임 포인트 (절제: 강조는 라임 하나)
/// - 토스풍: 넉넉한 여백, 크고 굵은 타이포, 부드러운 라운드
class AppTheme {
  AppTheme._();

  /// 둥근 모서리 토큰
  static const double radius = 16;

  static ThemeData get dark => _dark;
  static ThemeData get light => _light;

  // ---------------------------------------------------------------------------
  // DARK (기본)
  // ---------------------------------------------------------------------------
  static final ThemeData _dark = () {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.lime,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.lime,
      onPrimary: AppColors.background, // 라임 위 텍스트는 검정
      secondary: AppColors.lime,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.surfaceAlt,
      outline: AppColors.outline,
      error: AppColors.error,
    );

    return _base(scheme).copyWith(
      scaffoldBackgroundColor: AppColors.background,
      navigationBarTheme: _navBar(
        background: AppColors.surface,
        unselected: AppColors.textSecondary,
      ),
    );
  }();

  // ---------------------------------------------------------------------------
  // LIGHT
  // ---------------------------------------------------------------------------
  static final ThemeData _light = () {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.lime,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.limeStrong,
      onPrimary: AppColors.lightTextPrimary,
      surface: AppColors.lightBackground,
      onSurface: AppColors.lightTextPrimary,
      surfaceContainerHighest: AppColors.lightSurface,
      outline: AppColors.lightOutline,
      error: AppColors.error,
    );

    return _base(scheme).copyWith(
      scaffoldBackgroundColor: AppColors.lightBackground,
      navigationBarTheme: _navBar(
        background: AppColors.lightBackground,
        unselected: AppColors.lightTextSecondary,
      ),
    );
  }();

  // ---------------------------------------------------------------------------
  // 공통 베이스
  // ---------------------------------------------------------------------------
  static ThemeData _base(ColorScheme scheme) {
    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    // 토스풍: 큰 숫자/타이틀은 굵게 (베이스 텍스트테마 위에 weight만 강조)
    final text = base.textTheme.copyWith(
      displayLarge: base.textTheme.displayLarge?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      displayMedium: base.textTheme.displayMedium?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      displaySmall: base.textTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: base.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );

    return base.copyWith(
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerHighest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size.fromHeight(56), // 토스풍 큰 버튼
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
    );
  }

  static NavigationBarThemeData _navBar({
    required Color background,
    required Color unselected,
  }) {
    return NavigationBarThemeData(
      backgroundColor: background,
      elevation: 0,
      height: 64,
      indicatorColor: AppColors.lime.withValues(alpha: 0.18),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? AppColors.lime : unselected,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? AppColors.lime : unselected,
        );
      }),
    );
  }
}
