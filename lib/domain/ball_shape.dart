import 'dart:math' as math;
import 'dart:ui';

/// 볼의 외형. 캐릭터 그림 없이 "도형"만으로 개성을 낸다.
///
/// 모든 형태는 극좌표 반지름 함수 r(θ)로 정의한다.
/// 11월 변형 구현 때 이 r(θ)에 누른 위치 기준의 오프셋을 더하는 것만으로
/// 어떤 형태든 같은 방식으로 찌그러뜨릴 수 있게 하기 위함.
enum BallShape {
  round('まる'),
  squircle('しかく'),
  egg('たまご'),
  flower('はな'),
  wave('なみ');

  const BallShape(this.label);

  final String label;

  /// θ 방향의 반지름 (기준 반지름 1.0 대비 비율). 화면 좌표계라 θ=π/2가 아래쪽.
  double radiusAt(double theta) {
    switch (this) {
      case BallShape.round:
        return 1.0;
      case BallShape.squircle:
        const n = 4.0;
        final c = math.cos(theta).abs();
        final s = math.sin(theta).abs();
        return 0.86 *
            math.pow(math.pow(c, n) + math.pow(s, n), -1 / n).toDouble();
      case BallShape.egg:
        return 0.9 + 0.08 * math.sin(theta);
      case BallShape.flower:
        return 0.9 + 0.08 * math.cos(6 * theta);
      case BallShape.wave:
        return 0.93 + 0.06 * math.sin(3 * theta + 0.6);
    }
  }

  /// [center]를 중심으로 [radius] 크기의 외곽 Path를 만든다.
  Path buildPath(Offset center, double radius, {int samples = 96}) {
    final path = Path();
    for (var i = 0; i <= samples; i++) {
      final theta = 2 * math.pi * i / samples;
      final r = radius * radiusAt(theta);
      final p = center + Offset(math.cos(theta) * r, math.sin(theta) * r);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    return path..close();
  }
}
