import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// 이번 달 출석 달력.
/// 출석한 날은 라임으로 채워 표시, 오늘은 라임 테두리로 강조.
/// attendedDays: 이번 달에 출석한 '일(day)' 집합 (더미).
class AttendanceCalendar extends StatelessWidget {
  const AttendanceCalendar({super.key, required this.attendedDays});

  final Set<int> attendedDays;

  static const List<String> _weekdays = ['일', '월', '화', '수', '목', '금', '토'];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;
    final today = now.day;

    // 1일의 요일(일=0 ~ 토=6) / 이번 달 일수
    final firstColumn = DateTime(year, month, 1).weekday % 7;
    final daysInMonth = DateTime(year, month + 1, 0).day;

    // 셀 구성: 앞쪽 빈칸 + 날짜들 + 마지막 주 빈칸
    final cells = <int?>[];
    for (var i = 0; i < firstColumn; i++) {
      cells.add(null);
    }
    for (var d = 1; d <= daysInMonth; d++) {
      cells.add(d);
    }
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    final weeks = <List<int?>>[
      for (var i = 0; i < cells.length; i += 7) cells.sublist(i, i + 7),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목 + 출석 일수
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$year년 $month월',
                style: textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                '출석 ${attendedDays.length}일',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.lime,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 요일 헤더
          Row(
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Center(
                    child: Text(
                      _weekdays[i],
                      style: textTheme.bodySmall?.copyWith(
                        color: i == 0
                            ? const Color(0xFFFF6B6B) // 일요일
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // 날짜 그리드
          for (final week in weeks)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  for (final day in week)
                    Expanded(child: _dayCell(day, today)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _dayCell(int? day, int today) {
    if (day == null) return const SizedBox(height: 36);

    final attended = attendedDays.contains(day);
    final isToday = day == today;

    return SizedBox(
      height: 36,
      child: Center(
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: attended ? AppColors.lime : Colors.transparent,
            shape: BoxShape.circle,
            border: isToday && !attended
                ? Border.all(color: AppColors.lime, width: 1.5)
                : null,
          ),
          child: Text(
            '$day',
            style: TextStyle(
              color: attended ? AppColors.background : AppColors.textPrimary,
              fontWeight:
                  attended || isToday ? FontWeight.w700 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
