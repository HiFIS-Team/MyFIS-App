import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../../../shared/widgets/lime_confetti.dart';
import '../../../shared/widgets/pressable.dart';
import '../../../shared/widgets/reward_capsule.dart';

/// 스트레칭 동작 하나.
class _Pose {
  const _Pose(this.name, this.hint, this.seconds);
  final String name;
  final String hint;
  final int seconds;
}

/// 스트레칭 미션 — 가이드 타이머 링. 동작을 따라 하며 시간을 채운다. (현재 더미)
class StretchMissionScreen extends StatefulWidget {
  const StretchMissionScreen({super.key});

  @override
  State<StretchMissionScreen> createState() => _StretchMissionScreenState();
}

class _StretchMissionScreenState extends State<StretchMissionScreen>
    with TickerProviderStateMixin {
  static const int _rewardPoints = 5;

  static const List<_Pose> _poses = [
    _Pose('목 스트레칭', '고개를 좌우로 천천히', 20),
    _Pose('어깨 풀기', '어깨를 크게 돌려요', 20),
    _Pose('햄스트링', '다리 뒤를 늘려요', 20),
  ];

  int _index = 0;
  bool _running = false;
  bool _done = false;

  // 현재 동작 카운트다운.
  late final AnimationController _timer = AnimationController(
    vsync: this,
    duration: Duration(seconds: _poses[0].seconds),
  );
  // 진행 중 숨쉬는 듯한 미세 펄스.
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  // 완료 폭죽 + 적립 캡슐.
  late final AnimationController _confetti = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );
  List<ConfettiPiece> _confettiPieces = [];
  bool _toastActive = false;
  late final AnimationController _toast = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  );

  _Pose get _pose => _poses[_index];
  bool get _started => _index > 0 || _timer.value > 0;

  @override
  void initState() {
    super.initState();
    _timer.addStatusListener((s) {
      if (s == AnimationStatus.completed) _onPoseDone();
    });
    _toast.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        _toast.reset();
        if (mounted) setState(() => _toastActive = false);
      }
    });
  }

  @override
  void dispose() {
    _timer.dispose();
    _pulse.dispose();
    _confetti.dispose();
    _toast.dispose();
    super.dispose();
  }

  void _start() {
    if (_done) return;
    setState(() => _running = true);
    _timer.forward();
    _pulse.repeat(reverse: true);
  }

  void _pause() {
    setState(() => _running = false);
    _timer.stop();
    _pulse.stop();
  }

  void _onPoseDone() {
    if (_index < _poses.length - 1) {
      // 다음 동작으로
      HapticFeedback.mediumImpact();
      setState(() => _index++);
      _timer.duration = Duration(seconds: _pose.seconds);
      _timer.forward(from: 0);
    } else {
      // 전체 완료
      HapticFeedback.mediumImpact();
      _pulse.stop();
      setState(() {
        _running = false;
        _done = true;
        _toastActive = true;
      });
      _confettiPieces = spawnLimeConfetti();
      _confetti.forward(from: 0);
      _toast.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const AppTopBar(title: '스트레칭'),
      body: Stack(
        children: [
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Text(
                    _done ? '완료' : '${_index + 1}/${_poses.length}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.lime,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _done ? '스트레칭 완료!' : _pose.name,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _done ? '오늘도 몸이 개운해졌어요' : _pose.hint,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),

                  // 타이머 링
                  Expanded(
                    child: Center(
                      child: SizedBox(
                        width: 240,
                        height: 240,
                        child: AnimatedBuilder(
                          animation: Listenable.merge([_timer, _pulse]),
                          builder: (context, _) {
                            final remain = _done
                                ? 0
                                : (_pose.seconds * (1 - _timer.value)).ceil();
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                CustomPaint(
                                  size: const Size(240, 240),
                                  painter: _RingPainter(
                                    progress: _done ? 1 : _timer.value,
                                    pulse: _running ? _pulse.value : 0,
                                  ),
                                ),
                                if (_done)
                                  const Icon(Symbols.check_rounded,
                                      color: AppColors.lime, size: 72, weight: 700)
                                else
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '$remain',
                                          style: textTheme.displayMedium?.copyWith(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '초',
                                          style: textTheme.titleMedium?.copyWith(
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // 동작 진행 점
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < _poses.length; i++)
                        Container(
                          width: 9,
                          height: 9,
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (i < _index || _done)
                                ? AppColors.lime
                                : (i == _index && !_done)
                                    ? AppColors.lime
                                    : AppColors.outline,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 시작/일시정지 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: PressableButton(
                      onPressed: _done ? null : (_running ? _pause : _start),
                      child: Text(
                        _done
                            ? '스트레칭 완료'
                            : (_running
                                ? '일시정지'
                                : (_started ? '이어서 하기' : '시작하기')),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 완료 폭죽
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _confetti,
                builder: (context, _) => CustomPaint(
                  painter: ConfettiPainter(
                    pieces: _confettiPieces,
                    t: _confetti.value,
                  ),
                ),
              ),
            ),
          ),

          // 적립 캡슐
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

/// 원형 타이머 링 — 배경 링 + 라임 진행 아크 + 숨쉬는 내부 글로우.
class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.pulse});
  final double progress; // 0..1
  final double pulse; // 0..1 (0이면 정지)

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const stroke = 12.0;

    // 진행 중 내부 글로우(숨쉬기)
    if (pulse > 0) {
      final glowR = radius * (0.62 + 0.06 * math.sin(pulse * math.pi));
      canvas.drawCircle(
        center,
        glowR,
        Paint()
          ..shader = RadialGradient(
            colors: [
              AppColors.lime.withValues(alpha: 0.16),
              AppColors.lime.withValues(alpha: 0.0),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: glowR)),
      );
    }

    // 배경 링
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = AppColors.surfaceAlt,
    );

    // 진행 아크 (위에서 시계방향)
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        progress * 2 * math.pi,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..color = AppColors.lime,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.pulse != pulse;
}
