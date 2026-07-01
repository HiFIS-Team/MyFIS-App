import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../../../shared/widgets/pressable.dart';

/// 알림 조회 화면.
/// 헤더 알림 벨에서 오른쪽→왼쪽 슬라이드로 진입.
/// 현재는 더미 데이터.
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  static const List<_Noti> _items = [
    _Noti(
      icon: Symbols.check_circle,
      color: AppColors.lime, // 출석 - 라임
      title: '오늘도 출석 완료! 💪',
      body: '출석 마일리지 100P가 적립되었어요.',
      time: '방금',
    ),
    _Noti(
      icon: Symbols.fitness_center,
      color: Color(0xFF4DA3FF), // 운동 - 블루
      title: '이번 주 운동 루틴이 도착했어요',
      body: '가슴 · 삼두 집중 루틴 5개를 확인해보세요.',
      time: '2시간 전',
    ),
    _Noti(
      icon: Symbols.paid,
      color: Color(0xFFFFC24B), // 마일리지 - 앰버
      title: '마일리지 2,400P 적립',
      body: '유산소 5km 완주 보상이 적립되었어요.',
      time: '어제',
    ),
    _Noti(
      icon: Symbols.card_membership,
      color: Color(0xFFB69CFF), // 멤버십 - 퍼플
      title: '멤버십이 30일 남았어요',
      body: '2026. 8. 31에 만료돼요. 미리 연장해보세요.',
      time: '3일 전',
    ),
    _Noti(
      icon: Symbols.trophy,
      color: Color(0xFF4FD1C5), // 랭킹 - 민트
      title: '출석왕 순위가 3위로 올랐어요 🏆',
      body: '이번 주 출석을 이어가면 더 올라갈 수 있어요.',
      time: '5일 전',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: '알림',
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Symbols.settings, color: AppColors.textSecondary),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: _items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 4),
        itemBuilder: (context, index) => _NotiTile(item: _items[index]),
      ),
    );
  }
}

class _Noti {
  const _Noti({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.time,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String time;
}

class _NotiTile extends StatelessWidget {
  const _NotiTile({required this.item});
  final _Noti item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Pressable(
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 아이콘 (항목별 색 틴트 원형)
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(item.icon, color: item.color, size: 22),
            ),
            const SizedBox(width: 14),

            // 내용
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // 시간
            Text(
              item.time,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
