import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../application/exchange_orders_provider.dart';
import '../domain/exchange_order.dart';

/// 교환권 지갑 — 오른쪽 모서리 탭.
/// 평소엔 화면 오른쪽 가장자리에 작은 탭만 보이고,
/// 탭을 누르거나 왼쪽으로 쓸어넘기면 교환권 카드가 오른쪽에서 미끄러져 나온다.
class ExchangeWalletOverlay extends ConsumerStatefulWidget {
  const ExchangeWalletOverlay({super.key});

  @override
  ConsumerState<ExchangeWalletOverlay> createState() =>
      _ExchangeWalletOverlayState();
}

class _ExchangeWalletOverlayState extends ConsumerState<ExchangeWalletOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 340),
  );

  // 수령 전 교환권이 있을 때 탭을 라임색으로 깜빡이게 하는 펄스.
  late final AnimationController _blink = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
  )..repeat(reverse: true);

  static const double _dragRange = 300;

  @override
  void dispose() {
    _c.dispose();
    _blink.dispose();
    super.dispose();
  }

  void _open() => _c.animateTo(1,
      curve: Curves.easeOutCubic, duration: const Duration(milliseconds: 340));
  void _close() => _c.animateBack(0,
      curve: Curves.easeOutCubic, duration: const Duration(milliseconds: 300));

  // 가로 드래그: 왼쪽(dx<0)으로 끌면 열리고, 오른쪽으로 끌면 닫힌다.
  void _onDragUpdate(DragUpdateDetails d) {
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
    final orders = ref.watch(exchangeOrdersProvider);
    if (orders.isEmpty) return const SizedBox.shrink();

    final size = MediaQuery.of(context).size;
    final panelW = size.width * 0.82;
    final pending = orders.any((o) => !o.done); // 수령 전이 하나라도 있으면 깜빡

    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final p = _c.value;
        final eased = Curves.easeOutCubic.transform(p);

        return Stack(
          children: [
            // 뒤 배경 딤(시각용)
            Positioned.fill(
              child: IgnorePointer(
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.55 * p),
                ),
              ),
            ),

            // 전체 탭 닫기 레이어 — 열렸을 때 카드 밖(밑 포함) 어디든 누르면 닫힘.
            // 카드는 이 위에 올라가므로 카드 탭은 닫기에서 제외된다.
            Positioned.fill(
              child: IgnorePointer(
                ignoring: p < 0.5,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _close,
                ),
              ),
            ),

            // 카드 패널 — 화면 정중앙. 닫힘=오른쪽 화면 밖에서 슬라이드 인.
            Positioned.fill(
              child: IgnorePointer(
                ignoring: p < 0.5,
                child: Center(
                  child: Transform.translate(
                    offset: Offset((1 - eased) * size.width, 0),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque, // 카드 탭은 닫기 막음
                      onTap: () {},
                      onHorizontalDragUpdate: _onDragUpdate,
                      onHorizontalDragEnd: _onDragEnd,
                      child: SizedBox(
                        width: panelW,
                        child: _CardPanel(orders: orders),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 오른쪽 모서리 탭 — 닫힘일 때 보임, 누르면 열림
            Positioned(
              right: 0,
              top: size.height * 0.40,
              child: Opacity(
                opacity: (1 - p * 3).clamp(0.0, 1.0),
                child: IgnorePointer(
                  ignoring: p > 0.2,
                  child: _EdgeTab(
                    pending: pending,
                    blink: _blink,
                    onTap: _open,
                  ),
                ),
              ),
            ),

            // 오른쪽 가장자리 스와이프 감지(어디서든 왼쪽으로 쓸면 열림)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 26,
              child: IgnorePointer(
                ignoring: p > 0.5,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragUpdate: _onDragUpdate,
                  onHorizontalDragEnd: _onDragEnd,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 펼친 상태의 카드 묶음(세로 나열). 내용 높이에 딱 맞게(빈 공간 없음) →
/// 카드 밖(위·아래 포함)을 누르면 닫기 레이어가 받는다.
class _CardPanel extends StatelessWidget {
  const _CardPanel({required this.orders});
  final List<ExchangeOrder> orders;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < orders.length; i++) ...[
          if (i > 0) const SizedBox(height: 14),
          SizedBox(height: 196, child: _WalletCard(order: orders[i])),
        ],
      ],
    );
  }
}

/// 오른쪽 모서리 탭 — 작은 세로 손잡이(반투명 블러).
/// 수령 전 교환권이 있으면 지갑 아이콘이 라임색으로 깜빡인다.
class _EdgeTab extends StatelessWidget {
  const _EdgeTab({
    required this.pending,
    required this.blink,
    required this.onTap,
  });

  final bool pending;
  final Animation<double> blink;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.horizontal(left: Radius.circular(14));

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt.withValues(alpha: 0.3),
              borderRadius: radius,
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Symbols.chevron_left,
                    size: 18, color: AppColors.textSecondary),
                const SizedBox(height: 6),
                // 수령 전이면 라임으로 깜빡, 아니면 흰색 고정.
                AnimatedBuilder(
                  animation: blink,
                  builder: (context, _) {
                    final color = pending
                        ? Color.lerp(AppColors.textPrimary, AppColors.lime,
                            blink.value)!
                        : AppColors.textPrimary;
                    return Icon(Symbols.wallet, size: 22, color: color);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 교환권 카드 — 바우처 느낌. 교환번호를 크게 표시.
class _WalletCard extends StatelessWidget {
  const _WalletCard({required this.order});
  final ExchangeOrder order;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final done = order.done;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
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
              Expanded(
                child: Text(
                  '${order.name} x${order.qty}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: done
                      ? Colors.white.withValues(alpha: 0.10)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
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
