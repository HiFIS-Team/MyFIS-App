import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:screen_brightness/screen_brightness.dart';

import '../../../core/theme/app_colors.dart';

/// 출석 바코드 화면.
/// 헤더 바코드 아이콘에서 진입. 리더기에 스캔해 출석한다.
/// 토스 QR 결제처럼 진입 시 화면 밝기를 자동으로 최대로 올리고,
/// 나갈 때 원래 밝기로 복구한다(손으로 밝기 조절할 필요 없음).
class CheckinBarcodeScreen extends StatefulWidget {
  const CheckinBarcodeScreen({super.key});

  @override
  State<CheckinBarcodeScreen> createState() => _CheckinBarcodeScreenState();
}

class _CheckinBarcodeScreenState extends State<CheckinBarcodeScreen> {
  // 더미 회원 바코드 데이터
  static const String _userName = '은후';
  static const String _barcodeData = '202609031234';

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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // 닫기
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  iconSize: 28,
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.close),
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),

              Text('$_userName님', style: textTheme.headlineSmall),
              const SizedBox(height: 6),
              Text(
                '리더기에 바코드를 스캔해 출석하세요',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 28),

              // 바코드 카드 (흰 배경 — 스캐너 인식용)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    BarcodeWidget(
                      barcode: Barcode.code128(),
                      data: _barcodeData,
                      width: double.infinity,
                      height: 96,
                      drawText: false,
                      color: Colors.black,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _formatCode(_barcodeData),
                      style: textTheme.titleMedium?.copyWith(
                        color: Colors.black,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 밝기 자동 조절 안내
              const _BrightnessHint(),

              const Spacer(),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  /// 코드 가독성: 4자리마다 띄어쓰기
  static String _formatCode(String code) {
    final buf = StringBuffer();
    for (var i = 0; i < code.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(code[i]);
    }
    return buf.toString();
  }
}

class _BrightnessHint extends StatelessWidget {
  const _BrightnessHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Symbols.brightness_high, color: AppColors.lime, size: 18),
          const SizedBox(width: 7),
          Text(
            '화면을 밝게 조절했어요',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
