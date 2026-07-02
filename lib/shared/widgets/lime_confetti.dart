import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

const List<Color> _confettiColors = [
  AppColors.lime,
  AppColors.limeStrong,
  Color(0xFFEBFFA6), // 밝은 라임
  Color(0xFFFFFFFF), // 하이라이트 소량
];

/// 폭죽 조각 하나 (하늘에서 떨어지는 라임 종이).
class ConfettiPiece {
  const ConfettiPiece({
    required this.x0,
    required this.delay,
    required this.speed,
    required this.driftAmp,
    required this.driftFreq,
    required this.driftPhase,
    required this.size,
    required this.rot0,
    required this.rotSpeed,
    required this.color,
    required this.round,
  });

  final double x0; // 시작 가로 위치 (0..1)
  final double delay; // 낙하 시작 지연 (0..1)
  final double speed; // 낙하 속도 배수
  final double driftAmp; // 좌우 흔들림 폭(px)
  final double driftFreq; // 좌우 흔들림 빈도
  final double driftPhase;
  final double size;
  final double rot0;
  final double rotSpeed;
  final Color color;
  final bool round; // true=원, false=직사각 조각
}

/// 라임 폭죽 조각들을 랜덤 생성. [seedTick]을 넣으면 매번 다른 패턴.
List<ConfettiPiece> spawnLimeConfetti({int count = 46, int seedTick = 0}) {
  final rnd = math.Random();
  return List.generate(count, (i) {
    return ConfettiPiece(
      x0: rnd.nextDouble(),
      delay: rnd.nextDouble() * 0.35,
      speed: 0.85 + rnd.nextDouble() * 0.55,
      driftAmp: 10 + rnd.nextDouble() * 28,
      driftFreq: 1 + rnd.nextDouble() * 2,
      driftPhase: rnd.nextDouble() * math.pi * 2,
      size: 6 + rnd.nextDouble() * 7,
      rot0: rnd.nextDouble() * math.pi * 2,
      rotSpeed: (rnd.nextDouble() * 2 - 1) * 6,
      color: _confettiColors[rnd.nextInt(_confettiColors.length)],
      round: rnd.nextDouble() < 0.35,
    );
  });
}

/// 하늘에서 떨어지는 라임 폭죽 페인터. [t]는 0..1 진행도.
class ConfettiPainter extends CustomPainter {
  ConfettiPainter({required this.pieces, required this.t});
  final List<ConfettiPiece> pieces;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0) return;
    for (final p in pieces) {
      final ct = ((t - p.delay) / (1 - p.delay));
      if (ct <= 0) continue;
      final c = ct.clamp(0.0, 1.0);

      final y = -40 + c * p.speed * (size.height + 80);
      if (y > size.height + 40) continue;
      final x = p.x0 * size.width +
          math.sin(c * p.driftFreq * 2 * math.pi + p.driftPhase) * p.driftAmp;

      // 등장 시 페이드인, 후반부 페이드아웃
      final op = c < 0.08
          ? c / 0.08
          : (c > 0.85 ? (1 - (c - 0.85) / 0.15) : 1.0);
      final paint = Paint()
        ..color = p.color.withValues(alpha: op.clamp(0.0, 1.0));

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rot0 + c * p.rotSpeed);
      if (p.round) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset.zero, width: p.size, height: p.size * 0.5),
            const Radius.circular(2),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.pieces != pieces;
}
