import 'package:flutter/material.dart';

import 'press_fade.dart';

/// 공용 뒤로가기(<) 버튼 — 누르면 아이콘이 살짝 흐려지는 토스식 프레스 피드백.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.onTap, this.color});

  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return PressableIcon(
      icon: Icons.arrow_back_ios_new,
      size: 20,
      color: color,
      onTap: onTap ?? () => Navigator.of(context).maybePop(),
    );
  }
}
