import 'dart:ui';

/// 레어도와 가챠 배출 확률(weight 합계 100 = %).
enum Rarity {
  n('N', 60, Color(0xFF9E9AAE)),
  r('R', 28, Color(0xFF5BA8E0)),
  sr('SR', 10, Color(0xFFB57BE8)),
  ssr('SSR', 2, Color(0xFFF2B33D));

  const Rarity(this.label, this.weight, this.color);

  final String label;
  final int weight;
  final Color color;
}
