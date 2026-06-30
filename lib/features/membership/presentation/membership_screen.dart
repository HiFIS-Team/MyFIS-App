import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../../../shared/widgets/pressable.dart';
import '../domain/branch.dart';

/// 멤버십(지점 선택) 화면.
/// "어디서 운동을 시작할까요?" + 지점 목록(사진 · 이름 · 주소).
/// 지점을 탭하면 멤버십 구매로 진입한다.
/// (활성 회원권 현황은 마이페이지에서 보여주므로 여기선 생략)
class MembershipScreen extends StatelessWidget {
  const MembershipScreen({super.key});

  void _purchase(BuildContext context, Branch branch) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('${branch.name} 멤버십 구매 (준비 중)')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const AppTopBar(title: '멤버십'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        children: [
          Text(
            '어디서 운동을\n시작할까요?',
            style: textTheme.headlineSmall?.copyWith(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < kBranches.length; i++) ...[
            _BranchRow(
              branch: kBranches[i],
              onTap: () => _purchase(context, kBranches[i]),
            ),
            if (i != kBranches.length - 1)
              const Divider(height: 1, thickness: 1, color: AppColors.outline),
          ],
        ],
      ),
    );
  }
}

/// 지점 한 줄 — 왼쪽 사진(그라데이션 placeholder) + 이름 · 주소.
/// 마이페이지 메뉴 행처럼 전체 영역을 누르면 dim.
class _BranchRow extends StatelessWidget {
  const _BranchRow({required this.branch, required this.onTap});

  final Branch branch;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Pressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            // 사진 자리 (그라데이션 + 아이콘)
            Container(
              width: 96,
              height: 96,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [branch.color1, branch.color2],
                ),
              ),
              child: const Icon(Symbols.exercise,
                  color: Colors.white24, size: 38),
            ),
            const SizedBox(width: 16),
            // 이름 + 주소
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    branch.name,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    branch.address,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
