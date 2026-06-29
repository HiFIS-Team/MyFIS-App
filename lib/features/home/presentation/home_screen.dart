import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 하단 네비게이션을 가진 메인 셸 화면.
/// GoRouter의 StatefulShellRoute와 함께 사용된다.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      // 이미 선택된 탭을 다시 누르면 해당 탭의 첫 화면으로 이동
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: '운동',
          ),
          NavigationDestination(
            icon: Icon(Icons.card_membership_outlined),
            selectedIcon: Icon(Icons.card_membership),
            label: '멤버십',
          ),
        ],
      ),
    );
  }
}
