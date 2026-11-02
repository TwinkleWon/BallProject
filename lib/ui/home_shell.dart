import 'package:flutter/material.dart';

import 'screens/collection_screen.dart';
import 'screens/gacha_screen.dart';
import 'screens/zukan_screen.dart';

/// 하단 탭: ガチャ(메인) / コレクション(보유 볼) / 図鑑(전체 종류)
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const _gacha = 0;
  static const _collection = 1;

  int _index = _gacha;

  void _select(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          GachaScreen(onOpenCollection: () => _select(_collection)),
          CollectionScreen(onGoToGacha: () => _select(_gacha)),
          const ZukanScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _select,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'ガチャ',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'コレクション',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: '図鑑',
          ),
        ],
      ),
    );
  }
}
