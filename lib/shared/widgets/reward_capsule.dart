import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// 마일리지 적립 토스트 캡슐 — 회색 캡슐 + 라임 체크 + 문구.
/// 위에서 내려오는 토스트로 재사용 (카드 긁기·물 마시기 등).
class RewardCapsule extends StatelessWidget {
  const RewardCapsule({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(99),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.lime,
            ),
            child: const Icon(Icons.check_rounded,
                size: 15, color: Colors.black, weight: 800),
          ),
          const SizedBox(width: 9),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

/// 위에서 스르륵 내려왔다 사라지는 토스트 래퍼.
/// [progress] 0..1 (보통 2.8초짜리 컨트롤러) 를 받아 등장/유지/퇴장을 처리한다.
/// Stack 안에서 [Positioned]로 배치해 사용.
class TopToast extends StatelessWidget {
  const TopToast({super.key, required this.progress, required this.child});
  final double progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final appear = Curves.easeOut.transform((progress / 0.12).clamp(0.0, 1.0));
    final disappear =
        Curves.easeIn.transform(((progress - 0.86) / 0.14).clamp(0.0, 1.0));
    final op = (appear * (1 - disappear)).clamp(0.0, 1.0);
    final dy = -60 * (1 - appear) - 50 * disappear;
    return IgnorePointer(
      child: Opacity(
        opacity: op,
        child: Transform.translate(offset: Offset(0, dy), child: child),
      ),
    );
  }
}
