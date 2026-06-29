import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// 홈 - 멤버십 상태 카드.
/// 남은 기간(D-day) + 이용권 종류 + 진행바. 탭하면 멤버십 상세로(추후).
/// 현재는 더미 데이터.
class MembershipCard extends StatelessWidget {
  const MembershipCard({
    super.key,
    this.planName = '3개월권',
    this.daysLeft = 30,
    this.totalDays = 90,
    this.endDateLabel = '2026. 8. 31',
    this.onTap,
  });

  final String planName;
  final int daysLeft;
  final int totalDays;
  final String endDateLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final usedRatio =
        ((totalDays - daysLeft) / totalDays).clamp(0.0, 1.0).toDouble();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단: 라벨 + 이용권 칩
              Row(
                children: [
                  Text(
                    '멤버십',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  _PlanChip(label: planName),
                ],
              ),
              const SizedBox(height: 12),

              // 남은 일수 강조
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('$daysLeft', style: textTheme.headlineMedium),
                  const SizedBox(width: 3),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      '일 남음',
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 진행바 (라임 포인트)
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: usedRatio,
                  minHeight: 6,
                  backgroundColor: AppColors.outline,
                  valueColor: const AlwaysStoppedAnimation(AppColors.lime),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$endDateLabel까지',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanChip extends StatelessWidget {
  const _PlanChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.lime.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.lime,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
