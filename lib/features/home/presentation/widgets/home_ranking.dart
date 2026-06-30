import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// 홈 — 랭킹(출석왕 / 지인소개왕). 토스 증권 실시간 차트 스타일.
/// 언더라인 탭으로 카테고리 전환, 1~10위 리스트 + 등락 표시 + 더 보기.
/// 현재는 더미 데이터.
class HomeRanking extends StatefulWidget {
  const HomeRanking({super.key});

  @override
  State<HomeRanking> createState() => _HomeRankingState();
}

class _HomeRankingState extends State<HomeRanking> {
  int _tab = 0; // 0: 출석왕, 1: 지인소개왕

  static const List<_Board> _boards = [
    _Board(label: '출석왕', unit: '일', rows: [
      _Rank(1, '김철수', 28, change: 2),
      _Rank(2, '이영희', 25, change: 0),
      _Rank(3, '박민수', 24, change: 5),
      _Rank(4, '정수진', 22, change: -1),
      _Rank(5, '최동욱', 21, change: 1),
      _Rank(6, '강민지', 20, isNew: true),
      _Rank(7, '나', 18, change: 3, isMe: true),
      _Rank(8, '윤서연', 17, change: -2),
      _Rank(9, '임재현', 16, change: 0),
      _Rank(10, '한지우', 15, change: 1),
    ]),
    _Board(label: '지인소개왕', unit: '명', rows: [
      _Rank(1, '박지연', 12, change: 1),
      _Rank(2, '정우성', 9, change: 0),
      _Rank(3, '나', 6, change: 4, isMe: true),
      _Rank(4, '이준호', 5, change: -2),
      _Rank(5, '송미라', 5, change: 0),
      _Rank(6, '김하늘', 4, isNew: true),
      _Rank(7, '오세훈', 4, change: -1),
      _Rank(8, '장도연', 3, change: 2),
      _Rank(9, '신유빈', 3, change: 0),
      _Rank(10, '문상혁', 2, change: -3),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final board = _boards[_tab];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
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
                        for (var i = 0; i < _boards.length; i++) ...[
                          if (i > 0) const SizedBox(width: 22),
                          _TabItem(
                            label: _boards[i].label,
                            selected: _tab == i,
                            onTap: () => setState(() => _tab = i),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // 1~10위 리스트
                for (final r in board.rows)
                  _RankRow(rank: r, unit: board.unit),
                // 더 보기
                InkWell(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '더 보기',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.keyboard_arrow_down,
                            size: 20, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Board {
  const _Board({required this.label, required this.unit, required this.rows});
  final String label;
  final String unit;
  final List<_Rank> rows;
}

class _Rank {
  const _Rank(
    this.rank,
    this.name,
    this.value, {
    this.change = 0,
    this.isNew = false,
    this.isMe = false,
  });
  final int rank;
  final String name;
  final int value;
  final int change; // >0 상승, <0 하락, 0 변동없음
  final bool isNew;
  final bool isMe;
}

/// 순위 한 줄 — 순위 · 등락 · 아바타 · 이름 · 값.
class _RankRow extends StatelessWidget {
  const _RankRow({required this.rank, required this.unit});
  final _Rank rank;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final top3 = rank.rank <= 3;

    return Container(
      color: rank.isMe ? AppColors.lime.withValues(alpha: 0.10) : null,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
      child: Row(
        children: [
          // 순위
          SizedBox(
            width: 22,
            child: Text(
              '${rank.rank}',
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: top3 ? AppColors.lime : AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // 등락
          SizedBox(width: 40, child: _Change(change: rank.change, isNew: rank.isNew)),
          const SizedBox(width: 6),
          // 아바타
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: rank.isMe
                  ? AppColors.lime.withValues(alpha: 0.2)
                  : AppColors.surfaceAlt,
            ),
            child: Text(
              rank.name.characters.first,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: rank.isMe ? AppColors.lime : AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // 이름
          Expanded(
            child: Text(
              rank.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: rank.isMe ? FontWeight.w800 : FontWeight.w600,
                color: rank.isMe ? AppColors.lime : AppColors.textPrimary,
              ),
            ),
          ),
          // 값
          Text(
            '${rank.value}$unit',
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// 등락 표시 — ▲상승(초록) / ▼하락(빨강) / NEW / -.
class _Change extends StatelessWidget {
  const _Change({required this.change, required this.isNew});
  final int change;
  final bool isNew;

  static const _up = Color(0xFF4ADE80);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    if (isNew) {
      return Text(
        'NEW',
        style: textTheme.labelSmall?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w800,
        ),
      );
    }
    if (change == 0) {
      return Text(
        '-',
        style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
      );
    }
    final up = change > 0;
    final color = up ? _up : AppColors.error;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(up ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            size: 20, color: color),
        Text(
          '${change.abs()}',
          style: textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// 언더라인 탭 항목 (찜한 상품·스토어 카테고리와 동일 스타일).
class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 10),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: selected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 2.5,
              color: selected ? AppColors.lime : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
