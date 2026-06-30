import 'dart:math' as math;

import 'package:flutter/material.dart';

/// iOS 기본 바운스보다 훨씬 뻑뻑한 오버스크롤.
/// 끝에서 끌어당겨도 조금만 늘어나서 뒤 배경(검정)이 크게 드러나지 않는다.
/// [factor]가 작을수록 더 안 끌린다(기본 0.28, Bouncing은 1.0).
class StiffBounceScrollPhysics extends BouncingScrollPhysics {
  const StiffBounceScrollPhysics({this.factor = 0.28, super.parent});

  final double factor;

  @override
  StiffBounceScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return StiffBounceScrollPhysics(factor: factor, parent: buildParent(ancestor));
  }

  // BouncingScrollPhysics의 마찰 계수를 줄여 끌리는 양을 제한한다.
  @override
  double frictionFactor(double overscrollFraction) =>
      0.52 * math.pow(1 - overscrollFraction, 2) * factor;
}

/// 앱 전역 스크롤 동작 — 모든 스크롤뷰에 [StiffBounceScrollPhysics] 적용.
/// MaterialApp.scrollBehavior에 지정해 페이지 전체에 일괄 반영한다.
class StiffBounceScrollBehavior extends MaterialScrollBehavior {
  const StiffBounceScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const StiffBounceScrollPhysics();
}
