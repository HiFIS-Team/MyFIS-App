import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../application/ranking_data.dart';

/// 순위 한 줄 — 순위 · 등락 · 아바타 · 이름 · 값. (홈·전체 랭킹 공용)
class RankRow extends StatelessWidget {
  const RankRow({super.key, required this.entry, required this.unit});
  final RankEntry entry;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final top3 = entry.rank <= 3;

    return Container(
      color: entry.isMe ? AppColors.lime.withValues(alpha: 0.10) : null,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Text(
              '${entry.rank}',
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: top3 ? AppColors.lime : AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 40,
            child: _Change(change: entry.change, isNew: entry.isNew),
          ),
          const SizedBox(width: 6),
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: entry.isMe
                  ? AppColors.lime.withValues(alpha: 0.2)
                  : AppColors.surfaceAlt,
            ),
            child: Text(
              entry.name.characters.first,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: entry.isMe ? AppColors.lime : AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              entry.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: entry.isMe ? FontWeight.w800 : FontWeight.w600,
                color: entry.isMe ? AppColors.lime : AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            '${_comma(entry.value)}$unit',
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// 천 단위 콤마 (마일리지 등 큰 값 가독성).
String _comma(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
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

/// 언더라인 탭 항목 (랭킹 공용).
class RankTabItem extends StatelessWidget {
  const RankTabItem({
    super.key,
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
