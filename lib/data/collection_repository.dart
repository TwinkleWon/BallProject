/// 컬렉션(볼 id → 보유 개수) 저장소.
///
/// 지금은 메모리 구현만 있다. 11월 가챠/컬렉션 저장 구현 때
/// shared_preferences 등을 쓰는 구현을 추가하고 main.dart에서 교체한다.
abstract interface class CollectionRepository {
  Future<Map<String, int>> load();
  Future<void> save(Map<String, int> counts);
}

class InMemoryCollectionRepository implements CollectionRepository {
  InMemoryCollectionRepository([Map<String, int>? initial])
      : _counts = {...?initial};

  Map<String, int> _counts;

  @override
  Future<Map<String, int>> load() async => {..._counts};

  @override
  Future<void> save(Map<String, int> counts) async => _counts = {...counts};
}
