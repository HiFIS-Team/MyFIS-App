import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_colors.dart';

/// 홈 상단 고정 헤더 — 브랜드 로고 + 알림.
/// 다크 토스: 좌측 워드마크 브랜드, 우측 아이콘.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    this.hasNotification = false,
    this.onNotificationTap,
    this.onCheckInTap,
    this.onMembershipTap,
  });

  /// 안 읽은 알림 여부 — 벨 아이콘에 점 표시.
  final bool hasNotification;
  final VoidCallback? onNotificationTap;

  /// 출석 체크 (QR 스캔).
  final VoidCallback? onCheckInTap;

  /// 멤버십 관리.
  final VoidCallback? onMembershipTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).colorScheme.onSurface;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const _BrandWordmark(),
        const Spacer(),
        // 멤버십 관리 (카드)
        IconButton(
          onPressed: onMembershipTap,
          iconSize: 26,
          icon: const Icon(Symbols.credit_card),
          color: iconColor,
        ),
        // 출석 체크 (바코드 + 스캔 프레임)
        IconButton(
          onPressed: onCheckInTap,
          iconSize: 26,
          icon: const Icon(Symbols.barcode_scanner, fill: 1),
          color: iconColor,
        ),
        _NotificationButton(
          hasNotification: hasNotification,
          onTap: onNotificationTap,
        ),
      ],
    );
  }
}

/// 브랜드 워드마크 — MyFIS 로고 (플랫, "My" 흰색 + "FIS" 라임).
class _BrandWordmark extends StatelessWidget {
  const _BrandWordmark();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      height: 22,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
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
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
