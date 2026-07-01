import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/press_fade.dart';

/// 이번 달 출석 달력.
/// - 출석한 날: 덤벨 아이콘 + 라임 날짜
/// - 오늘(미출석): 라임 테두리
/// - 미래 날짜: 흐리게 / 일요일 빨강 · 토요일 파랑
/// - 상단: 연속 출석 스트릭(🔥) + 월 이동(◀▶)
/// attendedDays: 현재(실제) 달에 출석한 '일(day)' 집합 (더미).
class AttendanceCalendar extends StatefulWidget {
  const AttendanceCalendar({super.key, required this.attendedDays});

  final Set<int> attendedDays;

  @override
  State<AttendanceCalendar> createState() => _AttendanceCalendarState();
}

class _AttendanceCalendarState extends State<AttendanceCalendar> {
  static const List<String> _weekdays = ['일', '월', '화', '수', '목', '금', '토'];
  static const Color _sunColor = Color(0xFFFF6B6B);
  static const Color _satColor = Color(0xFF5B9DFF);

  late DateTime _displayed; // 표시 중인 달 (1일 기준)
  late final DateTime _dataMonth; // 데이터가 있는 달(= 현재 달)

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayed = DateTime(now.year, now.month);
    _dataMonth = DateTime(now.year, now.month);
  }

  bool get _isDataMonth =>
      _displayed.year == _dataMonth.year && _displayed.month == _dataMonth.month;

  Set<int> get _attended => _isDataMonth ? widget.attendedDays : const {};

  void _prevMonth() => setState(() {
        _displayed = DateTime(_displayed.year, _displayed.month - 1);
      });

  void _nextMonth() => setState(() {
        _displayed = DateTime(_displayed.year, _displayed.month + 1);
      });

  /// 오늘 기준 연속 출석 일수 (현재 달 데이터 기준).
  int get _streak {
    final today = _dataMonth == DateTime(DateTime.now().year, DateTime.now().month)
        ? DateTime.now().day
        : 0;
    var streak = 0;
    for (var d = today; d >= 1; d--) {
      if (widget.attendedDays.contains(d)) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  /// 해당 날짜가 미래인지 (흐리게 처리용).
  bool _isFuture(int day) {
    if (_displayed.isAfter(_dataMonth)) return true;
    if (_displayed.isBefore(_dataMonth)) return false;
    return day > DateTime.now().day; // 현재 달
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final year = _displayed.year;
    final month = _displayed.month;
    final today = _isDataMonth ? DateTime.now().day : -1;

    final firstColumn = DateTime(year, month, 1).weekday % 7; // 일=0
    final daysInMonth = DateTime(year, month + 1, 0).day;

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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목(가운데) + 월 이동 / 스트릭(오른쪽)
          SizedBox(
            width: double.infinity,
            height: 36,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 가운데: ‹ 2026년 6월 ›
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _NavButton(icon: Icons.chevron_left, onTap: _prevMonth),
                    const SizedBox(width: 2),
                    Text(
                      '$year년 $month월',
                      style: textTheme.titleLarge?.copyWith(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 2),
                    _NavButton(icon: Icons.chevron_right, onTap: _nextMonth),
                  ],
                ),
                // 오른쪽: 스트릭 배지
                if (_streak > 0)
                  Align(
                    alignment: Alignment.centerRight,
                    child: _StreakBadge(days: _streak),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 요일 헤더
          Row(
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Center(
                    child: Text(
                      _weekdays[i],
                      style: textTheme.bodySmall?.copyWith(
                        color: _weekdayColor(i),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),

          // 날짜 그리드
          for (final week in weeks)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  for (var col = 0; col < 7; col++)
                    Expanded(child: _dayCell(week[col], col, today)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _weekdayColor(int col) {
    if (col == 0) return _sunColor;
    if (col == 6) return _satColor;
    return AppColors.textSecondary;
  }

  Widget _dayCell(int? day, int col, int today) {
    if (day == null) return const SizedBox(height: 44);

    final attended = _attended.contains(day);
    final isToday = day == today;
    final isFuture = _isFuture(day);

    // 출석한 날 — 날짜는 가운데(다른 날과 같은 위치), 덤벨은 위 작은 표시.
    // 탭하면 그날 운동 기록 페이지로 진입.
    if (attended) {
      return PressFade(
        onTap: () => context.push(
          '/attendance-day',
          extra: '${_displayed.month}월 $day일',
        ),
        child: SizedBox(
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                '$day',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const Positioned(
                top: 2,
                child: Icon(Icons.fitness_center,
                    color: AppColors.textSecondary, size: 13),
              ),
            ],
          ),
        ),
      );
    }

    // 미출석 — 요일색(+미래 흐리게), 오늘은 라임 테두리
    final base = col == 0
        ? _sunColor
        : col == 6
            ? _satColor
            : AppColors.textPrimary;
    final color = isFuture ? base.withValues(alpha: 0.30) : base;

    return SizedBox(
      height: 44,
      child: Center(
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: isToday
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.textPrimary, width: 1.5),
                )
              : null,
          child: Text(
            '$day',
            style: TextStyle(
              color: isToday ? AppColors.textPrimary : color,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

/// 월 이동 버튼.
class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressFade(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: AppColors.textSecondary, size: 24),
      ),
    );
  }
}

/// 연속 출석 스트릭 배지.
class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.days});
  final int days;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department,
              color: AppColors.textSecondary, size: 16),
          const SizedBox(width: 4),
          Text(
            '$days일 연속',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
