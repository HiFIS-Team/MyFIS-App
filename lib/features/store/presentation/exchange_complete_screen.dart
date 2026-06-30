import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';

/// 교환 완료 화면 (토스 이체/결제 완료 스타일).
/// 장바구니에서 교환하면 풀스크린으로 페이드 진입한다.
class ExchangeCompleteScreen extends StatefulWidget {
  const ExchangeCompleteScreen({
    super.key,
    required this.summary,
    required this.totalPoints,
  });

  /// 교환 요약 (예: "프로틴 쉐이커 외 1건").
  final String summary;
  final int totalPoints;

  @override
  State<ExchangeCompleteScreen> createState() => _ExchangeCompleteScreenState();
}

class _ExchangeCompleteScreenState extends State<ExchangeCompleteScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final total = widget.totalPoints;

    // 체크 아이콘: 팝 등장(스케일 elasticOut) + 페이드
    final scale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
    );
    final fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    // 텍스트/카드는 살짝 늦게 부드럽게
    final contentFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 체크 원형
                    FadeTransition(
                      opacity: fade,
                      child: ScaleTransition(
                        scale: scale,
                        child: Container(
                          width: 92,
                          height: 92,
                          decoration: const BoxDecoration(
                            color: AppColors.lime,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Symbols.check_rounded,
                              size: 52, color: Colors.black, weight: 700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    FadeTransition(
                      opacity: contentFade,
                      child: Column(
                        children: [
                          Text(
                            '교환 완료!',
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '프론트에서 상품을 수령하세요.',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 32),
                          // 교환 정보 카드
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  _InfoRow(
                                    label: '상품',
                                    value: widget.summary,
                                  ),
                                  const SizedBox(height: 14),
                                  _InfoRow(
                                    label: '차감 마일리지',
                                    value: '${_comma(total)}P',
                                    valueColor: AppColors.textPrimary,
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                      height: 1, color: AppColors.outline),
                                  const SizedBox(height: 16),
                                  _InfoRow(
                                    label: '교환번호',
                                    value: 'A3F92',
                                    valueColor: AppColors.textPrimary,
                                  ),
                                  const SizedBox(height: 6),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      '프론트에서 이 번호를 제시하세요',
                                      style: textTheme.bodySmall?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 확인 버튼
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: FilledButton(
                // 확인 → 상세·완료 화면 모두 닫고 스토어로 이동
                onPressed: () => context.go('/store'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  '확인',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

/// 천 단위 콤마.
String _comma(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}
