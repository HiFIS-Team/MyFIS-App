import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// 누르면 내용이 살짝 작아지고(스케일) 칸 전체가 흐려지는(스크림) 토스식 press 피드백.
/// 하단 바(네비/카트바 등) 외 탭 가능한 행·카드에 공용으로 사용.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = BorderRadius.zero,
    this.scale = 0.95,
    this.dim = 0.5,
  });

  final Widget child;
  final VoidCallback? onTap;

  /// 흐림 스크림을 자식 모서리에 맞춰 클립(둥근 카드면 지정).
  final BorderRadius borderRadius;
  final double scale;
  final double dim;

  @override
  State<Pressable> createState() => _PressableState();
}

/// 앱 공통 CTA 버튼 — 테마의 FilledButton 스타일 그대로에 "눌리면 작아졌다 커지는"
/// 스케일 피드백을 더한다. onPressed·style·child는 FilledButton과 동일하게 사용.
/// 비활성(onPressed=null)일 땐 스케일 없이 기본 비활성 버튼으로 표시.
class PressableButton extends StatelessWidget {
  const PressableButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
    this.scale = 0.96,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final double scale;

  static void _noop() {}

  @override
  Widget build(BuildContext context) {
    // 실제 탭은 Pressable이 처리하고, 내부 버튼은 스타일만 담당(포인터 무시).
    final button = IgnorePointer(
      child: FilledButton(
        onPressed: onPressed == null ? null : _noop,
        style: style,
        child: child,
      ),
    );
    if (onPressed == null) return button;
    // 마이페이지처럼 눌리면 살짝 어두워지며(스크림) 작아진다.
    return Pressable(
      onTap: onPressed,
      scale: scale,
      dim: 0.5,
      borderRadius: BorderRadius.circular(12),
      child: button,
    );
  }
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;
  DateTime? _downAt;

  // 빠른 탭이어도 축소가 눈에 보이도록 최소 눌림 시간을 보장한다.
  static const _minVisible = Duration(milliseconds: 130);

  void _down() {
    _downAt = DateTime.now();
    if (!_pressed) setState(() => _pressed = true);
  }

  void _up() {
    final downAt = _downAt;
    final elapsed =
        downAt == null ? Duration.zero : DateTime.now().difference(downAt);
    if (elapsed < _minVisible) {
      Future.delayed(_minVisible - elapsed, () {
        if (mounted) setState(() => _pressed = false);
      });
    } else if (_pressed) {
      setState(() => _pressed = false);
    }
  }

  void _cancel() {
    if (_pressed) setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    const dur = Duration(milliseconds: 110);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _down(),
      onTapUp: (_) => _up(),
      onTapCancel: _cancel,
      onTap: widget.onTap,
      child: Stack(
        children: [
          AnimatedScale(
            scale: _pressed ? widget.scale : 1.0,
            duration: dur,
            curve: Curves.easeOut,
            child: widget.child,
          ),
          // 칸 전체를 덮는 페이드 스크림(스케일과 무관하게 풀사이즈)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: _pressed ? widget.dim : 0.0,
                duration: dur,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: widget.borderRadius,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
