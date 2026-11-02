import 'dart:math';

import 'package:ball_project/application/collection_controller.dart';
import 'package:ball_project/application/gacha_service.dart';
import 'package:ball_project/data/ball_catalog.dart';
import 'package:ball_project/data/collection_repository.dart';
import 'package:ball_project/domain/rarity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('カタログのidは重複しない', () {
    final ids = ballCatalog.map((b) => b.id).toSet();
    expect(ids.length, ballCatalog.length);
  });

  test('排出率がレアリティのweightに近い', () {
    final gacha = GachaService(ballCatalog, random: Random(42));
    const n = 20000;
    final hits = <Rarity, int>{};
    for (var i = 0; i < n; i++) {
      final r = gacha.draw().rarity;
      hits[r] = (hits[r] ?? 0) + 1;
    }
    for (final r in Rarity.values) {
      expect(hits[r]! / n * 100, closeTo(r.weight, 1.5), reason: r.label);
    }
  });

  test('pullで所持数が増え、2回目以降はNEWにならない', () async {
    final repo = InMemoryCollectionRepository();
    final only = [ballCatalog.first];
    final controller = CollectionController(
      catalog: only,
      repository: repo,
      gacha: GachaService(only),
    );
    await controller.init();

    expect((await controller.pull()).isNew, isTrue);
    expect((await controller.pull()).isNew, isFalse);
    expect(controller.countOf(only.first), 2);
    expect(await repo.load(), {only.first.id: 2});
  });
}
