import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_top_bar.dart';

/// 출석 내역 — 통계 요약 + GitHub식 잔디 히트맵(최근 6개월).
/// 홈 달력이 '이번 달'만 본다면, 여기선 여러 달 꾸준함을 라임 농도로 한눈에 본다.
/// 데이터는 더미(결정적). 추후 서버 출석 로그로 교체.
class AttendanceHistoryScreen extends StatelessWidget {
  const AttendanceHistoryScreen({super.key});

  // 홈 달력과 맞춘 이번 달 출석일.
  static const Set<int> _thisMonthDays = {
    2, 5, 8, 12, 15, 18, 23, 25, 26, 27, 28, 29
  };

  static const int _weeks = 26; // 약 6개월

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // 이번 달을 온전히 보여주기 위해 그리드 끝을 '이번 달 말일'이 속한 주로.
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    final endWeekday = monthEnd.weekday % 7; // 0=일 … 6=토
    final lastSaturday = monthEnd.add(Duration(days: 6 - endWeekday));
    final firstSunday =
        lastSaturday.subtract(const Duration(days: _weeks * 7 - 1));

    // 통계 계산.
    var thisMonth = 0;
    var total = 0;
    var bestStreak = 0;
    var run = 0;
    for (var i = 0; i < _weeks * 7; i++) {
      final d = firstSunday.add(Duration(days: i));
      final lv = _level(d, now);
      if (lv > 0) {
        total++;
        run++;
        if (run > bestStreak) bestStreak = run;
        if (d.year == now.year && d.month == now.month) thisMonth++;
      } else {
        run = 0;
      }
    }

    return Scaffold(
      appBar: const AppTopBar(title: '출석 내역'),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            // 통계 요약 카드
            Container(
              padding: const EdgeInsets.symmetric(vertical: 22),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                        child: _Stat(value: '$thisMonth', unit: '회', label: '이번 달')),
                    const _StatDivider(),
                    Expanded(
                      child: _Stat(
                          value: '$bestStreak',
                          unit: '일',
                          label: '최고 연속',
                          fire: true),
                    ),
                    const _StatDivider(),
                    Expanded(
                        child: _Stat(value: '$total', unit: '회', label: '누적 출석')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),

            // 잔디 히트맵
            _SectionLabel('최근 6개월'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _Heatmap(
                    firstSunday: firstSunday,
                    weeks: _weeks,
                    now: now,
                    level: _level,
                  ),
                  const SizedBox(height: 14),
                  const _Legend(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 날짜별 출석 강도(0=미출석, 1~4). 이번 달은 홈과 동일, 과거는 결정적 패턴.
  static int _level(DateTime d, DateTime now) {
    if (d.year == now.year && d.month == now.month) {
      return _thisMonthDays.contains(d.day) ? 1 + (d.day % 4) : 0;
    }
    // 미래 달은 비움.
    if (d.isAfter(DateTime(now.year, now.month + 1, 0))) return 0;
    final h = d.year * 372 + d.month * 31 + d.day;
    final r = (h * 1103515245 + 12345) % 100;
    final rr = r < 0 ? r + 100 : r;
    if (rr < 44) return 0; // 약 56% 출석
    return 1 + (rr % 4);
  }
}

/// 잔디 히트맵 — 주=열, 요일=행. 가로 스크롤(최신이 오른쪽).
class _Heatmap extends StatelessWidget {
  const _Heatmap({
    required this.firstSunday,
    required this.weeks,
    required this.now,
    required this.level,
  });

  final DateTime firstSunday;
  final int weeks;
  final DateTime now;
  final int Function(DateTime, DateTime) level;

  static const double _cell = 14;
  static const double _gap = 4;
  static const List<String> _wd = ['', '월', '', '수', '', '금', ''];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final labelStyle = textTheme.labelSmall
        ?.copyWith(color: AppColors.textSecondary, fontSize: 10);

    // 월 라벨 — 각 주(열)의 첫날(일요일) 기준, 달이 바뀌는 열에 표시.
    final monthLabels = <int, String>{};
    var prevMonth = -1;
    for (var w = 0; w < weeks; w++) {
      final colDate = firstSunday.add(Duration(days: w * 7));
      if (colDate.month != prevMonth) {
        monthLabels[w] = '${colDate.month}월';
        prevMonth = colDate.month;
      }
    }

    // 요일 라벨 열
    final weekdayCol = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16), // 월 라벨 줄 높이만큼
        for (var r = 0; r < 7; r++)
          Container(
            height: _cell,
            margin: const EdgeInsets.only(bottom: _gap),
            alignment: Alignment.centerLeft,
            child: Text(_wd[r], style: labelStyle),
          ),
      ],
    );

    // 주 열들
    final columns = <Widget>[];
    for (var w = 0; w < weeks; w++) {
      final cells = <Widget>[];
      for (var r = 0; r < 7; r++) {
        final d = firstSunday.add(Duration(days: w * 7 + r));
        final lv = level(d, now);
        cells.add(Container(
          width: _cell,
          height: _cell,
          margin: const EdgeInsets.only(bottom: _gap),
          decoration: BoxDecoration(
            color: _cellColor(lv),
            borderRadius: BorderRadius.circular(3),
          ),
        ));
      }
      columns.add(Container(
        margin: const EdgeInsets.only(right: _gap),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 16,
              width: _cell,
              child: monthLabels.containsKey(w)
                  ? OverflowBox(
                      maxWidth: 40,
                      alignment: Alignment.centerLeft,
                      child: Text(monthLabels[w]!, style: labelStyle),
                    )
                  : null,
            ),
            ...cells,
          ],
        ),
      ));
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        weekdayCol,
        const SizedBox(width: 6),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true, // 최신(오른쪽)에 앵커
            child: Row(children: columns),
          ),
        ),
      ],
    );
  }
}

/// 강도별 셀 색 — 라임 농도.
Color _cellColor(int lv) {
  switch (lv) {
    case 1:
      return AppColors.lime.withValues(alpha: 0.30);
    case 2:
      return AppColors.lime.withValues(alpha: 0.52);
    case 3:
      return AppColors.lime.withValues(alpha: 0.74);
    case 4:
      return AppColors.lime;
    default:
      return AppColors.surfaceAlt;
  }
}

/// 히트맵 범례 — 적음 ▫▪▪▪ 많음.
class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context)
        .textTheme
        .labelSmall
        ?.copyWith(color: AppColors.textSecondary, fontSize: 10);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('적음', style: labelStyle),
        const SizedBox(width: 6),
        for (var lv = 0; lv <= 4; lv++) ...[
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _cellColor(lv),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 3),
        ],
        const SizedBox(width: 3),
        Text('많음', style: labelStyle),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.value,
    required this.unit,
    required this.label,
    this.fire = false,
  });

  final String value;
  final String unit;
  final String label;
  final bool fire;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: textTheme.headlineSmall?.copyWith(
                color: AppColors.lime,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              unit,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.lime,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (fire) ...[
              const SizedBox(width: 2),
              const Icon(Symbols.local_fire_department,
                  color: AppColors.lime, size: 16, fill: 1),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: AppColors.outline,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
