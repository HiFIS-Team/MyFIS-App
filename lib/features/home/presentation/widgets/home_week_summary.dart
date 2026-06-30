import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// 홈 — 달력 밑 운동 요약(웨이트·러닝·칼로리).
/// 한 카드에 세로 구분선으로 3분할. 라벨 + 큰 값 + 작은 보조값(목표/페이스/단위).
/// 러닝 거리·페이스는 런닝머신 연동 예정. 현재는 더미값.
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
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Expanded(
                child: _Stat(label: '웨이트', value: '4회', sub: '목표 5회'),
              ),
              _Divider(),
              Expanded(
                child: _Stat(label: '러닝', value: '12.5km', sub: '이번 주'),
              ),
              _Divider(),
              Expanded(
                child: _Stat(label: '페이스', value: '5\'42"', sub: '/km'),
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
    required this.sub,
  });

  final String label;
  final String value;
  final String sub;

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
          const SizedBox(height: 7),
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            sub,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
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
