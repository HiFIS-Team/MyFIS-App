import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:screen_brightness/screen_brightness.dart';

import '../../../core/theme/app_colors.dart';

/// 출석 바코드 화면.
/// 진입 시 화면 밝기 바가 헤더 자리로 위에서 내려오며 밝기를 최대로 올린다.
/// 밝기 바: [아이콘 + 화면 밝기] · [슬라이더] · [X].
/// X를 누르면 밝기 바가 사라지고 진짜 헤더(뒤로가기 + 출석)가 나타난다.
class CheckinBarcodeScreen extends StatefulWidget {
  const CheckinBarcodeScreen({super.key});

  @override
  State<CheckinBarcodeScreen> createState() => _CheckinBarcodeScreenState();
}

class _CheckinBarcodeScreenState extends State<CheckinBarcodeScreen>
    with SingleTickerProviderStateMixin {
  // 더미 데이터
  static const String _barcodeData = '202609031234';
  static const List<_Attendance> _history = [
    _Attendance(date: '6월 29일', day: '일', time: '오후 1:45'),
    _Attendance(date: '6월 27일', day: '금', time: '오후 7:20'),
    _Attendance(date: '6월 26일', day: '목', time: '오후 6:50'),
    _Attendance(date: '6월 24일', day: '화', time: '오후 8:10'),
    _Attendance(date: '6월 23일', day: '월', time: '오후 7:35'),
  ];

  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  );
  late final Animation<Offset> _slide = Tween(
    begin: const Offset(0, -1),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

  double _brightness = 1.0;

  @override
  void initState() {
    super.initState();
    _boostBrightness();
    _ctrl.forward(); // 밝기 바가 위에서 내려옴
  }

  @override
  void dispose() {
    _restoreBrightness();
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _boostBrightness() async {
    try {
      await ScreenBrightness.instance.setApplicationScreenBrightness(1.0);
    } catch (_) {
      // 일부 플랫폼/시뮬레이터 미지원 — 무시
    }
  }

  Future<void> _restoreBrightness() async {
    try {
      await ScreenBrightness.instance.resetApplicationScreenBrightness();
    } catch (_) {}
  }

  void _onBrightnessChanged(double value) {
    setState(() => _brightness = value);
    try {
      ScreenBrightness.instance.setApplicationScreenBrightness(value);
    } catch (_) {}
  }

  void _closeBrightness() => _ctrl.reverse(); // 밝기 바가 위로 사라지고 헤더 노출

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 고정 영역: 헤더(아래) + 밝기 바(위에서 덮음)
            SizedBox(
              height: kToolbarHeight,
              child: ClipRect(
                child: Stack(
                  children: [
                    _Header(onBack: () => Navigator.of(context).maybePop()),
                    SlideTransition(
                      position: _slide,
                      child: _BrightnessBar(
                        value: _brightness,
                        onChanged: _onBrightnessChanged,
                        onClose: _closeBrightness,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 본문
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                children: const [
                  _BarcodeCard(data: _barcodeData),
                  SizedBox(height: 32),
                  _AttendanceHistory(items: _history),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 진짜 헤더 — 뒤로가기 + 출석.
class _Header extends StatelessWidget {
  const _Header({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: onBack,
            color: AppColors.textPrimary,
          ),
          const SizedBox(width: 4),
          Text('출석', style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

/// 화면 밝기 바 (헤더 자리). 왼쪽 라벨 · 가운데 슬라이더 · 오른쪽 X.
class _BrightnessBar extends StatelessWidget {
  const _BrightnessBar({
    required this.value,
    required this.onChanged,
    required this.onClose,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // 빈 영역 탭이 뒤 헤더로 새지 않도록 흡수
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: Container(
        color: AppColors.background,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Icon(Symbols.brightness_high,
                color: AppColors.lime, size: 20),
            const SizedBox(width: 6),
            Text(
              '화면 밝기',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.lime,
                  inactiveTrackColor: AppColors.outline,
                  thumbColor: AppColors.lime,
                  trackHeight: 4,
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 14),
                ),
                child: Slider(
                  value: value,
                  min: 0.05,
                  max: 1.0,
                  onChanged: onChanged,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: onClose,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

/// 바코드 카드 (흰 배경 — 스캐너 인식용). 군더더기 없이 바코드만.
class _BarcodeCard extends StatelessWidget {
  const _BarcodeCard({required this.data});
  final String data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: BarcodeWidget(
        barcode: Barcode.code128(),
        data: data,
        width: double.infinity,
        height: 104,
        drawText: false,
        color: Colors.black,
      ),
    );
  }
}

class _Attendance {
  const _Attendance({
    required this.date,
    required this.day,
    required this.time,
  });

  final String date;
  final String day;
  final String time;
}

/// 출석 현황 — 제목·목록 모두 박스 안에, 항목 사이 구분선.
class _AttendanceHistory extends StatelessWidget {
  const _AttendanceHistory({required this.items});
  final List<_Attendance> items;

  static const Color _divider = Color(0x14FFFFFF); // white 8%

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text('출석 현황', style: textTheme.titleMedium),
          ),
          for (final item in items) ...[
            const Divider(
              height: 1,
              thickness: 1,
              color: _divider,
              indent: 16,
              endIndent: 16,
            ),
            _AttendanceRow(item: item),
          ],
        ],
      ),
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  const _AttendanceRow({required this.item});
  final _Attendance item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const Icon(Symbols.check_circle,
              color: AppColors.lime, size: 20, fill: 1),
          const SizedBox(width: 12),
          Text(
            '${item.date} (${item.day})',
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Text(
            item.time,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
