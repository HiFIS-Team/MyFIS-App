import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// 운동 루틴 화면.
/// 다크 토스 느낌 미리보기용 샘플 UI (실데이터 연동 전 placeholder).
class RoutineScreen extends StatelessWidget {
  const RoutineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          children: [
            // 인사 — 토스풍 큰 굵은 타이포
            Text('오늘도\n시작해볼까요? 💪', style: textTheme.headlineMedium),
            const SizedBox(height: 28),

            // 오늘의 루틴 카드 — 큰 숫자 강조
            _RoutineCard(textTheme: textTheme),
            const SizedBox(height: 16),

            // 보조 정보 카드 2개
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: '이번 주 출석',
                    value: '4',
                    unit: '일',
                    textTheme: textTheme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: '누적 유산소',
                    value: '12.5',
                    unit: 'km',
                    textTheme: textTheme,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({required this.textTheme});
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '오늘의 추천 루틴',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            // 큰 숫자 — 운동 데이터 = 숫자 강조 (토스 무드 핵심)
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '5',
                  style: textTheme.displayLarge?.copyWith(
                    color: AppColors.lime,
                  ),
                ),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text('개 운동', style: textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '가슴 · 삼두 집중 루틴',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {},
              child: const Text('운동 시작'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.textTheme,
  });

  final String label;
  final String value;
  final String unit;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value, style: textTheme.headlineSmall),
                const SizedBox(width: 3),
                Text(
                  unit,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
