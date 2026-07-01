import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../../../shared/widgets/pressable.dart';

/// 멤버십 관리 화면.
/// 로그인 회원이 자신의 멤버십을 관리하는 진입점(연장·변경/결제카드/이용내역/지점 안내).
/// 활성 회원권 현황은 마이페이지에서 보여주므로 여기선 생략.
/// (지점 선택+구매는 회원가입·이용권 구매 흐름에서 처리)
class MembershipScreen extends StatelessWidget {
  const MembershipScreen({super.key});

  void _todo(BuildContext context, String label) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$label (준비 중)')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: '멤버십'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        children: [
          _MenuCard(
            children: [
              _MenuRow(
                icon: Symbols.event_repeat,
                label: '이용권 연장 · 변경',
                onTap: () => _todo(context, '이용권 연장 · 변경'),
              ),
              _MenuRow(
                icon: Symbols.credit_card,
                label: '결제 카드 관리',
                onTap: () => _todo(context, '결제 카드 관리'),
              ),
              _MenuRow(
                icon: Symbols.receipt_long,
                label: '이용 내역',
                onTap: () => _todo(context, '이용 내역'),
              ),
              _MenuRow(
                icon: Symbols.storefront,
                label: '지점 안내',
                isLast: true,
                onTap: () => context.push('/branches'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: children),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Pressable(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.textSecondary, size: 22),
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
