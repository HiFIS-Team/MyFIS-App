import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/pressable.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../../../shared/widgets/reward_capsule.dart';

/// 체중 기록 미션 — 라임 추세 그래프 + 눈금자 입력. (현재 더미)
/// 오늘 체중을 기록하면 마일리지를 받는다.
class WeightMissionScreen extends StatefulWidget {
  const WeightMissionScreen({super.key});

  @override
  State<WeightMissionScreen> createState() => _WeightMissionScreenState();
}

class _WeightMissionScreenState extends State<WeightMissionScreen>
    with SingleTickerProviderStateMixin {
  static const int _rewardPoints = 5;

  // 최근 기록(오래된→최신), 마지막이 가장 최근 체중. (더미)
  final List<double> _entries = [70.2, 69.9, 70.0, 69.6, 69.3, 69.1, 68.8, 68.5];
  bool _recordedToday = false;

  // 위에서 내려오는 적립 캡슐.
  bool _toastActive = false;
  late final AnimationController _toast = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  );

  double get _current => _entries.last;
  double get _delta => _entries.last - _entries.first;

  @override
  void initState() {
    super.initState();
    _toast.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        _toast.reset();
        if (mounted) setState(() => _toastActive = false);
      }
    });
  }

  @override
  void dispose() {
    _toast.dispose();
    super.dispose();
  }

  Future<void> _openInput() async {
    final result = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WeightInputSheet(initial: _current),
    );
    if (result != null) _record(result);
  }

  void _record(double weight) {
    setState(() {
      _entries.add(weight);
      _recordedToday = true;
      _toastActive = true;
    });
    HapticFeedback.mediumImpact();
    _toast.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final down = _delta <= 0;

    return Scaffold(
      appBar: const AppTopBar(title: '체중 기록'),
      body: Stack(
        children: [
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    _recordedToday ? '오늘 체중' : '최근 체중',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // 큰 현재 체중
                  Text.rich(
                    TextSpan(
                      style: textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.5,
                        color: AppColors.lime,
                      ),
                      children: [
                        TextSpan(text: _current.toStringAsFixed(1)),
                        TextSpan(
                          text: ' kg',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  // 기간 변화
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '지난 30일 ',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Icon(
                        down ? Icons.south_rounded : Icons.north_rounded,
                        size: 15,
                        color: down ? AppColors.lime : AppColors.textSecondary,
                      ),
                      Text(
                        '${_delta.abs().toStringAsFixed(1)}kg',
                        style: textTheme.bodyMedium?.copyWith(
                          color: down ? AppColors.lime : AppColors.textSecondary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),

                  // 추세 그래프
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: LayoutBuilder(
                        builder: (context, c) => CustomPaint(
                          size: Size(c.maxWidth, c.maxHeight),
                          painter: _WeightChart(entries: _entries),
                        ),
                      ),
                    ),
                  ),

                  Text(
                    '최근 ${_entries.length}회 기록',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 기록 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: PressableButton(
                      onPressed: _recordedToday ? null : _openInput,
                      child: Text(
                        _recordedToday ? '오늘 기록 완료' : '오늘 체중 기록하기',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 적립 캡슐 토스트
          if (_toastActive)
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _toast,
                builder: (context, child) => TopToast(
                  progress: _toast.value,
                  child: child!,
                ),
                child: Center(
                  child: RewardCapsule(text: '$_rewardPoints 마일리지 받았어요!'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 라임 추세 꺾은선 그래프 — 영역 그라데이션 + 라인 + 점, 마지막(오늘) 강조.
class _WeightChart extends CustomPainter {
  _WeightChart({required this.entries});
  final List<double> entries;

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.length < 2) return;

    const padTop = 14.0;
    const padBottom = 10.0;
    final n = entries.length;

    final minW = entries.reduce(math.min);
    final maxW = entries.reduce(math.max);
    final span = (maxW - minW).abs();
    final pad = span < 0.1 ? 0.5 : span * 0.35;
    final lo = minW - pad;
    final hi = maxW + pad;

    double xAt(int i) => i / (n - 1) * size.width;
    double yAt(double w) {
      final t = (w - lo) / (hi - lo);
      return padTop + (1 - t) * (size.height - padTop - padBottom);
    }

    final points = [
      for (var i = 0; i < n; i++) Offset(xAt(i), yAt(entries[i])),
    ];

    // 라인 경로
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < n; i++) {
      final prev = points[i - 1];
      final cur = points[i];
      final midX = (prev.dx + cur.dx) / 2;
      linePath.cubicTo(midX, prev.dy, midX, cur.dy, cur.dx, cur.dy);
    }

    // 영역 채움 (라인 아래)
    final areaPath = Path.from(linePath)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();
    canvas.drawPath(
      areaPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.lime.withValues(alpha: 0.28),
            AppColors.lime.withValues(alpha: 0.0),
          ],
        ).createShader(Offset.zero & size),
    );

    // 라인
    canvas.drawPath(
      linePath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.lime,
    );

    // 중간 점들
    for (var i = 0; i < n - 1; i++) {
      canvas.drawCircle(
        points[i],
        3,
        Paint()..color = AppColors.lime.withValues(alpha: 0.7),
      );
    }

    // 마지막(오늘) 점 강조 + 값 라벨
    final last = points.last;
    canvas.drawCircle(last, 9, Paint()..color = AppColors.lime.withValues(alpha: 0.22));
    canvas.drawCircle(last, 5.5, Paint()..color = AppColors.lime);
    canvas.drawCircle(
      last,
      5.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppColors.background,
    );

    final label = TextPainter(
      text: TextSpan(
        text: entries.last.toStringAsFixed(1),
        style: const TextStyle(
          color: AppColors.lime,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    var lx = last.dx - label.width / 2;
    lx = lx.clamp(0.0, size.width - label.width);
    final ly = (last.dy - 22).clamp(0.0, size.height);
    label.paint(canvas, Offset(lx, ly));
  }

  @override
  bool shouldRepaint(_WeightChart old) => old.entries != entries;
}

/// 눈금자 입력 바텀시트 — 가로 눈금자를 밀어 오늘 체중을 맞춘다.
class _WeightInputSheet extends StatefulWidget {
  const _WeightInputSheet({required this.initial});
  final double initial;

  @override
  State<_WeightInputSheet> createState() => _WeightInputSheetState();
}

class _WeightInputSheetState extends State<_WeightInputSheet> {
  late double _value = widget.initial;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outline,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '오늘 체중',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              style: textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -1.5,
                color: AppColors.lime,
              ),
              children: [
                TextSpan(text: _value.toStringAsFixed(1)),
                TextSpan(
                  text: ' kg',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Ruler(
            value: _value,
            onChanged: (v) => setState(() => _value = v),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: PressableButton(
              onPressed: () => Navigator.of(context)
                  .pop(double.parse(_value.toStringAsFixed(1))),
              child: const Text('기록하고 +5P'),
            ),
          ),
        ],
      ),
    );
  }
}

/// 가로 눈금자 — 드래그로 값 조정, 0.1kg마다 햅틱.
class _Ruler extends StatefulWidget {
  const _Ruler({required this.value, required this.onChanged});
  final double value;
  final ValueChanged<double> onChanged;

  static const double _min = 30;
  static const double _max = 200;

  @override
  State<_Ruler> createState() => _RulerState();
}

class _RulerState extends State<_Ruler> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final width = c.maxWidth;
        final pxPerKg = width / 6; // 화면에 6kg 보이도록
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanUpdate: (d) {
            var v = widget.value - d.delta.dx / pxPerKg;
            v = v.clamp(_Ruler._min, _Ruler._max);
            if ((v * 10).round() != (widget.value * 10).round()) {
              HapticFeedback.selectionClick();
            }
            widget.onChanged(double.parse(v.toStringAsFixed(2)));
          },
          child: CustomPaint(
            size: Size(width, 88),
            painter: _RulerPainter(value: widget.value, pxPerKg: pxPerKg),
          ),
        );
      },
    );
  }
}

class _RulerPainter extends CustomPainter {
  _RulerPainter({required this.value, required this.pxPerKg});
  final double value;
  final double pxPerKg;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    const top = 8.0;

    final startTenth = ((value - 3.2) * 10).floor();
    final endTenth = ((value + 3.2) * 10).ceil();

    for (var tenth = startTenth; tenth <= endTenth; tenth++) {
      final t = tenth / 10.0;
      final x = cx + (t - value) * pxPerKg;
      if (x < 0 || x > size.width) continue;

      final whole = tenth % 10 == 0;
      final half = tenth % 5 == 0;
      final len = whole ? 30.0 : (half ? 20.0 : 12.0);
      final color = whole
          ? AppColors.textPrimary
          : AppColors.textSecondary.withValues(alpha: half ? 0.6 : 0.3);

      canvas.drawLine(
        Offset(x, top),
        Offset(x, top + len),
        Paint()
          ..color = color
          ..strokeWidth = whole ? 2 : 1,
      );

      if (whole) {
        final tp = TextPainter(
          text: TextSpan(
            text: '${tenth ~/ 10}',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x - tp.width / 2, top + 38));
      }
    }

    // 가운데 포인터 (라임)
    canvas.drawLine(
      Offset(cx, 0),
      Offset(cx, top + 34),
      Paint()
        ..color = AppColors.lime
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RulerPainter old) =>
      old.value != value || old.pxPerKg != pxPerKg;
}
