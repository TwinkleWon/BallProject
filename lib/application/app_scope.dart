import 'package:flutter/widgets.dart';

import 'collection_controller.dart';

/// 위젯 트리에 [CollectionController]를 제공한다. 외부 패키지 없이 InheritedNotifier 사용.
class AppScope extends InheritedNotifier<CollectionController> {
  const AppScope({
    super.key,
    required CollectionController controller,
    required super.child,
  }) : super(notifier: controller);

  static CollectionController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
