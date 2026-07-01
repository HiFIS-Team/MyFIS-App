import 'package:flutter/material.dart';

import 'app_back_button.dart';

/// 푸시 화면 공통 헤더 — 뒤로가기 + 제목(+선택 액션).
/// 알림·출석·멤버십 등 모든 진입 화면에서 동일한 위치/크기로 보이게 한다.
/// 제목 스타일은 테마 appBarTheme.titleTextStyle을 따른다.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.actions,
    this.onBack,
    this.primary = true,
  });

  final String title;
  final List<Widget>? actions;
  final VoidCallback? onBack;

  /// Scaffold.appBar로 쓸 땐 true(상태바 패딩 포함),
  /// 이미 SafeArea 안에서 직접 배치할 땐 false.
  final bool primary;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      primary: primary,
      centerTitle: true,
      leading: AppBackButton(onTap: onBack),
      title: Text(title),
      actions: actions,
    );
  }
}
