import 'package:flutter/material.dart';

/// 누르면 자식(주로 아이콘)이 살짝 흐려지는(opacity) 토스식 프레스 피드백.
/// 크기 변화 없이 opacity만 낮춰 "눌렀다"가 확실히 보이게 한다.
/// IconButton의 잔잔한 물결을 대체. (캡슐 네비바 등 자체 애니메이션 영역은 제외)
class PressFade extends StatefulWidget {
  const PressFade({
    super.key,
    required this.child,
    this.onTap,
    this.pressedOpacity = 0.35,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double pressedOpacity;

  @override
  State<PressFade> createState() => _PressFadeState();
}

class _PressFadeState extends State<PressFade> {
  bool _pressed = false;
  DateTime? _downAt;

  // 빠른 탭이어도 흐려짐이 눈에 보이도록 최소 눌림 시간 보장.
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _down(),
      onTapUp: (_) => _up(),
      onTapCancel: _cancel,
      onTap: widget.onTap,
      child: AnimatedOpacity(
        opacity: _pressed ? widget.pressedOpacity : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// 아이콘 전용 프레스 페이드 버튼 — [PressFade]로 감싼 탭 타깃(기본 48x48).
class PressableIcon extends StatelessWidget {
  const PressableIcon({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 24,
    this.color,
    this.fill,
    this.minSize = 48,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final Color? color;
  final double? fill;
  final double minSize;

  @override
  Widget build(BuildContext context) {
    return PressFade(
      onTap: onTap,
      child: SizedBox(
        width: minSize,
        height: minSize,
        child: Center(
          child: Icon(icon, size: size, color: color, fill: fill),
        ),
      ),
    );
  }
}
