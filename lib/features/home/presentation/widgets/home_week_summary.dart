import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_colors.dart';

/// 홈 — 달력 밑 "이번 주 운동" 요약(웨이트·유산소·칼로리 3분할).
/// 현재는 더미 통계.
class HomeWeekSummary extends StatelessWidget {
  const HomeWeekSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '이번 주 운동',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Symbols.exercise,
                  value: '4회',
                  label: '웨이트',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  icon: Symbols.directions_run,
                  value: '120분',
                  label: '유산소',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  icon: Symbols.local_fire_department,
                  value: '1,860',
                  label: 'kcal',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppColors.textSecondary, fill: 1),
          const SizedBox(height: 14),
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
