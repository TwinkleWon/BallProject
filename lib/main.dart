import 'package:flutter/material.dart';

import 'application/app_scope.dart';
import 'application/collection_controller.dart';
import 'application/gacha_service.dart';
import 'data/ball_catalog.dart';
import 'data/collection_repository.dart';
import 'ui/home_shell.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 의존성 조립은 여기 한 곳에서만 한다. 저장소 교체(11月)도 이 줄만 바꾸면 된다.
  final controller = CollectionController(
    catalog: ballCatalog,
    repository: InMemoryCollectionRepository(),
    gacha: GachaService(ballCatalog),
  );
  await controller.init();

  runApp(BallApp(controller: controller));
}

class BallApp extends StatelessWidget {
  const BallApp({super.key, required this.controller});

  final CollectionController controller;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: controller,
      child: MaterialApp(
        title: 'ストレスボールガチャ',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const HomeShell(),
      ),
    );
  }
}
