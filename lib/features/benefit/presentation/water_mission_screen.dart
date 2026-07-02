import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../../../shared/widgets/press_fade.dart';

/// 물 마시기 미션 — 물병을 라임 물로 채우는 데일리 트래킹. (현재 더미)
/// '+ 한 컵'을 누르면 물결(wave) 애니메이션과 함께 물이 차오른다.
class WaterMissionScreen extends StatefulWidget {
  const WaterMissionScreen({super.key});

  @override
  State<WaterMissionScreen> createState() => _WaterMissionScreenState();
}

class _WaterMissionScreenState extends State<WaterMissionScreen>
    with SingleTickerProviderStateMixin {
  static const int _goal = 2000; // ml
  static const int _cup = 250; // 한 컵
  static const int _rewardPoints = 10;

  int _amount = 750; // 오늘 마신 양(더미 시작값)

  // 물 표면 물결 위상.
  late final AnimationController _wave = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  )..repeat();

  bool get _done => _amount >= _goal;
  int get _cups => _amount ~/ _cup;
  int get _percent => (_amount / _goal * 100).round().clamp(0, 100);

  @override
  void dispose() {
    _wave.dispose();
    super.dispose();
  }

  void _addCup() {
    if (_done) return;
    setState(() => _amount = math.min(_goal, _amount + _cup));
    if (_done) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.selectionClick();
    }
  }

  void _reset() {
    if (_amount == 0) return;
    setState(() => _amount = 0);
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final fraction = (_amount / _goal).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppTopBar(
        title: '물 마시기',
        actions: [
          PressableIcon(
            icon: Icons.refresh_rounded,
            size: 22,
            color: AppColors.textSecondary,
            onTap: _reset,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // 오늘 마신 양 / 목표
              Text.rich(
                TextSpan(
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                  children: [
                    TextSpan(
                      text: _comma(_amount),
                      style: const TextStyle(color: AppColors.lime),
                    ),
                    TextSpan(
                      text: ' / ${_comma(_goal)}ml',
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
              Text(
                _done ? '오늘 목표를 채웠어요' : '$_percent% 달성 · $_cups컵',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              // 물병 (남는 공간 가운데)
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 140,
                    height: 250,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(end: fraction),
                      duration: const Duration(milliseconds: 640),
                      curve: Curves.easeOutCubic,
                      builder: (context, level, child) => AnimatedBuilder(
                        animation: _wave,
                        builder: (context, _) => CustomPaint(
                          painter: _BottlePainter(
                            level: level,
                            phase: _wave.value,
                          ),
                          size: const Size(140, 250),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 리워드 안내
              Text(
                _done ? '+$_rewardPoints 마일리지 적립 완료' : '목표 달성 시 +$_rewardPoints P',
                style: textTheme.bodyMedium?.copyWith(
                  color: _done ? AppColors.lime : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),

              // 한 컵 추가 버튼
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: _done ? null : _addCup,
                  child: Text(_done ? '오늘 목표 달성' : '+ 한 컵  ${_cup}ml'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 물병 + 라임 물결 페인터.
class _BottlePainter extends CustomPainter {
  _BottlePainter({required this.level, required this.phase});
  final double level; // 0..1 채움 비율
  final double phase; // 0..1 물결 위상

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bodyTop = h * 0.16;

    // 병 실루엣 (몸통 ∪ 목)
    final body = RRect.fromRectAndCorners(
      Rect.fromLTRB(0, bodyTop, w, h),
      topLeft: Radius.circular(w * 0.28),
      topRight: Radius.circular(w * 0.28),
      bottomLeft: Radius.circular(w * 0.22),
      bottomRight: Radius.circular(w * 0.22),
    );
    final neck = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.33, h * 0.035, w * 0.34, h * 0.16),
      Radius.circular(w * 0.05),
    );
    final bottle = Path.combine(
      PathOperation.union,
      Path()..addRRect(body),
      Path()..addRRect(neck),
    );
    final cap = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.35, 0, w * 0.30, h * 0.05),
      Radius.circular(w * 0.04),
    );

    // 병 안쪽 배경(빈 물병)
    canvas.drawPath(bottle, Paint()..color = AppColors.surfaceAlt);

    // 물 (병 몸통에 클립)
    final waterTop = h - level * (h - bodyTop);
    canvas.save();
    canvas.clipPath(Path()..addRRect(body));

    if (level > 0.001) {
      // 뒤 물결 (연한 라임)
      canvas.drawPath(
        _wavePath(w, h, waterTop, phase, amp: 6, waveLen: w * 0.9, off: 1.1),
        Paint()..color = AppColors.lime.withValues(alpha: 0.4),
      );
      // 앞 물결 (라임 그라데이션)
      canvas.drawPath(
        _wavePath(w, h, waterTop, phase, amp: 9, waveLen: w * 0.75, off: 0),
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE4FF8A), AppColors.lime, AppColors.limeStrong],
          ).createShader(Rect.fromLTRB(0, waterTop - 12, w, h)),
      );
    }
    canvas.restore();

    // 왼쪽 유리 하이라이트
    canvas.save();
    canvas.clipPath(Path()..addRRect(body));
    final gloss = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.14, bodyTop + h * 0.06, w * 0.08, h * 0.5),
      Radius.circular(w * 0.04),
    );
    canvas.drawRRect(
      gloss,
      Paint()..color = Colors.white.withValues(alpha: 0.10),
    );
    canvas.restore();

    // 외곽선 + 뚜껑
    canvas.drawPath(
      bottle,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..color = AppColors.lime.withValues(alpha: 0.55),
    );
    canvas.drawRRect(cap, Paint()..color = AppColors.lime);
  }

  Path _wavePath(
    double w,
    double h,
    double top,
    double phase, {
    required double amp,
    required double waveLen,
    required double off,
  }) {
    final path = Path()..moveTo(0, top);
    for (double x = 0; x <= w; x += 4) {
      final y = top +
          amp * math.sin((x / waveLen) * 2 * math.pi + phase * 2 * math.pi + off);
      path.lineTo(x, y);
    }
    path
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    return path;
  }

  @override
  bool shouldRepaint(_BottlePainter old) =>
      old.level != level || old.phase != phase;
}

/// 천 단위 콤마.
String _comma(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}
