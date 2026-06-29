import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../application/exchange_orders_provider.dart';
import '../domain/exchange_order.dart';

/// 삼성페이식 교환권 지갑.
/// 하단 "내 교환권" 핸들을 쓸어올리면 카드 묶음이 세로→가로로 회전하며 펼쳐지고,
/// 펼친 뒤엔 프로모션 배너처럼 좌우로 쓸어넘겨(자동 X) 여러 교환권을 본다.
class ExchangeWalletOverlay extends ConsumerStatefulWidget {
  const ExchangeWalletOverlay({super.key});

  @override
  ConsumerState<ExchangeWalletOverlay> createState() =>
      _ExchangeWalletOverlayState();
}

class _ExchangeWalletOverlayState extends ConsumerState<ExchangeWalletOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 360),
  );
  final PageController _page = PageController(viewportFraction: 0.84);

  static const double _dragRange = 360;
  static const double _cardH = 196;

  @override
  void dispose() {
    _c.dispose();
    _page.dispose();
    super.dispose();
  }

  void _open() => _c.animateTo(1,
      curve: Curves.easeOutCubic, duration: const Duration(milliseconds: 360));
  void _close() => _c.animateBack(0,
      curve: Curves.easeOutCubic, duration: const Duration(milliseconds: 320));

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

    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final p = _c.value;
        final eased = Curves.easeOut.transform(p);

        return Stack(
          children: [
            // 뒤 배경 딤
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

            // 접힘 상태 핸들 (시각 표시용)
            Positioned(
              left: 0,
              right: 0,
              bottom: 92,
              child: IgnorePointer(
                child: Opacity(
                  opacity: (1 - p * 4).clamp(0.0, 1.0),
                  child: Center(child: _WalletHandle(count: orders.length)),
                ),
              ),
            ),

            // 카드 캐러셀: 세로(접힘)→가로(펼침)로 회전 + 확대 + 상승
            Align(
              alignment: Alignment.lerp(
                const Alignment(0, 1.25),
                const Alignment(0, -0.05),
                eased,
              )!,
              child: Opacity(
                opacity: (p * 2.4).clamp(0.0, 1.0),
                child: Transform.rotate(
                  angle: (1 - eased) * (math.pi / 2),
                  child: Transform.scale(
                    scale: 0.42 + 0.58 * eased,
                    child: IgnorePointer(
                      ignoring: p < 0.5, // 펼친 뒤에만 스와이프
                      child: GestureDetector(
                        // 세로 드래그는 닫기(가로 스와이프는 PageView가 처리)
                        onVerticalDragUpdate: _onDragUpdate,
                        onVerticalDragEnd: _onDragEnd,
                        child: SizedBox(
                          width: size.width,
                          height: _cardH,
                          child: orders.length == 1
                              ? Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 28),
                                  child: _WalletCard(order: orders.first),
                                )
                              : PageView.builder(
                                  controller: _page,
                                  itemCount: orders.length,
                                  itemBuilder: (context, i) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6),
                                    child: _WalletCard(order: orders[i]),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 하단 스와이프 감지 영역 — 항상 유지(접힘=위로 열기 / 펼침=아래로/탭 닫기)
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

/// 접힘 상태 핸들 — "내 교환권 N장".
class _WalletHandle extends StatelessWidget {
  const _WalletHandle({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
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
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 6),
          Text(
            '$count장',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.lime,
              fontWeight: FontWeight.w800,
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
  final ExchangeOrder order;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final done = order.done;

    return Container(
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
