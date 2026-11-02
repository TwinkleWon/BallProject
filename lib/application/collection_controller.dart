import 'package:flutter/foundation.dart';

import '../data/collection_repository.dart';
import '../domain/ball.dart';
import 'gacha_service.dart';

class PullResult {
  const PullResult(this.ball, {required this.isNew});

  final Ball ball;
  final bool isNew;
}

/// 앱 상태(보유 볼)를 들고 있는 유일한 컨트롤러. 화면은 이것만 바라본다.
class CollectionController extends ChangeNotifier {
  CollectionController({
    required this.catalog,
    required CollectionRepository repository,
    required GachaService gacha,
  })  : _repository = repository,
        _gacha = gacha;

  final List<Ball> catalog;
  final CollectionRepository _repository;
  final GachaService _gacha;

  Map<String, int> _counts = {};

  Future<void> init() async {
    _counts = await _repository.load();
    notifyListeners();
  }

  int countOf(Ball ball) => _counts[ball.id] ?? 0;
  bool isOwned(Ball ball) => countOf(ball) > 0;
  int get ownedKinds => catalog.where(isOwned).length;
  int get totalPulls => _counts.values.fold(0, (a, b) => a + b);

  Future<PullResult> pull() async {
    final ball = _gacha.draw();
    final isNew = !isOwned(ball);
    _counts = {..._counts, ball.id: countOf(ball) + 1};
    notifyListeners();
    await _repository.save(_counts);
    return PullResult(ball, isNew: isNew);
  }
}
