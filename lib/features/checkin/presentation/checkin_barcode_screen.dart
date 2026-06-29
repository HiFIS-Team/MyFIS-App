import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:screen_brightness/screen_brightness.dart';

import '../../../core/theme/app_colors.dart';

/// 출석 바코드 화면.
/// 헤더 바코드 아이콘에서 좌→우 슬라이드로 진입(알림과 통일).
/// 구성: 화면 밝기 슬라이더(상) → 바코드(중) → 출석 현황(하).
/// 진입 시 밝기를 최대로 올리고, 슬라이더로 직접 조절 가능. 나갈 때 복구.
class CheckinBarcodeScreen extends StatefulWidget {
  const CheckinBarcodeScreen({super.key});

  @override
  State<CheckinBarcodeScreen> createState() => _CheckinBarcodeScreenState();
}

class _CheckinBarcodeScreenState extends State<CheckinBarcodeScreen> {
  // 더미 회원/출석 데이터
  static const String _userName = '은후';
  static const String _barcodeData = '202609031234';
  static const List<_Attendance> _history = [
    _Attendance(date: '6월 29일', day: '일', time: '오후 1:45'),
    _Attendance(date: '6월 27일', day: '금', time: '오후 7:20'),
    _Attendance(date: '6월 26일', day: '목', time: '오후 6:50'),
    _Attendance(date: '6월 24일', day: '화', time: '오후 8:10'),
    _Attendance(date: '6월 23일', day: '월', time: '오후 7:35'),
  ];

  double _brightness = 1.0;

  @override
  void initState() {
    super.initState();
    _boostBrightness();
  }

  @override
  void dispose() {
    _restoreBrightness();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('출석'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: [
          // ① 화면 밝기 슬라이더
          _BrightnessSlider(
            value: _brightness,
            onChanged: _onBrightnessChanged,
          ),
          const SizedBox(height: 24),

          // ② 바코드 카드
          _BarcodeCard(userName: _userName, data: _barcodeData),
          const SizedBox(height: 32),

          // ③ 출석 현황
          const _AttendanceHistory(items: _history),
        ],
      ),
    );
  }
}

/// 화면 밝기 슬라이더 (가로) — 오른쪽 밝게 / 왼쪽 어둡게.
class _BrightnessSlider extends StatelessWidget {
  const _BrightnessSlider({required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Symbols.brightness_low,
              color: AppColors.textSecondary, size: 20),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.lime,
                inactiveTrackColor: AppColors.outline,
                thumbColor: AppColors.lime,
                trackHeight: 4,
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 16),
              ),
              child: Slider(
                value: value,
                min: 0.05, // 완전 검정 방지
                max: 1.0,
                onChanged: onChanged,
              ),
            ),
          ),
          const Icon(Symbols.brightness_high,
              color: AppColors.lime, size: 22),
        ],
      ),
    );
  }
}

/// 바코드 카드 (흰 배경 — 스캐너 인식용).
class _BarcodeCard extends StatelessWidget {
  const _BarcodeCard({required this.userName, required this.data});

  final String userName;
  final String data;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            '$userName님',
            style: textTheme.titleMedium?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          BarcodeWidget(
            barcode: Barcode.code128(),
            data: data,
            width: double.infinity,
            height: 96,
            drawText: false,
            color: Colors.black,
          ),
          const SizedBox(height: 16),
          Text(
            _formatCode(data),
            style: textTheme.titleMedium?.copyWith(
              color: Colors.black,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  /// 4자리마다 띄어쓰기
  static String _formatCode(String code) {
    final buf = StringBuffer();
    for (var i = 0; i < code.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(code[i]);
    }
    return buf.toString();
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

/// 출석 현황 — 최근 출석 기록 리스트.
class _AttendanceHistory extends StatelessWidget {
  const _AttendanceHistory({required this.items});

  final List<_Attendance> items;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('출석 현황', style: textTheme.titleMedium),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.outline,
                    indent: 16,
                    endIndent: 16,
                  ),
                _AttendanceRow(item: items[i]),
              ],
            ],
          ),
        ),
      ],
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
