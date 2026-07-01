import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_top_bar.dart';

/// 프로필 상세 화면.
/// 마이페이지 프로필 카드(>)에서 오른쪽→왼쪽 슬라이드로 진입.
/// 가입 시 입력 정보(기본·신체·가입정보)를 보여준다. 현재는 더미 데이터.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const AppTopBar(title: '프로필'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          // 상단: 큰 아바타 + 이름 + 전화번호
          Column(
            children: [
              Container(
                width: 88,
                height: 88,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Symbols.person,
                    color: AppColors.textSecondary, size: 48, fill: 1),
              ),
              const SizedBox(height: 14),
              Text(
                '김은후',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '010-1234-5678',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          _InfoCard(title: '기본 정보', rows: const [
            _InfoRow(label: '이름', value: '김은후'),
            _InfoRow(label: '전화번호 (아이디)', value: '010-1234-5678'),
            _InfoRow(label: '나이', value: '28세'),
            _InfoRow(label: '성별', value: '남성', isLast: true),
          ]),
          const SizedBox(height: 16),

          _InfoCard(title: '신체 정보', rows: const [
            _InfoRow(label: '키', value: '175 cm'),
            _InfoRow(label: '몸무게', value: '70 kg'),
            _InfoRow(label: 'BMI', value: '22.9 (정상)', isLast: true),
          ]),
          const SizedBox(height: 16),

          _InfoCard(title: '가입 정보', rows: const [
            _InfoRow(label: '유입경로', value: '인스타그램'),
            _InfoRow(label: '방문목적', value: '체중 감량'),
            _InfoRow(label: '추천인', value: '없음', isLast: true),
          ]),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: FilledButton(
          onPressed: () {},
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            '프로필 수정',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.lime,
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.rows});
  final String title;
  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(children: rows),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: [
              Text(
                label,
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.outline,
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }
}
