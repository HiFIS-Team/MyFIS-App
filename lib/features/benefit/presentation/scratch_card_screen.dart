import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_top_bar.dart';

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

  // 긁힘 감지용 그리드 해상도 + 완전공개 임계치.
  static const int _cols = 24;
  static const int _rows = 15;
  static const double _revealThreshold = 0.45;

  late final int _prize = _pickPrize();
  final Set<int> _scratched = {};
  final List<Offset?> _strokes = [];
  Size _cardSize = Size.zero;
  int _hapticTick = 0;
  bool _revealed = false;
  bool _claimed = false;

  // 포일이 스르륵 사라지는 페이드 + 당첨 숫자 통통 팝.
  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 620),
  );

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
  void dispose() {
    _fade.dispose();
    _pop.dispose();
    super.dispose();
  }

  void _addPoint(Offset local) {
    if (_revealed || _cardSize == Size.zero) return;
    setState(() => _strokes.add(local));

    final col =
        (local.dx / _cardSize.width * _cols).floor().clamp(0, _cols - 1);
    final row =
        (local.dy / _cardSize.height * _rows).floor().clamp(0, _rows - 1);
    _scratched.add(row * _cols + col);

    // 긁는 느낌의 가벼운 햅틱 (너무 잦지 않게 스로틀).
    if (_hapticTick++ % 6 == 0) HapticFeedback.selectionClick();

    if (_scratched.length / (_cols * _rows) >= _revealThreshold) _reveal();
  }

  void _reveal() {
    if (_revealed) return;
    setState(() => _revealed = true);
    HapticFeedback.mediumImpact();
    _fade.forward();
    _pop.forward();
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
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Text(
                _revealed ? '축하해요! 🎉' : '오늘의 행운 카드',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _revealed
                    ? '$_prize 마일리지에 당첨됐어요'
                    : '손가락으로 카드를 긁어\n마일리지를 확인하세요',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),

              // 카드 (남는 공간 가운데)
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1.6,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        _cardSize =
                            Size(constraints.maxWidth, constraints.maxHeight);
                        return _buildCard();
                      },
                    ),
                  ),
                ),
              ),

              // 하단 버튼
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: _revealed ? _claim : null,
                  child: Text(_revealed ? '$_prize 마일리지 받기' : '카드를 긁어주세요'),
                ),
              ),
            ],
          ),
        ),
      ),
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
