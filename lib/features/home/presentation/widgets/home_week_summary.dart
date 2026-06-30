import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// 홈 — 달력 밑 운동 요약(주간 목표 진행바).
/// 웨이트는 추천 루틴 횟수, 러닝은 거리(런닝머신 연동), 칼로리는 소모량을
/// 각각 주간 목표 대비 진행바로 보여준다. 현재는 더미값.
class HomeWeekSummary extends StatelessWidget {
  const HomeWeekSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _Stat(
                  label: '웨이트',
                  value: '4',
                  goal: '/ 5회',
                  ratio: 4 / 5,
                ),
              ),
              _Divider(),
              Expanded(
                child: _Stat(
                  label: '러닝',
                  value: '12.5',
                  goal: '/ 15km',
                  ratio: 12.5 / 15,
                ),
              ),
              _Divider(),
              Expanded(
                child: _Stat(
                  label: '칼로리',
                  value: '1,860',
                  goal: '/ 2,500',
                  ratio: 1860 / 2500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.goal,
    required this.ratio,
  });

  final String label;
  final String value;
  final String goal;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          // 칸 너비를 넘으면 값+목표를 통째로 축소
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    goal,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // 진행바
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Stack(
              children: [
                Container(height: 5, color: AppColors.surfaceAlt),
                FractionallySizedBox(
                  widthFactor: ratio.clamp(0.0, 1.0),
                  child: Container(height: 5, color: AppColors.lime),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, color: AppColors.outline);
  }
}
