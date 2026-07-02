import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../../../shared/widgets/lime_confetti.dart';
import '../../../shared/widgets/pressable.dart';
import '../../../shared/widgets/reward_capsule.dart';
import '../../home/presentation/widgets/attendance_calendar.dart';

/// 인스타 스토리 공유 미션 — 홈 출석 달력을 스토리 카드로 만들어 공유. (현재 더미)
class InstagramMissionScreen extends StatefulWidget {
  const InstagramMissionScreen({super.key});

  @override
  State<InstagramMissionScreen> createState() => _InstagramMissionScreenState();
}

class _InstagramMissionScreenState extends State<InstagramMissionScreen>
    with TickerProviderStateMixin {
  static const int _rewardPoints = 5;
  static const Set<int> _attended = {2, 5, 8, 12, 15, 18, 23, 25, 26, 27, 28, 29};

  final GlobalKey _cardKey = GlobalKey();
  bool _sharing = false;
  bool _rewarded = false;

  // 공유 완료 시 적립 캡슐.
  bool _toastActive = false;
  late final AnimationController _toast = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  );

  // 공유 완료 시 라임 폭죽.
  late final AnimationController _confetti = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );
  List<ConfettiPiece> _confettiPieces = [];

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
    _confetti.dispose();
    super.dispose();
  }

  void _reward() {
    HapticFeedback.mediumImpact();
    setState(() {
      _rewarded = true;
      _toastActive = true;
    });
    _confettiPieces = spawnLimeConfetti();
    _confetti.forward(from: 0);
    _toast.forward(from: 0);
  }

  Future<void> _share() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      // 스토리 카드를 이미지로 캡처
      final boundary =
          _cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = data!.buffer.asUint8List();
      final path = '${Directory.systemTemp.path}/myfis_attendance.png';
      await File(path).writeAsBytes(bytes);

      final result = await SharePlus.instance.share(
        ShareParams(
          files: [XFile(path, mimeType: 'image/png')],
          text: '오늘도 MyFIS 출석 완료 💪',
        ),
      );

      // 인스타처럼 "앱으로 열기"로 완료되는 대상은 iOS가 success 대신
      // dismissed를 주기도 해서, 공유 시트가 실제로 실행됐으면(미지원 아님) 적립.
      if (result.status != ShareResultStatus.unavailable && !_rewarded) {
        _reward();
      }
    } catch (_) {
      // 공유 실패 — 조용히 무시
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const AppTopBar(title: '인스타 스토리 공유'),
      body: Stack(
        children: [
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Text(
                    '오늘 출석을 자랑해요',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '스토리에 공유하고 +$_rewardPoints P 받기',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),

                  // 스토리 카드 미리보기 (9:16) — 화면에 맞게 축소
                  Expanded(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: RepaintBoundary(
                          key: _cardKey,
                          child: const _StoryCard(attended: _attended),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: PressableButton(
                      onPressed: (_sharing || _rewarded) ? null : _share,
                      child: Text(
                        _rewarded
                            ? '오늘 공유 완료'
                            : (_sharing ? '준비 중…' : '인스타 스토리에 공유'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 공유 완료 폭죽
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

/// 공유용 스토리 카드 (9:16) — 브랜딩 + 이번 달 출석 달력.
class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.attended});
  final Set<int> attended;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: 360,
      height: 640,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF10160A), Color(0xFF000000)],
        ),
      ),
      child: Stack(
        children: [
          // 상단 라임 글로우
          const Positioned(
            top: -80,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 240,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [Color(0x33D7FC51), Color(0x00D7FC51)],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 브랜드
                Center(
                  child: Image.asset('assets/images/logo.png', height: 26),
                ),
                const SizedBox(height: 28),
                Text(
                  '오늘도 출석 완료',
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '꾸준함이 실력이 되는 중',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.lime,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                // 출석 달력 (홈과 동일) — 캡처용이라 상호작용 차단
                IgnorePointer(
                  child: AttendanceCalendar(attendedDays: attended),
                ),
                const Spacer(),
                Center(
                  child: Text(
                    'MyFIS · 헬스가 습관이 되는 곳',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
