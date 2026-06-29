import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// 홈 상단 헤더 — 인사 + 알림.
/// 다크 토스: 이름은 굵게 크게, 인사말은 보조 톤.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.userName,
    this.hasNotification = false,
    this.onNotificationTap,
  });

  /// 사용자 이름 (예: "은후"). 데이터 연동 전 더미.
  final String userName;

  /// 안 읽은 알림 여부 — 벨 아이콘에 점 표시.
  final bool hasNotification;
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            '$userName님 👋',
            style: textTheme.headlineSmall,
          ),
        ),
        _NotificationButton(
          hasNotification: hasNotification,
          onTap: onNotificationTap,
        ),
      ],
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.hasNotification, this.onTap});

  final bool hasNotification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onTap,
          iconSize: 26,
          icon: const Icon(Icons.notifications_outlined),
          color: Theme.of(context).colorScheme.onSurface,
        ),
        if (hasNotification)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.lime,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
