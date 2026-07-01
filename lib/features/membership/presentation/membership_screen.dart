import 'package:flutter/material.dart';

import '../../../shared/widgets/app_top_bar.dart';

/// 멤버십 화면 — 재구상 중(placeholder).
/// 기존 등급/혜택/관리 구현은 git 이력 참고. 본문은 추후 다시 설계.
class MembershipScreen extends StatelessWidget {
  const MembershipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppTopBar(title: '멤버십'),
      body: SizedBox.shrink(),
    );
  }
}
