import 'package:ball_project/application/collection_controller.dart';
import 'package:ball_project/application/gacha_service.dart';
import 'package:ball_project/data/ball_catalog.dart';
import 'package:ball_project/data/collection_repository.dart';
import 'package:ball_project/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<CollectionController> _pumpApp(WidgetTester tester) async {
  // 머신 전체가 보이도록 폰 크기로 고정
  tester.view.physicalSize = const Size(1125, 2436);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final controller = CollectionController(
    catalog: ballCatalog,
    repository: InMemoryCollectionRepository(),
    gacha: GachaService(ballCatalog),
  );
  await controller.init();
  await tester.pumpWidget(BallApp(controller: controller));
  return controller;
}

void main() {
  testWidgets('ガチャを回すと結果が出てコレクションに反映される', (tester) async {
    final controller = await _pumpApp(tester);

    // 처음엔 컬렉션이 비어 있다
    await tester.tap(find.text('コレクション'));
    await tester.pumpAndSettle();
    expect(find.text('まだボールを持っていません'), findsOneWidget);

    // 빈 화면 버튼으로 가챠 탭으로 돌아가서 돌린다
    await tester.tap(find.text('ガチャへ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle(); // 핸들 회전 + 캡슐 배출
    await tester.pump(const Duration(milliseconds: 300)); // 결과 공개 전 대기
    await tester.pumpAndSettle();

    expect(find.text('NEW!'), findsOneWidget);
    expect(controller.totalPulls, 1);

    await tester.tap(find.text('コレクションを見る'));
    await tester.pumpAndSettle();
    expect(find.text('持っているボール 1 / 20種 · 合計 1個'), findsOneWidget);
    // 미보유 볼도 비활성 칸으로 함께 보인다
    expect(find.text('未入手'), findsWidgets);
  });

  testWidgets('図鑑は全種類を表示し、コンプリート率を出す', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('図鑑'));
    await tester.pumpAndSettle();

    expect(find.text('0 / 20  (0%)'), findsOneWidget);
    // 미보유여도 이름은 보인다 (SSR 섹션이 맨 위)
    expect(find.text(ballCatalog.last.name), findsOneWidget);
    expect(find.text('未入手'), findsWidgets);
  });
}
