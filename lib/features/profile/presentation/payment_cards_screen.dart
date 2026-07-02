import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../../../shared/widgets/press_fade.dart';
import '../../../shared/widgets/pressable.dart';
import 'payment_history_screen.dart';

/// 등록 결제 카드.
class _PayCard {
  _PayCard({
    required this.brand,
    required this.last4,
    required this.colors,
    this.isDefault = false,
  });
  final String brand;
  final String last4;
  final List<Color> colors;
  bool isDefault;
}

/// 결제 카드 관리 — 토스 카드 상세식. 기본 카드의 이번 달 결제 + 내역 + 기능,
/// 우상단 '관리'로 카드 전환/추가/삭제. (현재 더미, PortOne 연동 시 실제 결제)
class PaymentCardsScreen extends StatefulWidget {
  const PaymentCardsScreen({super.key});

  @override
  State<PaymentCardsScreen> createState() => _PaymentCardsScreenState();
}

class _PaymentCardsScreenState extends State<PaymentCardsScreen> {
  final List<_PayCard> _cards = [
    _PayCard(
      brand: '현대카드',
      last4: '1234',
      colors: const [Color(0xFF2A2A2C), Color(0xFF0A0A0B)],
      isDefault: true,
    ),
    _PayCard(
      brand: '국민카드',
      last4: '5678',
      colors: const [Color(0xFF3A3A3C), Color(0xFF232325)],
    ),
  ];

  final List<_PayCard> _pool = [
    _PayCard(
        brand: '신한카드',
        last4: '9012',
        colors: const [Color(0xFF1E3A5F), Color(0xFF0F2038)]),
    _PayCard(
        brand: '삼성카드',
        last4: '3456',
        colors: const [Color(0xFF1B2A4A), Color(0xFF0E1730)]),
    _PayCard(
        brand: '토스뱅크',
        last4: '7890',
        colors: const [Color(0xFF2B3240), Color(0xFF1A1F2A)]),
  ];
  int _poolIndex = 0;
  int _month = DateTime.now().month;

  _PayCard? get _default =>
      _cards.where((c) => c.isDefault).isNotEmpty
          ? _cards.firstWhere((c) => c.isDefault)
          : (_cards.isNotEmpty ? _cards.first : null);

  void _addCard() {
    final base = _pool[_poolIndex % _pool.length];
    _poolIndex++;
    setState(() {
      _cards.add(_PayCard(
        brand: base.brand,
        last4: base.last4,
        colors: base.colors,
        isDefault: _cards.isEmpty,
      ));
    });
    HapticFeedback.selectionClick();
  }

  void _setDefault(_PayCard card) {
    setState(() {
      for (final c in _cards) {
        c.isDefault = false;
      }
      card.isDefault = true;
    });
    HapticFeedback.selectionClick();
  }

  void _delete(_PayCard card) {
    setState(() {
      final wasDefault = card.isDefault;
      _cards.remove(card);
      if (wasDefault && _cards.isNotEmpty) _cards.first.isDefault = true;
    });
    HapticFeedback.mediumImpact();
  }

