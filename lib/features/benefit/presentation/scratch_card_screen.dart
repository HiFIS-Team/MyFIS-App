import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_top_bar.dart';

/// 카드 진행 단계.
/// intro: 세로 카드가 3D로 회전 → flipping: 눌러서 가로로 눕는 전환 → scratch: 긁기.
enum _CardPhase { intro, flipping, scratch }

/// 카드 긁기 — 복권식 스크래치 카드.
/// 은박(포일)을 손가락으로 긁으면 랜덤 마일리지가 드러난다. (현재 더미)
class ScratchCardScreen extends StatefulWidget {
  const ScratchCardScreen({super.key});

  @override
  State<ScratchCardScreen> createState() => _ScratchCardScreenState();
}

class _ScratchCardScreenState extends State<ScratchCardScreen>
    with TickerProviderStateMixin {
  // 당첨 마일리지 후보 (값: 가중치) — 복권처럼 소액이 흔하고 큰 값은 희귀.
  static const Map<int, int> _prizeWeights = {
    10: 28,
    20: 24,
    30: 18,
    50: 14,
    100: 9,
    300: 5,
    500: 2,
  };

  // 긁힘 감지용 그리드 해상도.
  static const int _cols = 24;
  static const int _rows = 15;

  // 가운데 당첨(마일리지) 영역 — 이 부분이 드러나면 나머지와 상관없이 자동 공개.
  static const int _rcLo = 6, _rcHi = 18; // 열 6~17
  static const int _rrLo = 5, _rrHi = 12; // 행 5~11
  static const int _prizeCells = (_rcHi - _rcLo) * (_rrHi - _rrLo);
  static const double _revealThreshold = 0.5; // 당첨 영역의 절반이 긁히면 공개

  late final int _prize = _pickPrize();
  final Set<int> _prizeHit = {};
  final List<Offset?> _strokes = [];
  Size _cardSize = Size.zero;
  int _hapticTick = 0;
  bool _revealed = false;
  bool _claimed = false;

  // 인트로: 세로 카드가 계속 도는 상태 → 누르면 가로 스크래치 카드로 눕는다.
  _CardPhase _phase = _CardPhase.intro;
  double _spinAtTap = 0; // 눌린 순간의 회전각(이어서 정면으로 마무리)

  late final AnimationController _idle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3400),
  )..repeat();
  late final AnimationController _flip = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 780),
  );

  // 포일이 스르륵 사라지는 페이드 + 당첨 숫자 통통 팝.
  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 620),
  );

  // 공개 순간 하늘에서 떨어지는 라임 폭죽.
  late final AnimationController _confetti = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );
  final List<_Confetti> _confettiPieces = [];

  static const List<Color> _confettiColors = [
    AppColors.lime,
    AppColors.limeStrong,
    Color(0xFFEBFFA6), // 밝은 라임
    Color(0xFFFFFFFF), // 하이라이트 소량
  ];

  int _pickPrize() {
    final total = _prizeWeights.values.reduce((a, b) => a + b);
    var roll = math.Random().nextInt(total);
    for (final entry in _prizeWeights.entries) {
      if (roll < entry.value) return entry.key;
      roll -= entry.value;
    }
    return _prizeWeights.keys.first;
  }

  @override
  void initState() {
    super.initState();
    _flip.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        setState(() => _phase = _CardPhase.scratch);
      }
    });
  }

  @override
  void dispose() {
    _idle.dispose();
    _flip.dispose();
    _fade.dispose();
    _pop.dispose();
    _confetti.dispose();
    super.dispose();
  }

  // 카드를 눌러 세로→가로로 눕히는 전환 시작.
  void _startFlip() {
    if (_phase != _CardPhase.intro) return;
    HapticFeedback.selectionClick();
    _spinAtTap = (_idle.value * 2 * math.pi) % (2 * math.pi);
    _idle.stop();
    setState(() => _phase = _CardPhase.flipping);
    _flip.forward(from: 0);
  }

  void _addPoint(Offset local) {
    if (_revealed || _cardSize == Size.zero) return;
    setState(() => _strokes.add(local));

    final col =
        (local.dx / _cardSize.width * _cols).floor().clamp(0, _cols - 1);
    final row =
        (local.dy / _cardSize.height * _rows).floor().clamp(0, _rows - 1);

    // 긁는 느낌의 가벼운 햅틱 (너무 잦지 않게 스로틀).
    if (_hapticTick++ % 6 == 0) HapticFeedback.selectionClick();

    // 가운데 마일리지 영역이 충분히 드러나면 나머지와 상관없이 공개.
    final inPrize =
        col >= _rcLo && col < _rcHi && row >= _rrLo && row < _rrHi;
    if (inPrize) {
      _prizeHit.add(row * _cols + col);
      if (_prizeHit.length / _prizeCells >= _revealThreshold) _reveal();
    }
  }

  void _reveal() {
    if (_revealed) return;
    setState(() => _revealed = true);
    HapticFeedback.mediumImpact();
    _fade.forward();
    _pop.forward();
    _spawnConfetti();
    _confetti.forward(from: 0);
  }

  void _spawnConfetti() {
    final rnd = math.Random();
    _confettiPieces
      ..clear()
      ..addAll(List.generate(46, (_) {
        return _Confetti(
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
      }));
  }

  void _claim() {
    if (_claimed) return;
    setState(() => _claimed = true);
    HapticFeedback.lightImpact();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const AppTopBar(title: '카드 긁기'),
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
                _title,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _subtitle,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),

              // 카드 (남는 공간 가운데) — 인트로엔 세로로 회전, 누르면 가로로 눕는다.
              Expanded(
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) => _buildCardArea(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    ),
                  ),
                ),
              ),

              // 하단 버튼
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: _phase == _CardPhase.intro
                      ? _startFlip
                      : (_revealed ? _claim : null),
                  child: Text(
                    _phase == _CardPhase.intro
                        ? '카드 열기'
                        : (_revealed ? '$_prize 마일리지 받기' : '카드를 긁어주세요'),
                  ),
                ),
              ),
            ],
          ),
        ),
          ),

          // 폭죽 오버레이 (공개 시 하늘에서 라임 조각이 떨어짐)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _confetti,
                builder: (context, _) => CustomPaint(
                  painter: _ConfettiPainter(
                    pieces: _confettiPieces,
                    t: _confetti.value,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _title {
    if (_revealed) return '축하해요!';
    if (_phase == _CardPhase.scratch) return '오늘의 행운 카드';
    return '행운 카드가 도착했어요';
  }

  String get _subtitle {
    if (_revealed) return '$_prize 마일리지에 당첨됐어요';
    if (_phase == _CardPhase.scratch) return '손가락으로 카드를 긁어\n마일리지를 확인하세요';
    return '카드를 눌러 열어보세요';
  }

  /// 카드 영역 — 세로 회전(intro) → 가로로 눕기(flip) → 스크래치(scratch).
  Widget _buildCardArea(double maxW, double maxH) {
    // 가로(스크래치) 카드 목표 크기 (비율 1.6)
    var lw = maxW;
    var lh = lw / 1.6;
    if (lh > maxH) {
      lh = maxH;
      lw = lh * 1.6;
    }
    // 세로(인트로) 카드 크기 (카드 비율 0.64)
    var ph = math.min(maxH, lw * 1.02);
    var pw = ph * 0.64;
    if (pw > maxW) {
      pw = maxW;
      ph = pw / 0.64;
    }
    // 스크래치 그리드는 가로 카드 크기 기준
    _cardSize = Size(lw, lh);

    return GestureDetector(
      behavior: _phase == _CardPhase.intro
          ? HitTestBehavior.opaque
          : HitTestBehavior.deferToChild,
      onTap: _phase == _CardPhase.intro ? _startFlip : null,
      child: AnimatedBuilder(
        animation: Listenable.merge([_idle, _flip]),
        builder: (context, _) {
          final isIntro = _phase == _CardPhase.intro;
          final f = isIntro ? 0.0 : Curves.easeInOut.transform(_flip.value);

          final w = lerpDouble(pw, lw, f)!;
          final h = lerpDouble(ph, lh, f)!;

          // 회전: 인트로는 계속 회전, flip 시 정면(2π≒정면)으로 이어서 감속.
          final spin = isIntro
              ? _idle.value * 2 * math.pi
              : lerpDouble(_spinAtTap, 2 * math.pi,
                  Curves.easeOutCubic.transform(_flip.value))!;
          final tilt = lerpDouble(-0.10, 0.0, f)!; // 살짝 기울임 → 수평
          final floatY = (1 - f) * math.sin(_idle.value * 2 * math.pi) * 6;

          final m = Matrix4.identity()
            ..setEntry(3, 2, 0.0012) // 원근
            ..rotateZ(tilt)
            ..rotateY(spin);

          return Transform.translate(
            offset: Offset(0, floatY),
            child: Transform(
              alignment: Alignment.center,
              transform: m,
              child: SizedBox(width: w, height: h, child: _cardStack(f)),
            ),
          );
        },
      ),
    );
  }

  /// 카드 앞면(세로 백) ↔ 스크래치 카드 크로스페이드.
  Widget _cardStack(double f) {
    final backOp = _phase == _CardPhase.scratch
        ? 0.0
        : 1 - Curves.easeIn.transform(((f - 0.25) / 0.5).clamp(0.0, 1.0));
    final foilOp = _phase == _CardPhase.intro
        ? 0.0
        : Curves.easeIn.transform(((f - 0.45) / 0.55).clamp(0.0, 1.0));

    return Stack(
      fit: StackFit.expand,
      children: [
        if (backOp > 0)
          Opacity(
            opacity: backOp,
            child: const IgnorePointer(child: _CardBack()),
          ),
        Opacity(
          opacity: foilOp,
          child: IgnorePointer(
            ignoring: _phase != _CardPhase.scratch,
            child: _buildCard(),
          ),
        ),
      ],
    );
  }

  Widget _buildCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ① 당첨 결과 (아래 레이어)
          _PrizeLayer(prize: _prize, pop: _pop),

          // ② 은박 포일 (위 레이어) — 긁으면 뚫려서 아래가 보임
          FadeTransition(
            opacity: Tween<double>(begin: 1, end: 0).animate(
              CurvedAnimation(parent: _fade, curve: Curves.easeOut),
            ),
            child: IgnorePointer(
              ignoring: _revealed,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (d) => _addPoint(d.localPosition),
                onPanUpdate: (d) => _addPoint(d.localPosition),
                onPanEnd: (_) => _strokes.add(null),
                child: CustomPaint(
                  painter: _FoilPainter(strokes: _strokes),
                  size: Size.infinite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 인트로 세로 카드 앞면(백) — 회전 중 좌우 대칭이라 뒤집혀도 자연스럽다.
class _CardBack extends StatelessWidget {
  const _CardBack();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF20240F), Color(0xFF3C471C), Color(0xFF20240F)],
        ),
        border: Border.all(
          color: AppColors.lime.withValues(alpha: 0.55),
          width: 1.5,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 은은한 라임 글로우
          const DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              gradient: RadialGradient(
                radius: 0.75,
                colors: [Color(0x33D7FC51), Color(0x00D7FC51)],
              ),
            ),
          ),
          // 가운데 코인 (대칭)
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.lime.withValues(alpha: 0.12),
            ),
            child: const Icon(Symbols.paid,
                color: AppColors.lime, size: 52, fill: 1),
          ),
        ],
      ),
    );
  }
}

