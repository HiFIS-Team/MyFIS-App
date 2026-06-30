/// 랭킹 한 명의 항목.
class RankEntry {
  const RankEntry(
    this.rank,
    this.name,
    this.value, {
    this.change = 0,
    this.isNew = false,
    this.isMe = false,
  });

  final int rank;
  final String name;
  final int value;
  final int change; // >0 상승, <0 하락, 0 변동 없음
  final bool isNew;
  final bool isMe;
}

/// 랭킹 보드(출석왕 / 지인소개왕 등).
class RankBoard {
  const RankBoard({
    required this.label,
    required this.unit,
    required this.entries,
  });

  final String label;
  final String unit;
  final List<RankEntry> entries;
}

/// 랭킹 더미 데이터. 홈 미리보기(상위 10)·전체 랭킹 페이지 공용.
const List<RankBoard> kRankBoards = [
  RankBoard(label: '출석왕', unit: '일', entries: [
    RankEntry(1, '김철수', 28, change: 2),
    RankEntry(2, '이영희', 25),
    RankEntry(3, '박민수', 24, change: 5),
    RankEntry(4, '정수진', 22, change: -1),
    RankEntry(5, '최동욱', 21, change: 1),
    RankEntry(6, '강민지', 20, isNew: true),
    RankEntry(7, '나', 18, change: 3, isMe: true),
    RankEntry(8, '윤서연', 17, change: -2),
    RankEntry(9, '임재현', 16),
    RankEntry(10, '한지우', 15, change: 1),
    RankEntry(11, '오세훈', 14, change: -3),
    RankEntry(12, '장도연', 13, change: 2),
    RankEntry(13, '신유빈', 12),
    RankEntry(14, '문상혁', 11, change: -1),
    RankEntry(15, '배수지', 10, isNew: true),
    RankEntry(16, '권지용', 9, change: 1),
    RankEntry(17, '한소희', 8, change: -2),
    RankEntry(18, '차은우', 7),
  ]),
  RankBoard(label: '지인소개왕', unit: '명', entries: [
    RankEntry(1, '박지연', 12, change: 1),
    RankEntry(2, '정우성', 9),
    RankEntry(3, '나', 6, change: 4, isMe: true),
    RankEntry(4, '이준호', 5, change: -2),
    RankEntry(5, '송미라', 5),
    RankEntry(6, '김하늘', 4, isNew: true),
    RankEntry(7, '오세훈', 4, change: -1),
    RankEntry(8, '장도연', 3, change: 2),
    RankEntry(9, '신유빈', 3),
    RankEntry(10, '문상혁', 2, change: -3),
    RankEntry(11, '배수지', 2),
    RankEntry(12, '권지용', 2, change: 1),
    RankEntry(13, '한소희', 1),
    RankEntry(14, '차은우', 1, isNew: true),
    RankEntry(15, '김태형', 1),
    RankEntry(16, '전정국', 1, change: 1),
  ]),
];
