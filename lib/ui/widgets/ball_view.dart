import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/ball.dart';
import '../theme.dart';
import 'character_art.dart';

/// 볼 1개를 도형과 색만으로 그린다. 이미지 에셋은 쓰지 않는다.
class BallView extends StatelessWidget {
  const BallView({
    super.key,
    required this.ball,
    this.size = 96,
    this.locked = false,
  });

  final Ball ball;
  final double size;

  /// 미보유 상태: 형태만 회색 실루엣으로 보여준다.
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: BallPainter(ball, locked: locked)),
    );
  }
}

class BallPainter extends CustomPainter {
  BallPainter(this.ball, {this.locked = false});

  final Ball ball;
  final bool locked;

  @override
  void paint(Canvas canvas, Size size) {
    // 레어 볼은 동물 캐릭터 그림으로
    if (ball.character != null) {
      CharacterArt.paint(canvas, size, ball, locked: locked);
      return;
    }

    final radius = size.shortestSide * 0.42;
    final center = Offset(size.width / 2, size.height / 2 - radius * 0.04);
    final base = locked ? AppColors.locked : ball.base;

    // 바닥 그림자
    canvas.drawOval(
      Rect.fromCenter(
        center: center + Offset(0, radius * 1.02),
        width: radius * 1.5,
        height: radius * 0.22,
      ),
      Paint()
        ..color = Colors.black.withOpacity(0.10)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.06),
    );

    final path = ball.shape.buildPath(center, radius);
    final bounds = Rect.fromCircle(center: center, radius: radius * 1.2);

    canvas.save();
    canvas.clipPath(path);

    // 입체감: 왼쪽 위가 밝고 오른쪽 아래가 어두운 방사형 그라데이션
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.45),
          radius: 0.95,
          colors: [
            Color.lerp(base, Colors.white, 0.45)!,
            base,
            Color.lerp(base, Colors.black, 0.12)!,
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(bounds),
    );

    if (!locked) _paintPattern(canvas, center, radius);

    // 광택 하이라이트
    canvas.drawOval(
      Rect.fromCenter(
        center: center + Offset(-radius * 0.35, -radius * 0.45),
        width: radius * 0.55,
        height: radius * 0.32,
      ),
      Paint()
        ..color = Colors.white.withOpacity(0.55)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.08),
    );
    canvas.restore();

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, radius * 0.025)
        ..color = Color.lerp(base, Colors.black, 0.18)!.withOpacity(0.35),
    );
  }

  void _paintPattern(Canvas canvas, Offset c, double r) {
    final paint = Paint()..color = ball.accent.withOpacity(0.85);
    switch (ball.pattern) {
      case BallPattern.solid:
        break;
      case BallPattern.dots:
        final step = r * 0.42;
        var row = 0;
        for (var y = c.dy - r; y <= c.dy + r; y += step, row++) {
          final shift = row.isOdd ? step / 2 : 0.0;
          for (var x = c.dx - r - shift; x <= c.dx + r; x += step) {
            canvas.drawCircle(Offset(x, y), r * 0.085, paint);
          }
        }
      case BallPattern.stripes:
        canvas.save();
        canvas.translate(c.dx, c.dy);
        canvas.rotate(-0.5);
        for (var x = -r * 1.4; x < r * 1.4; x += r * 0.42) {
          canvas.drawRect(Rect.fromLTWH(x, -r * 1.4, r * 0.18, r * 2.8), paint);
        }
        canvas.restore();
      case BallPattern.twoTone:
        canvas.drawRect(
          Rect.fromLTRB(
              c.dx - r * 1.2, c.dy + r * 0.1, c.dx + r * 1.2, c.dy + r * 1.2),
          paint,
        );
      case BallPattern.sparkle:
        const spots = [
          (0.35, -0.25, 0.22),
          (-0.3, 0.3, 0.16),
          (0.25, 0.45, 0.12),
          (-0.05, -0.6, 0.1),
          (0.6, 0.15, 0.09),
        ];
        for (final (dx, dy, s) in spots) {
          _drawStar(canvas, c + Offset(dx * r, dy * r), s * r, paint);
        }
    }
  }

  /// 4갈래 반짝이 별
  void _drawStar(Canvas canvas, Offset p, double s, Paint paint) {
    final w = s * 0.28;
    final star = Path()
      ..moveTo(p.dx, p.dy - s)
      ..quadraticBezierTo(p.dx + w, p.dy - w, p.dx + s, p.dy)
      ..quadraticBezierTo(p.dx + w, p.dy + w, p.dx, p.dy + s)
      ..quadraticBezierTo(p.dx - w, p.dy + w, p.dx - s, p.dy)
      ..quadraticBezierTo(p.dx - w, p.dy - w, p.dx, p.dy - s)
      ..close();
    canvas.drawPath(star, paint);
  }

  @override
  bool shouldRepaint(BallPainter oldDelegate) =>
      oldDelegate.ball != ball || oldDelegate.locked != locked;
}
