import 'dart:math';

import '../domain/ball.dart';
import '../domain/rarity.dart';

/// 추첨 로직. ① 레어도를 weight로 뽑고 ② 그 레어도 안에서 균등하게 1종을 뽑는다.
///
/// 10월 시점에는 화면 흐름 확인용 최소 구현. 천장·연속 뽑기 등은 11월에 확장.
class GachaService {
  GachaService(this.catalog, {Random? random}) : _random = random ?? Random();

  final List<Ball> catalog;
  final Random _random;

  Ball draw() {
    final available =
        Rarity.values.where((r) => catalog.any((b) => b.rarity == r)).toList();
    final total = available.fold<int>(0, (sum, r) => sum + r.weight);

    var roll = _random.nextInt(total);
    var rarity = available.last;
    for (final r in available) {
      if (roll < r.weight) {
        rarity = r;
        break;
      }
      roll -= r.weight;
    }

    final pool = catalog.where((b) => b.rarity == rarity).toList();
    return pool[_random.nextInt(pool.length)];
  }
}
