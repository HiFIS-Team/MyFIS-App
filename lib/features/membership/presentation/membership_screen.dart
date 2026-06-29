import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../../home/presentation/widgets/membership_card.dart';

/// 멤버십 관리 화면.
/// 헤더 카드 아이콘에서 좌→우 슬라이드로 진입.
/// 멤버십 상태 + 관리 메뉴(이용권·결제카드·이용내역).
class MembershipScreen extends StatelessWidget {
  const MembershipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: '멤버십'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: const [
          MembershipCard(),
          SizedBox(height: 24),
          _ManageMenu(),
        ],
      ),
    );
  }
}

class _ManageMenu extends StatelessWidget {
  const _ManageMenu();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          _MenuRow(
            icon: Symbols.event_repeat,
            label: '이용권 연장 · 변경',
          ),
          _MenuRow(
            icon: Symbols.credit_card,
            label: '결제 카드 관리',
          ),
          _MenuRow(
            icon: Symbols.receipt_long,
            label: '이용 내역',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.lime, size: 22),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right,
                    color: AppColors.textSecondary, size: 22),
              ],
            ),
          ),
        ),
        if (!isLast)
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.outline,
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }
}