/// 당첨 결과 레이어 — 라임 글로우 + 코인 + 큰 마일리지 숫자.
class _PrizeLayer extends StatelessWidget {
  const _PrizeLayer({required this.prize, required this.pop});
  final int prize;
  final Animation<double> pop;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        gradient: const RadialGradient(
          center: Alignment.center,
          radius: 0.9,
          colors: [Color(0x33D7FC51), Color(0x00D7FC51)],
        ),
      ),
      child: Center(
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.7, end: 1).animate(
            CurvedAnimation(parent: pop, curve: Curves.elasticOut),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Symbols.paid,
                  color: AppColors.lime, size: 40, fill: 1),
              const SizedBox(height: 8),
              Text(
                '$prize P',
                style: textTheme.displaySmall?.copyWith(
                  color: AppColors.lime,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 은박 포일 페인터 — 포일을 그린 뒤 긁은 경로를 BlendMode.clear로 뚫는다.
class _FoilPainter extends CustomPainter {
  _FoilPainter({required this.strokes});
  final List<Offset?> strokes;

  static const double _brush = 46;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.saveLayer(rect, Paint());

    // 포일 그라데이션 (라임 틴트 그래파이트) + 대각 광택
    final foil = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2C3316), Color(0xFF515F2A), Color(0xFF2C3316)],
        stops: [0.0, 0.5, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, foil);

    final sheen = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.10),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.35, 0.5, 0.65],
      ).createShader(rect);
    canvas.drawRect(rect, sheen);

    // 가운데 안내(아이콘 + 문구) — 긁으면 같이 벗겨짐
    _drawHint(canvas, size);

    // 긁은 경로 뚫기
    final erase = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.stroke
      ..strokeWidth = _brush
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    var penDown = false;
    for (final p in strokes) {
      if (p == null) {
        penDown = false;
        continue;
      }
      if (!penDown) {
        path.moveTo(p.dx, p.dy);
        // 한 점만 찍힌 탭도 지워지도록 점 하나
        canvas.drawCircle(p, _brush / 2, erase);
        penDown = true;
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(path, erase);

    canvas.restore();
  }

  void _drawHint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const iconData = Symbols.touch_app;
    final icon = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(iconData.codePoint),
        style: TextStyle(
          fontFamily: iconData.fontFamily,
          package: iconData.fontPackage,
          fontSize: 40,
          color: AppColors.lime.withValues(alpha: 0.85),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    icon.paint(canvas, center - Offset(icon.width / 2, icon.height / 2 + 22));

    final label = TextPainter(
      text: TextSpan(
        text: '여기를 긁어보세요',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.lime.withValues(alpha: 0.85),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    label.paint(canvas, center - Offset(label.width / 2, -18));
  }

  @override
  bool shouldRepaint(_FoilPainter oldDelegate) => true;
}

/// 폭죽 조각 하나 (하늘에서 떨어지는 라임 종이).
class _Confetti {
  const _Confetti({
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

/// 하늘에서 떨어지는 라임 폭죽 페인터.
class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.pieces, required this.t});
  final List<_Confetti> pieces;
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
      final paint = Paint()..color = p.color.withValues(alpha: op.clamp(0.0, 1.0));

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
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.pieces != pieces;
}
