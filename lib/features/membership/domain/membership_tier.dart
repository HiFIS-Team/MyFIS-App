import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// 회원 등급 (이번 시즌 출석 횟수 기반). (현재 더미)
class MembershipTier {
  const MembershipTier({
    required this.name,
    required this.threshold,
    required this.color1,
    required this.color2,
  });

  final String name; // 브론즈 / 실버 / 골드 / 다이아
  final int threshold; // 이 등급이 되는 최소 출석 횟수
  final Color color1;
  final Color color2;
}

/// 등급 사다리 (오름차순).
const List<MembershipTier> kTiers = [
  MembershipTier(
    name: '브론즈',
    threshold: 0,
    color1: Color(0xFF3A2A1C),
    color2: Color(0xFF7A5230),
  ),
  MembershipTier(
    name: '실버',
    threshold: 5,
    color1: Color(0xFF2B2F33),
    color2: Color(0xFF8A93A0),
  ),
  MembershipTier(
    name: '골드',
    threshold: 12,
    color1: Color(0xFF3B300F),
    color2: Color(0xFFC9A227),
  ),
  MembershipTier(
    name: '다이아',
    threshold: 20,
    color1: Color(0xFF11303A),
    color2: Color(0xFF35B6C9),
  ),
];

/// 등급 혜택 항목.
class TierBenefit {
  const TierBenefit({
    required this.icon,
    required this.title,
    required this.desc,
  });

  final IconData icon;
  final String title;
  final String desc;
}

/// 이번 시즌 내 출석 횟수 (더미).
const int kMyAttendance = 17;

/// 현재 등급 혜택 (골드 기준 더미).
const List<TierBenefit> kTierBenefits = [
  TierBenefit(
    icon: Symbols.trending_up,
    title: '마일리지 2배',
    desc: '적립률 2배',
  ),
  TierBenefit(
    icon: Symbols.exercise,
    title: '무료 PT',
    desc: '월 1회 제공',
  ),
  TierBenefit(
    icon: Symbols.local_cafe,
    title: '제휴 카페',
    desc: '10% 할인',
  ),
  TierBenefit(
    icon: Symbols.weekend,
    title: '라운지',
    desc: '무료 이용',
  ),
];

/// 현재 등급 인덱스 (출석 횟수로 산정).
int currentTierIndex(int attendance) {
  var idx = 0;
  for (var i = 0; i < kTiers.length; i++) {
    if (attendance >= kTiers[i].threshold) idx = i;
  }
  return idx;
}
