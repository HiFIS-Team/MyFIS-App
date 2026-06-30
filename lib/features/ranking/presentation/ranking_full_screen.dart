import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../application/ranking_data.dart';
import 'widgets/rank_row.dart';

/// 전체 랭킹 페이지 — 홈 랭킹의 "더 보기"에서 진입.
/// 출석왕/지인소개왕 탭 + 전체 순위 리스트.
class RankingFullScreen extends StatefulWidget {
  const RankingFullScreen({super.key, this.initialTab = 0});
  final int initialTab;

  @override
  State<RankingFullScreen> createState() => _RankingFullScreenState();
}

class _RankingFullScreenState extends State<RankingFullScreen> {
  late int _tab = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    final board = kRankBoards[_tab];

    return Scaffold(
      appBar: const AppTopBar(title: '랭킹'),
      body: Column(
        children: [
          // 언더라인 탭
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.outline, width: 1),
                ),
              ),
              child: Row(
                children: [
                  for (var i = 0; i < kRankBoards.length; i++) ...[
                    if (i > 0) const SizedBox(width: 24),
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
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: board.entries.length,
              itemBuilder: (context, i) =>
                  RankRow(entry: board.entries[i], unit: board.unit),
            ),
          ),
        ],
      ),
    );
  }
}
