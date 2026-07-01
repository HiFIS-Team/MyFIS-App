import 'package:flutter/material.dart';

/// 디자인 토큰 - 컬러.
/// 다크 토스(Dark Toss) 방향: 검정 베이스 + 일렉트릭 라임 포인트.
/// 자세한 배경은 .claude/design.md 참고.
class AppColors {
  AppColors._();

  // === 브랜드 포인트 ===
  /// 일렉트릭 라임 (메인 포인트 컬러) — 노랑의 프리미엄/테크 진화
  static const Color lime = Color(0xFFD7FC51);
  static const Color limeStrong = Color(0xFFB8E02E);

  // === 다크 베이스 (토스식: 배경 순검정 + 카드는 그 위에 뜨는 회색) ===
  static const Color background = Color(0xFF000000); // 순검정 페이지
  static const Color surface = Color(0xFF141414); // 카드/시트 (덜 떠 보이게 어둡게)
  static const Color surfaceAlt = Color(0xFF202020); // 한 단계 밝은 카드/중첩 요소
  static const Color outline = Color(0xFF2A2A2A); // 경계선

  // === 다크 텍스트 ===
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9DA0A4); // 보조 텍스트(회색)

  // === 라이트 베이스 (라이트 모드용) ===
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF7F8FA);
  static const Color lightOutline = Color(0xFFE5E8EB);
  static const Color lightTextPrimary = Color(0xFF191F28); // 토스풍 짙은 네이비
  static const Color lightTextSecondary = Color(0xFF8B95A1);

  // === 공통 ===
  static const Color error = Color(0xFFFF5252);
}
