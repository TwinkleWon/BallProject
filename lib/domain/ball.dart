import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'ball_shape.dart';
import 'rarity.dart';

/// 볼 표면 무늬. 색 2개(base / accent)와 조합해 바리에이션을 만든다.
enum BallPattern {
  solid('むじ'),
  dots('ドット'),
  stripes('ストライプ'),
  twoTone('ツートン'),
  sparkle('キラキラ');

  const BallPattern(this.label);

  final String label;
}

/// 레어 볼에 붙는 동물 캐릭터. 그림 에셋이 아니라 귀·얼굴을 도형으로 그린다.
enum BallCharacter {
  cat('ねこ'),
  dog('いぬ'),
  rabbit('うさぎ'),
  bear('くま'),
  penguin('ペンギン');

  const BallCharacter(this.label);

  final String label;
}

/// 볼 1종의 마스터 데이터. 볼 = 형태 × 색 × 무늬 × 레어도 (+ 레어는 캐릭터).
@immutable
class Ball {
  const Ball({
    required this.id,
    required this.name,
    required this.shape,
    required this.pattern,
    required this.base,
    required this.accent,
    required this.rarity,
    this.character,
  });

  final String id;
  final String name;
  final BallShape shape;
  final BallPattern pattern;
  final Color base;
  final Color accent;
  final Rarity rarity;

  /// null이면 일반 볼(도형만), 값이 있으면 동물 캐릭터 볼.
  final BallCharacter? character;

  @override
  bool operator ==(Object other) => other is Ball && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
