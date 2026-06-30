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
