import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../ranking/application/ranking_data.dart';
import '../../../ranking/presentation/widgets/rank_row.dart';

/// 홈 — 랭킹(출석왕 / 지인소개왕). 토스 증권 실시간 차트 스타일.
/// 언더라인 탭 전환, 상위 10위 리스트 + 더 보기(전체 랭킹 페이지로 이동).
class HomeRanking extends StatefulWidget {
  const HomeRanking({super.key});

  @override
  State<HomeRanking> createState() => _HomeRankingState();
}

class _HomeRankingState extends State<HomeRanking> {
  int _tab = 0; // 0: 출석왕, 1: 지인소개왕, 2: 적립왕
  static const int _previewCount = 10;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final board = kRankBoards[_tab];
    final preview = board.entries.take(_previewCount);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            // 언더라인 탭
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.outline, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    for (var i = 0; i < kRankBoards.length; i++) ...[
                      if (i > 0) const SizedBox(width: 22),
                      RankTabItem(
                        label: kRankBoards[i].label,
                        selected: _tab == i,
                        onTap: () => setState(() => _tab = i),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            // 상위 10위
            for (final e in preview) RankRow(entry: e, unit: board.unit),
            // 더 보기 → 전체 랭킹 페이지
            InkWell(
              onTap: () => context.push('/ranking-full', extra: _tab),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Center(
                  child: Text(
                    '더 보기',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
