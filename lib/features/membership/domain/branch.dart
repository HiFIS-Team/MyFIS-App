import 'package:flutter/material.dart';

/// 헬스장 지점. (현재 더미 — 추후 백엔드 연동)
/// 사진 에셋이 없어 [color1]~[color2] 그라데이션으로 사진 자리를 대신한다.
class Branch {
  const Branch({
    required this.name,
    required this.address,
    required this.hours,
    required this.intro,
    required this.facilities,
    required this.color1,
    required this.color2,
  });

  final String name;
  final String address;
  final String hours; // 운영 시간 등 한 줄 정보
  final String intro; // 지점 소개 문구
  final List<String> facilities; // 편의시설
  final Color color1;
  final Color color2;
}

/// 지점 목록 (3개 지점).
const List<Branch> kBranches = [
  Branch(
    name: 'MyFIS 강남점',
    address: '서울 강남구 테헤란로 123',
    hours: '연중무휴 · 06:00–24:00',
    intro:
        '강남 한복판, 최신 머신과 넓은 프리웨이트 존을 갖춘 플래그십 지점입니다. '
        '전문 트레이너 상주로 1:1 PT와 그룹 GX 클래스를 운영해요.',
    facilities: ['주차 가능', '샤워실', '사우나', 'PT', 'GX 클래스', '운동복 대여'],
    color1: Color(0xFF1E3A1A),
    color2: Color(0xFF5C8A2E),
  ),
  Branch(
    name: 'MyFIS 홍대점',
    address: '서울 마포구 양화로 45',
    hours: '연중무휴 · 24시간',
    intro:
        '24시간 언제든 운동할 수 있는 홍대점. 유산소 머신과 크로스핏 존이 넉넉하고 '
        '젊은 분위기의 커뮤니티 이벤트가 활발합니다.',
    facilities: ['24시간', '샤워실', '크로스핏 존', '유산소 특화', '운동복 대여'],
    color1: Color(0xFF1B2C3D),
    color2: Color(0xFF3E6E9E),
  ),
  Branch(
    name: 'MyFIS 잠실점',
    address: '서울 송파구 올림픽로 240',
    hours: '연중무휴 · 06:00–24:00',
    intro:
        '잠실 대로변의 대형 지점으로, 넓은 스트레칭·필라테스 존과 가족 단위 회원을 위한 '
        '편의시설을 잘 갖췄습니다. 주차가 편리해요.',
    facilities: ['넓은 주차장', '샤워실', '사우나', '필라테스', 'PT', '락커 대형'],
    color1: Color(0xFF2E2440),
    color2: Color(0xFF6E5AA0),
  ),
];
