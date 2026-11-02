# 아키텍처 설계

## 개발 환경
- Flutter 3.24.3 / Dart 3.5.3 (SDK: `D:\flutter_windows_3.22.2-stable\flutter`, PATH 미등록)
- VS Code / Windows, 타깃 iOS·Android (개발 중 확인은 Chrome·Windows로도 가능)
- 외부 패키지 없음 (2026-10 기준). 저장 기능 구현 시 `shared_preferences` 추가 예정.

```bash
D:\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat run -d chrome
```

## 레이어 구성

```
lib/
├─ main.dart                  의존성 조립 (여기서만 구현체를 고른다)
├─ domain/                    순수 모델 — 화면/저장 방식과 무관
│   ├─ ball.dart              Ball, BallPattern
│   ├─ ball_shape.dart        BallShape (r(θ) 반지름 함수 + Path 생성)
│   └─ rarity.dart            Rarity (라벨, 배출 weight, 색)
├─ data/                      데이터 출처
│   ├─ ball_catalog.dart      볼 마스터 20종
│   └─ collection_repository.dart  보유 데이터 저장소 (interface + InMemory)
├─ application/               앱 로직·상태
│   ├─ gacha_service.dart     추첨 (레어도 weight → 레어도 내 균등)
│   ├─ collection_controller.dart  ChangeNotifier, 보유 수·pull()
│   └─ app_scope.dart         InheritedNotifier로 컨트롤러 제공
└─ ui/
    ├─ theme.dart             색 토큰, ThemeData
    ├─ home_shell.dart        하단 탭
    ├─ screens/               gacha / collection / ball_detail
    └─ widgets/               BallView(CustomPainter), RarityBadge
```

의존 방향: `ui → application → data → domain` (역방향 import 금지).

## 설계 포인트
- **상태 관리:** 상태는 `CollectionController` 하나뿐이라 외부 라이브러리 없이
  `ChangeNotifier + InheritedNotifier`로 충분. 화면이 늘어 상태가 복잡해지면 Riverpod 등 검토.
- **저장소 교체:** `CollectionRepository` 인터페이스만 의존. 11월에
  `SharedPrefsCollectionRepository`를 만들고 `main.dart` 한 줄만 바꾼다.
- **테스트 용이성:** `GachaService`는 `Random`을 주입받아 시드 고정 테스트 가능.
- **볼 렌더링:** `BallPainter` 한 곳에서 그림자 → 형태 클리핑 → 그라데이션 → 무늬 → 하이라이트 순으로 그린다.
  11월 변형 구현은 `BallShape.buildPath`에 변형 파라미터를 넘기는 형태로 확장한다.

## 테스트
```bash
D:\flutter_windows_3.22.2-stable\flutter\bin\flutter.bat test
```
- `test/gacha_test.dart` — id 중복, 배출률(2만 회 시뮬레이션), pull/NEW 판정
- `test/widget_test.dart` — 가챠 → 결과 → 컬렉션 반영 흐름

## 11월 이후 (스케줄 대응)
| 기간 | 작업 | 손댈 곳 |
|---|---|---|
| 11/1~15 | 스트레스볼 인터랙션 | `ball_detail_screen.dart`, `BallShape`, 새 `SquishBall` 위젯 |
| 11/1~30 | 가챠 로직 | `gacha_service.dart`, 영구 저장 Repository |
| 11/16~12/15 | 도감·과금·사운드 | 컬렉션 확장, 재화 모델 추가 |
