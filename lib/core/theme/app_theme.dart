import 'package:flutter/material.dart';

/// 앱 전역 테마 정의.
/// 헬스/피트니스 느낌의 에너제틱한 컬러를 시드로 사용한다.
class AppTheme {
  static const Color _seedColor = Color(0xFF2E7D32); // 그린 계열

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: brightness,
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(centerTitle: true),
    );
  }
}