  void _openManage() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ManageSheet(
        cards: _cards,
        onSelect: (c) {
          Navigator.of(context).pop();
          _setDefault(c);
        },
        onDelete: (c) {
          Navigator.of(context).pop();
          _delete(c);
        },
        onAdd: () {
          Navigator.of(context).pop();
          _addCard();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final card = _default;

    return Scaffold(
      appBar: AppTopBar(
        title: '카드 관리',
        actions: [
          if (card != null)
            PressableIcon(
              icon: Icons.tune_rounded,
              size: 22,
              color: AppColors.textSecondary,
              onTap: _openManage,
            ),
        ],
      ),
      body: card == null ? _empty(textTheme) : _detail(context, card),
    );
  }

  Widget _empty(TextTheme textTheme) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
        child: Column(
          children: [
            const SizedBox(height: 60),
            Text('등록된 카드가 없어요',
                style: textTheme.bodyMedium
                    ?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            _DashedAddTile(onTap: _addCard),
          ],
        ),
      ),
    );
  }

  Widget _detail(BuildContext context, _PayCard card) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        children: [
          // 이번 달 결제 + 카드 썸네일
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _MonthArrow(
                          icon: Icons.chevron_left,
                          onTap: () => setState(
                              () => _month = _month == 1 ? 12 : _month - 1),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '$_month월 결제 금액',
                          style: textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 2),
                        _MonthArrow(
                          icon: Icons.chevron_right,
                          onTap: () => setState(
                              () => _month = _month == 12 ? 1 : _month + 1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '0원',
                      style: textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '적립 마일리지 0P',
                          style: textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const Icon(Icons.chevron_right,
                            size: 18, color: AppColors.textSecondary),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _CardThumb(card: card),
            ],
          ),
          const SizedBox(height: 28),

          // 결제 내역 (최근 2건 + 더 보기)
          _SectionCard(
            children: [
              _sectionLabel(textTheme, '결제 내역'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  children: [
                    for (final tx in kPayHistory.take(2)) PayTxRow(tx: tx),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              const Divider(height: 1, color: AppColors.outline),
              _MoreRow(
                text: '내역 더 보기',
                onTap: () => context.push('/payment-history'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 편리한 기능
          _SectionCard(
            children: [
              _sectionLabel(textTheme, '편리한 기능'),
              _FeatureRow(label: '결제일 변경', onTap: () {}),
              _FeatureRow(label: '자동결제 관리', onTap: () {}),
              _FeatureRow(label: '영수증 조회', onTap: () {}),
            ],
          ),
          const SizedBox(height: 20),

          // 의견 보내기
          _SectionCard(
            children: [
              _FeatureRow(
                label: 'MyFIS 멤버십 어떤가요?',
                sub: '의견 보내기',
                leadingEmoji: '💬',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(TextTheme textTheme, String text) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 4),
        child: Text(
          text,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}

/// 월 이동 화살표.
class _MonthArrow extends StatelessWidget {
  const _MonthArrow({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressFade(
      onTap: onTap,
      child: Icon(icon, size: 22, color: AppColors.textSecondary),
    );
  }
}

/// 작은 세로 카드 썸네일.
class _CardThumb extends StatelessWidget {
  const _CardThumb({required this.card});
  final _PayCard card;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 100,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: card.colors,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 15,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: const LinearGradient(
                colors: [Color(0xFFE7D18C), Color(0xFFB89B57)],
              ),
            ),
          ),
          const Spacer(),
          Text(
            card.last4,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
  }
}

class _MoreRow extends StatelessWidget {
  const _MoreRow({required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return PressFade(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.label,
    required this.onTap,
    this.sub,
    this.leadingEmoji,
  });
  final String label;
  final VoidCallback onTap;
  final String? sub;
  final String? leadingEmoji;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return PressFade(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            if (leadingEmoji != null) ...[
              Text(leadingEmoji!, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style:
                        textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  if (sub != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      sub!,
                      style: textTheme.bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                size: 20, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

/// 관리 시트 — 등록 카드 목록(기본 선택/삭제) + 카드 추가.
class _ManageSheet extends StatelessWidget {
  const _ManageSheet({
    required this.cards,
    required this.onSelect,
    required this.onDelete,
    required this.onAdd,
  });
  final List<_PayCard> cards;
  final ValueChanged<_PayCard> onSelect;
  final ValueChanged<_PayCard> onDelete;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Row(
                children: [
                  Text('카드 관리',
                      style: textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            for (final c in cards)
              _ManageRow(
                card: c,
                onSelect: () => onSelect(c),
                onDelete: () => onDelete(c),
              ),
            PressFade(
              onTap: onAdd,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    const Icon(Icons.add_rounded,
                        color: AppColors.lime, size: 22),
                    const SizedBox(width: 12),
                    Text('카드 추가',
                        style: textTheme.bodyLarge?.copyWith(
                            color: AppColors.lime,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ManageRow extends StatelessWidget {
  const _ManageRow({
    required this.card,
    required this.onSelect,
    required this.onDelete,
  });
  final _PayCard card;
  final VoidCallback onSelect;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return PressFade(
      onTap: onSelect,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                gradient: LinearGradient(colors: card.colors),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${card.brand} •••• ${card.last4}',
                style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            if (card.isDefault)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.lime,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text('기본',
                    style: textTheme.bodySmall?.copyWith(
                        color: AppColors.background,
                        fontWeight: FontWeight.w800)),
              )
            else
              PressableIcon(
                icon: Icons.delete_outline_rounded,
                size: 22,
                color: AppColors.textSecondary,
                onTap: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}

/// 카드 추가 점선 타일 (빈 상태용).
class _DashedAddTile extends StatelessWidget {
  const _DashedAddTile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Pressable(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedRectPainter(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_rounded, color: AppColors.lime, size: 22),
              const SizedBox(width: 6),
              Text('카드 추가',
                  style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.lime, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Offset.zero & size, const Radius.circular(16)));
    const dash = 6.0;
    const gap = 5.0;
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + dash), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRectPainter oldDelegate) => false;
}
