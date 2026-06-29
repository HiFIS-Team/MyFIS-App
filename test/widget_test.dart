import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:myfis_app/main.dart';

void main() {
  testWidgets('앱이 정상적으로 빌드되고 탭이 표시된다', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyFisApp()));
    await tester.pumpAndSettle();

    // 하단 네비게이션의 4개 탭 라벨 확인
    expect(find.text('홈'), findsWidgets);
    expect(find.text('운동'), findsWidgets);
    expect(find.text('랭킹'), findsWidgets);
    expect(find.text('마이'), findsWidgets);
  });

  testWidgets('홈 헤더에 알림 아이콘이 보인다', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyFisApp()));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
  });
}
