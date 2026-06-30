import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:screen_brightness/screen_brightness.dart';

import '../../../core/theme/app_colors.dart';

/// 출석 바코드 — 홈 위로 "위에서 바코드까지" 내려오는 드롭다운 시트.
/// 투명 오버레이라 패널이 안 덮은 아래쪽은 뒤 화면(홈)이 어둡게 비친다.
/// 패널: 화면 밝기 조절 + 바코드. 진입 시 밝기 최대, 닫으면 원복.
/// 슬라이드·스크림은 ModalRoute.animation에 맞춰 함께 움직인다.
class CheckinBarcodeScreen extends StatefulWidget {
  const CheckinBarcodeScreen({super.key});

  @override
  State<CheckinBarcodeScreen> createState() => _CheckinBarcodeScreenState();
}

class _CheckinBarcodeScreenState extends State<CheckinBarcodeScreen> {
  static const String _barcodeData = '202609031234';

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

  void _close() => Navigator.of(context).maybePop();

  @override
  Widget build(BuildContext context) {
    final anim = ModalRoute.of(context)?.animation ?? kAlwaysCompleteAnimation;
    return AnimatedBuilder(
      animation: anim,
      builder: (context, _) {
        final t = anim.value;
        final slide = Curves.easeOutCubic.transform(t);
        return Stack(
          children: [
            // 뒤 화면(홈)을 어둡게 — 탭하면 닫힘
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _close,
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.55 * t),
                ),
              ),
            ),
            // 위에서 바코드까지 내려오는 패널
            Align(
              alignment: Alignment.topCenter,
              child: FractionalTranslation(
                translation: Offset(0, slide - 1),
                child: _Panel(
                  brightness: _brightness,
                  onBrightnessChanged: _onBrightnessChanged,
                  onClose: _close,
                  barcodeData: _barcodeData,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 위에서 내려오는 패널 — 밝기 조절 + 바코드 + 아래 손잡이.
class _Panel extends StatelessWidget {
  const _Panel({
    required this.brightness,
    required this.onBrightnessChanged,
    required this.onClose,
    required this.barcodeData,
  });

  final double brightness;
  final ValueChanged<double> onBrightnessChanged;
  final VoidCallback onClose;
  final String barcodeData;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 위로 쓸어올리면 닫힘
      onVerticalDragEnd: (d) {
        if ((d.primaryVelocity ?? 0) < -120) onClose();
      },
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
          boxShadow: [
            BoxShadow(color: Colors.black54, blurRadius: 24, offset: Offset(0, 8)),
          ],
        ),
        // Slider 등 머티리얼 위젯을 위한 Material 조상 제공(스캐폴드 없음)
        child: Material(
          type: MaterialType.transparency,
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 화면 밝기 조절 + 닫기
                SizedBox(
                  height: kToolbarHeight,
                  child: _BrightnessBar(
                    value: brightness,
                    onChanged: onBrightnessChanged,
                    onClose: onClose,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 10),
                  child: _BarcodeCard(data: barcodeData),
                ),
                // 아래 손잡이 (쓸어올려 닫기 힌트)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.outline,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
                color: AppColors.textSecondary, size: 20),
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
                  activeTrackColor: AppColors.textPrimary,
                  inactiveTrackColor: AppColors.outline,
                  thumbColor: AppColors.textPrimary,
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
