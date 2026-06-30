import 'package:flutter/material.dart';

/// 헬스장 지점. (현재 더미 — 추후 백엔드 연동)
/// 사진 에셋이 없어 [color1]~[color2] 그라데이션으로 사진 자리를 대신한다.
class Branch {
  const Branch({
    required this.name,
    required this.address,
    required this.hours,
    required this.color1,
    required this.color2,
  });

  final String name;
  final String address;
  final String hours; // 운영 시간 등 한 줄 정보
  final Color color1;
  final Color color2;
}

/// 지점 목록 (3개 지점).
const List<Branch> kBranches = [
  Branch(
    name: 'MyFIS 강남점',
    address: '서울 강남구 테헤란로 123',
    hours: '연중무휴 · 06:00–24:00',
    color1: Color(0xFF1E3A1A),
    color2: Color(0xFF5C8A2E),
  ),
  Branch(
    name: 'MyFIS 홍대점',
    address: '서울 마포구 양화로 45',
    hours: '연중무휴 · 24시간',
    color1: Color(0xFF1B2C3D),
    color2: Color(0xFF3E6E9E),
  ),
  Branch(
    name: 'MyFIS 잠실점',
    address: '서울 송파구 올림픽로 240',
    hours: '연중무휴 · 06:00–24:00',
    color1: Color(0xFF2E2440),
    color2: Color(0xFF6E5AA0),
  ),
];
