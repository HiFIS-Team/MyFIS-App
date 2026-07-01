import 'package:flutter/material.dart';

import '../../../shared/widgets/app_top_bar.dart';

/// 출석한 날 상세 — 재구상 중(placeholder).
/// 달력에서 출석한 날(덤벨)을 누르면 진입. 그날 운동 기록 등 추후 설계.
class AttendanceDayScreen extends StatelessWidget {
  const AttendanceDayScreen({super.key, this.title = '운동 기록'});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(title: title),
      body: const SizedBox.shrink(),
    );
  }
}
