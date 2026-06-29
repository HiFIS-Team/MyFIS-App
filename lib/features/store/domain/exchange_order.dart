/// 교환권(주문) 한 건.
class ExchangeOrder {
  const ExchangeOrder({
    required this.name,
    required this.number,
    required this.qty,
    required this.date,
    required this.done,
  });

  final String name;
  final String number; // 교환번호 (프론트 제시용)
  final int qty;
  final String date;
  final bool done; // 수령 완료 여부
}
