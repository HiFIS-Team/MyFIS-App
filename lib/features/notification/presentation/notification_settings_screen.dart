import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_top_bar.dart';

/// 알림 설정 — 푸시 알림 종류별 on/off. (현재 더미, 인메모리)
/// 마이페이지 '알림 설정' · 홈 알림 화면의 설정 아이콘에서 진입.
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _Item {
  const _Item(this.key, this.title, [this.subtitle]);
  final String key;
  final String title;
  final String? subtitle;
}

class _Section {
  const _Section(this.title, this.items);
  final String title;
  final List<_Item> items;
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  static const List<_Section> _sections = [
    _Section('운동 · 출석', [
      _Item('workout', '운동 리마인더', '오늘 운동 안 했으면 알려줘요'),
      _Item('streak', '출석 스트릭 알림', '연속 출석이 끊기기 전에 알림'),
    ]),
    _Section('미션 · 마일리지', [
      _Item('mission', '데일리 미션 알림', '오늘의 미션을 알려줘요'),
      _Item('earn', '마일리지 적립 알림'),
      _Item('expire', '마일리지 소멸 예정', '만료 임박 마일리지 안내'),
    ]),
    _Section('멤버십', [
      _Item('membership', '멤버십 만료 임박', '갱신 시점을 알려줘요'),
    ]),
    _Section('혜택 · 마케팅', [
      _Item('event', '이벤트 · 혜택 소식', '프로모션 · 신상품 안내'),
      _Item('coupon', '교환권 만료 알림'),
    ]),
  ];

  bool _master = true;
  // 초기값(더미): 마케팅성 이벤트만 off.
  final Map<String, bool> _values = {
    'workout': true,
    'streak': true,
    'mission': true,
    'earn': true,
    'expire': true,
    'membership': true,
    'event': false,
    'coupon': true,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: '알림 설정'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          // 마스터 스위치
          _Card(
            children: [
              _ToggleRow(
                title: '푸시 알림 전체',
                subtitle: _master ? '알림을 받고 있어요' : '모든 알림이 꺼져 있어요',
                value: _master,
                enabled: true,
                onChanged: (v) => setState(() => _master = v),
              ),
            ],
          ),
          const SizedBox(height: 20),

          for (final section in _sections) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
              child: Text(
                section.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            _Card(
              children: [
                for (final item in section.items)
                  _ToggleRow(
                    title: item.title,
                    subtitle: item.subtitle,
                    value: _master && _values[item.key]!,
                    enabled: _master,
                    onChanged: (v) => setState(() => _values[item.key] = v),
                  ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}

/// 둥근 카드 컨테이너.
class _Card extends StatelessWidget {
  const _Card({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: children),
    );
  }
}

/// 토글 한 줄 — 제목(+설명) + 스위치.
class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.value,
    required this.enabled,
    required this.onChanged,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: textTheme.bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Switch(
              value: value,
              onChanged: enabled ? onChanged : null,
              thumbColor: WidgetStateProperty.resolveWith(
                (s) => s.contains(WidgetState.selected)
                    ? AppColors.background
                    : AppColors.textSecondary,
              ),
              trackColor: WidgetStateProperty.resolveWith(
                (s) => s.contains(WidgetState.selected)
                    ? AppColors.lime
                    : AppColors.surfaceAlt,
              ),
              trackOutlineColor:
                  WidgetStateProperty.all(Colors.transparent),
            ),
          ],
        ),
      ),
    );
  }
}
