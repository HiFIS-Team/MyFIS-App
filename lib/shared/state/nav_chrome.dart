import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 스크롤에 따른 하단 크롬(네비바·교환권) 축소 상태.
/// 아래로 스크롤 = true(축소), 위로 스크롤/탭 이동 = false(복원).
/// MainShell이 스크롤을 보고 갱신하고, 네비바와 교환권 오버레이가 함께 구독해
/// 같은 배율로 동시에 줄어들고 커진다.
class NavCollapsedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) {
    if (state != value) state = value;
  }
}

final navCollapsedProvider =
    NotifierProvider<NavCollapsedNotifier, bool>(NavCollapsedNotifier.new);

/// 네비바 캡슐 치수(교환권이 같은 바닥점·배율로 붙기 위해 공유).
const double kNavBarHeight = 62;
const double kNavBarBottomPad = 8;
const double kNavCollapsedScale = 0.82;
