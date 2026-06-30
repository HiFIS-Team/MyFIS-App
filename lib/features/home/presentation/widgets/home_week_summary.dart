import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// 홈 — 달력 밑 운동 요약(웨이트·유산소·칼로리).
/// 한 카드에 세로 구분선으로 3분할. 현재는 더미 통계.
class HomeWeekSummary extends StatelessWidget {
  const HomeWeekSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            Expanded(child: _Stat(title: '웨이트', value: '4회')),
            _Divider(),
            Expanded(child: _Stat(title: '유산소', value: '120분')),
            _Divider(),
            Expanded(child: _Stat(title: '칼로리', value: '1,860')),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(
          title,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: AppColors.outline);
  }
}
