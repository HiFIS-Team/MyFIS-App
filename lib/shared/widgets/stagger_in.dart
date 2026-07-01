import 'dart:async';

import 'package:flutter/material.dart';

/// 리스트/그리드 항목이 위에서부터 하나씩 페이드+슬라이드로 등장.
/// [index]에 비례한 지연 뒤 재생된다. (탭 비활성 시 TickerMode로 자동 정지)
class StaggerIn extends StatefulWidget {
  const StaggerIn({
    super.key,
    required this.index,
    required this.child,
    this.step = const Duration(milliseconds: 55),
    this.duration = const Duration(milliseconds: 380),
    this.maxIndex = 12,
    this.offset = 18,
  });

  final int index;
  final Widget child;
  final Duration step; // 항목당 지연 간격
  final Duration duration; // 개별 등장 시간
  final int maxIndex; // 지연 상한(너무 늦게 나오는 것 방지)
  final double offset; // 슬라이드 시작 오프셋(px)

  @override
  State<StaggerIn> createState() => _StaggerInState();
}

class _StaggerInState extends State<StaggerIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  Timer? _timer;
  bool _scheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 탭(브랜치)이 실제로 활성화되어 보일 때 재생. 오프스크린 상태에선 대기.
    final active = TickerMode.valuesOf(context).enabled;
    if (active && !_scheduled) {
      _scheduled = true;
      final n = widget.index.clamp(0, widget.maxIndex);
      _timer = Timer(widget.step * n, () {
        if (mounted) _c.forward();
      });
    } else if (!active && _scheduled) {
      // 떠났다 다시 들어오면 처음부터 재생되도록 리셋
      _scheduled = false;
      _timer?.cancel();
      _c.value = 0;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = Curves.easeOut.transform(_c.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * widget.offset),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
