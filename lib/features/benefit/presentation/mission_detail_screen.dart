import 'package:flutter/material.dart';

import '../../../shared/widgets/app_top_bar.dart';

/// 매일 미션 상세 — 재구상 중(placeholder).
/// 혜택 탭에서 "방문하기"를 누르면 진입. 본문은 추후 설계.
class MissionDetailScreen extends StatelessWidget {
  const MissionDetailScreen({super.key, this.title = '미션'});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(title: title),
      body: const SizedBox.shrink(),
    );
  }
}
