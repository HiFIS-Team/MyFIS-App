import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// 홈 상단 고정 헤더 — 브랜드 로고 + 알림.
/// 다크 토스: 좌측 워드마크 브랜드, 우측 아이콘.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    this.hasNotification = false,
    this.onNotificationTap,
  });

  /// 안 읽은 알림 여부 — 벨 아이콘에 점 표시.
  final bool hasNotification;
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const _BrandWordmark(),
        const Spacer(),
        _NotificationButton(
          hasNotification: hasNotification,
          onTap: onNotificationTap,
        ),
      ],
    );
  }
}

/// 브랜드 워드마크 — "My" + 라임 "FIS".
/// (정식 로고 제작 전 텍스트 워드마크)
class _BrandWordmark extends StatelessWidget {
  const _BrandWordmark();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    const style = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
    );

    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: 'My', style: TextStyle(color: color)),
          const TextSpan(text: 'FIS', style: TextStyle(color: AppColors.lime)),
        ],
      ),
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
