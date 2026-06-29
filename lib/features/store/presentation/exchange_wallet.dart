import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';

/// 교환권(주문) 한 건. 현재는 더미 데이터.
class _ExchangeOrder {
  const _ExchangeOrder({
    required this.name,
    required this.number,
    required this.qty,
    required this.date,
    required this.done,
  });

  final String name;
  final String number; // 교환번호 (프론트 제시용)
  final int qty;
  final String date;
  final bool done;
}

// 지금(가장 최근) 교환 기록만 보여준다.
const _ExchangeOrder _latestOrder = _ExchangeOrder(
  name: '프로틴 쉐이커',
  number: 'A3F92',
  qty: 2,
  date: '6/29',
  done: false,
);

/// 삼성페이식 교환권.
/// 하단 "내 교환권" 핸들을 쓸어올리면 카드가 세로→가로로 회전하며 펼쳐지고,
/// 쓸어내리면 역재생으로 핸들로 접힌다. 스토어 화면 Stack 위에 올려 사용.
class ExchangeWalletOverlay extends StatefulWidget {
  const ExchangeWalletOverlay({super.key});

  @override
  State<ExchangeWalletOverlay> createState() => _ExchangeWalletOverlayState();
}

class _ExchangeWalletOverlayState extends State<ExchangeWalletOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 360),
  );

  // 완전히 펼치는 데 필요한 드래그 거리(px)
  static const double _dragRange = 360;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _open() =>
      _c.animateTo(1, curve: Curves.easeOutCubic, duration: const Duration(milliseconds: 360));
  void _close() =>
      _c.animateBack(0, curve: Curves.easeOutCubic, duration: const Duration(milliseconds: 320));

  void _onDragUpdate(DragUpdateDetails d) {
    // 위로(음수 dy) 끌면 진행도 증가
    _c.value = (_c.value - d.primaryDelta! / _dragRange).clamp(0.0, 1.0);
  }

  void _onDragEnd(DragEndDetails d) {
    final v = d.primaryVelocity ?? 0;
    if (v < -250) {
      _open();
    } else if (v > 250) {
      _close();
    } else {
      _c.value > 0.5 ? _open() : _close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cardW = size.width - 40;

    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final p = _c.value;
        final eased = Curves.easeOut.transform(p);

        return Stack(
          children: [
            // 뒤 배경 딤 (열릴수록 어두워짐)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: p < 0.02,
                child: GestureDetector(
                  onTap: _close,
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: 0.6 * p),
                  ),
                ),
              ),
            ),

            // 접힘 상태: "내 교환권" 핸들 (시각 표시용, 열리면 사라짐)
            Positioned(
              left: 0,
              right: 0,
              bottom: 92,
              child: IgnorePointer(
                child: Opacity(
                  opacity: (1 - p * 4).clamp(0.0, 1.0),
                  child: const Center(child: _WalletHandle()),
                ),
              ),
            ),

            // 카드: 세로(접힘)→가로(펼침)로 회전 + 확대 + 상승
            Align(
              alignment: Alignment.lerp(
                const Alignment(0, 1.25), // 아래(핸들 근처)
                const Alignment(0, -0.1), // 펼치면 중앙 살짝 위
                eased,
              )!,
              child: Opacity(
                opacity: (p * 2.4).clamp(0.0, 1.0),
                child: Transform.rotate(
                  angle: (1 - eased) * (math.pi / 2), // 90°(세로) → 0°(가로)
                  child: Transform.scale(
                    scale: 0.42 + 0.58 * eased, // 작게 → 원래 크기
                    child: IgnorePointer(
                      ignoring: p < 0.5, // 펼쳐졌을 때만 카드가 드래그 받음
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onVerticalDragUpdate: _onDragUpdate,
                        onVerticalDragEnd: _onDragEnd,
                        child: SizedBox(
                          width: cardW,
                          child: const _WalletCard(order: _latestOrder),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 하단 스와이프 감지 영역 — 항상 유지(드래그 중 사라지지 않게).
            // 접힘: 위로 끌면 열기 / 펼침: 아래로 끌거나 탭하면 닫기.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 150,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => _c.value > 0.5 ? _close() : _open(),
                onVerticalDragUpdate: _onDragUpdate,
                onVerticalDragEnd: _onDragEnd,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 접힘 상태 핸들 — "내 교환권".
class _WalletHandle extends StatelessWidget {
  const _WalletHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Symbols.keyboard_arrow_up,
              size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          const Icon(Symbols.wallet, size: 18, color: AppColors.lime),
          const SizedBox(width: 6),
          Text(
            '내 교환권',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

/// 교환권 카드 — 바우처 느낌. 교환번호를 크게 표시.
class _WalletCard extends StatelessWidget {
  const _WalletCard({required this.order});
  final _ExchangeOrder order;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final done = order.done;

    return Container(
      height: 196,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: done
              ? const [Color(0xFF202020), Color(0xFF2A2A2A)]
              : const [Color(0xFF2B3514), Color(0xFF566B25)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${order.name} x${order.qty}',
                style: textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: done
                      ? Colors.white.withValues(alpha: 0.10)
                      : AppColors.lime,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  done ? '수령 완료' : '수령 전',
                  style: textTheme.bodySmall?.copyWith(
                    color: done ? AppColors.textSecondary : Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '교환번호',
            style: textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                order.number,
                style: textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                ),
              ),
              const Spacer(),
              Icon(Symbols.qr_code_2,
                  color: Colors.white.withValues(alpha: 0.85), size: 26),
              const SizedBox(width: 8),
              Text(
                order.date,
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
