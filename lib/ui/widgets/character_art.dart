import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/ball.dart';
import '../../domain/rarity.dart';
import '../theme.dart';

/// 레어 볼용 동물 캐릭터 그림.
///
/// 말랑한 모찌 몸통 위에 귀·얼굴·손발·소품을 얹는다. 모든 좌표는 몸통 반지름 r에
/// 대한 비율이라 어떤 크기로 그려도 비율이 유지된다.
class CharacterArt {
  CharacterArt._(this.canvas, this.ball, this.c, this.r, this.locked);

  static void paint(Canvas canvas, Size size, Ball ball,
      {bool locked = false}) {
    final r = size.shortestSide * 0.34;
    final c = Offset(size.width / 2, size.height * 0.56);
    CharacterArt._(canvas, ball, c, r, locked)._paint();
  }

  final Canvas canvas;
  final Ball ball;
  final Offset c;
  final double r;
  final bool locked;

  static const _ink = Color(0xFF4A3F55);
  static const _blush = Color(0xFFFF8FA3);
  static const _pad = Color(0xFFFFA8BA);
  static const _gold = Color(0xFFFFD54F);

  BallCharacter get _kind => ball.character!;
  Color get _base => locked ? AppColors.locked : ball.base;
  bool get _isSsr => ball.rarity == Rarity.ssr;

  Offset _p(double x, double y) => c + Offset(x * r, y * r);
  Rect _rect(double x, double y, double w, double h) =>
      Rect.fromCenter(center: _p(x, y), width: w * r, height: h * r);
  Color _shade(double t) => Color.lerp(_base, Colors.black, t)!;
  Color _tint(double t) => Color.lerp(_base, Colors.white, t)!;
  Paint _fill(Color color) => Paint()..color = color;
  Paint _stroke(Color color, double width) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width * r
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  void _paint() {
    _shadow();
    _earsBehind();
    if (_kind == BallCharacter.penguin) _flippers();
    _body();
    _feet();
    if (locked) return;
    _markings();
    _face();
    _prop();
    if (_kind != BallCharacter.penguin) _arms();
    if (_isSsr) _crown();
    if (ball.pattern == BallPattern.sparkle) _sparkles();
  }

  // ---------------------------------------------------------------- 몸통

  Path _bodyPath() => Path()
    ..moveTo(_p(0, -0.92).dx, _p(0, -0.92).dy)
    ..cubicTo(_p(0.62, -0.92).dx, _p(0.62, -0.92).dy, _p(1.06, -0.5).dx,
        _p(1.06, -0.5).dy, _p(1.06, 0.12).dx, _p(1.06, 0.12).dy)
    ..cubicTo(_p(1.06, 0.62).dx, _p(1.06, 0.62).dy, _p(0.66, 0.86).dx,
        _p(0.66, 0.86).dy, _p(0, 0.86).dx, _p(0, 0.86).dy)
    ..cubicTo(_p(-0.66, 0.86).dx, _p(-0.66, 0.86).dy, _p(-1.06, 0.62).dx,
        _p(-1.06, 0.62).dy, _p(-1.06, 0.12).dx, _p(-1.06, 0.12).dy)
    ..cubicTo(_p(-1.06, -0.5).dx, _p(-1.06, -0.5).dy, _p(-0.62, -0.92).dx,
        _p(-0.62, -0.92).dy, _p(0, -0.92).dx, _p(0, -0.92).dy)
    ..close();

  void _shadow() {
    canvas.drawOval(
      _rect(0, 0.98, 1.7, 0.22),
      Paint()
        ..color = Colors.black.withOpacity(0.10)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.06),
    );
  }

  void _body() {
    final path = _bodyPath();
    final bounds = _rect(0, 0, 2.2, 2.0);
    canvas.drawPath(
      path,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.5),
          radius: 0.9,
          colors: [_tint(0.5), _base, _shade(0.1)],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(bounds),
    );
    // 말랑한 광택
    canvas.drawOval(
      _rect(-0.45, -0.5, 0.55, 0.3),
      Paint()
        ..color = Colors.white.withOpacity(0.55)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.07),
    );
    canvas.drawOval(
        _rect(-0.2, -0.66, 0.12, 0.08), _fill(Colors.white.withOpacity(0.8)));
    canvas.drawPath(path, _stroke(_shade(0.18).withOpacity(0.35), 0.03));
  }

  // ---------------------------------------------------------------- 귀

  void _earsBehind() {
    final outer = _fill(_shade(0.03));
    final innerPink = _fill(locked ? _base : Color.lerp(_base, _pad, 0.75)!);
    for (final s in const [-1.0, 1.0]) {
      switch (_kind) {
        case BallCharacter.cat:
        case BallCharacter.dog:
          final pointy = _kind == BallCharacter.cat;
          final ear = _poly(s, [
            (0.95, pointy ? -0.35 : -0.25),
            (pointy ? 0.82 : 0.76, pointy ? -1.18 : -1.1),
            (pointy ? 0.3 : 0.24, pointy ? -0.85 : -0.8),
          ]);
          canvas.drawPath(ear, outer);
          canvas.drawPath(ear, _stroke(outer.color, 0.16));
          canvas.drawPath(
            _poly(s, [(0.8, -0.5), (0.76, -0.98), (0.45, -0.82)]),
            pointy ? innerPink : _fill(locked ? _base : ball.accent),
          );
        case BallCharacter.rabbit:
          _rotatedOval(_rect(s * 0.36, -1.1, 0.42, 1.0), s * 0.18, outer);
          _rotatedOval(_rect(s * 0.36, -1.06, 0.2, 0.7), s * 0.18, innerPink);
        case BallCharacter.bear:
          canvas.drawCircle(_p(s * 0.72, -0.72), 0.3 * r, outer);
          canvas.drawCircle(_p(s * 0.72, -0.72), 0.17 * r,
              _fill(locked ? _base : ball.accent));
        case BallCharacter.penguin:
          break;
      }
    }
  }

  Path _poly(double s, List<(double, double)> pts) =>
      Path()..addPolygon([for (final (x, y) in pts) _p(s * x, y)], true);

  void _rotatedOval(Rect rect, double angle, Paint paint) {
    canvas.save();
    canvas.translate(rect.center.dx, rect.center.dy);
    canvas.rotate(angle);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset.zero, width: rect.width, height: rect.height),
      paint,
    );
    canvas.restore();
  }

  // ---------------------------------------------------------------- 손발

  void _feet() {
    final isPenguin = _kind == BallCharacter.penguin;
    for (final s in const [-1.0, 1.0]) {
      final foot = _rect(s * 0.4, 0.84, 0.38, 0.2);
      canvas.drawOval(
        foot,
        _fill(isPenguin && !locked ? const Color(0xFFFFB03A) : _shade(0.04)),
      );
      if (!locked && !isPenguin) {
        canvas.drawOval(foot, _stroke(_shade(0.2).withOpacity(0.3), 0.02));
        canvas.drawOval(_rect(s * 0.4, 0.85, 0.14, 0.09), _fill(_pad));
      }
    }
  }

  void _arms() {
    for (final s in const [-1.0, 1.0]) {
      final arm = _rect(s * 0.42, 0.5, 0.3, 0.24);
      canvas.drawOval(arm, _fill(_tint(0.08)));
      canvas.drawOval(arm, _stroke(_shade(0.2).withOpacity(0.3), 0.02));
    }
  }

  void _flippers() {
    for (final s in const [-1.0, 1.0]) {
      _rotatedOval(
          _rect(s * 0.98, 0.3, 0.26, 0.55), -s * 0.55, _fill(_shade(0.12)));
    }
  }

  // ---------------------------------------------------------------- 무늬

  void _markings() {
    canvas.save();
    canvas.clipPath(_bodyPath());
    switch (_kind) {
      case BallCharacter.penguin:
        final white = _fill(const Color(0xFFFFFDF8));
        canvas.drawOval(_rect(-0.3, -0.02, 0.9, 0.9), white);
        canvas.drawOval(_rect(0.3, -0.02, 0.9, 0.9), white);
        canvas.drawOval(_rect(0, 0.5, 1.4, 0.9), white);
      case BallCharacter.dog:
        // 시바견: 입 주변·배가 크림색, 크림색 눈썹 점
        final cream = _fill(ball.accent);
        canvas.drawOval(_rect(0, 0.48, 1.5, 0.95), cream);
        for (final s in const [-1.0, 1.0]) {
          canvas.drawOval(_rect(s * 0.3, -0.18, 0.14, 0.09), cream);
        }
      case BallCharacter.bear:
        canvas.drawOval(_rect(0, 0.25, 0.62, 0.44), _fill(ball.accent));
      case BallCharacter.cat:
      case BallCharacter.rabbit:
        break;
    }
    canvas.restore();
  }

  // ---------------------------------------------------------------- 얼굴

  void _face() {
    final ink = _fill(_ink);
    final happy = _isSsr && _kind == BallCharacter.cat;
    final sleepy = _kind == BallCharacter.bear;

    for (final s in const [-1.0, 1.0]) {
      final x = s * 0.32;
      if (happy) {
        // ^ ^ 웃는 눈
        canvas.drawArc(Rect.fromCircle(center: _p(x, 0.12), radius: 0.09 * r),
            math.pi, math.pi, false, _stroke(_ink, 0.05));
      } else if (sleepy) {
        // ‿ 졸린 눈
        canvas.drawArc(Rect.fromCircle(center: _p(x, 0.04), radius: 0.08 * r),
            0.15, math.pi - 0.3, false, _stroke(_ink, 0.045));
      } else {
        canvas.drawOval(_rect(x, 0.08, 0.14, 0.18), ink);
        canvas.drawCircle(_p(x - 0.025, 0.035), 0.04 * r, _fill(Colors.white));
        canvas.drawCircle(_p(x + 0.03, 0.12), 0.018 * r,
            _fill(Colors.white.withOpacity(0.8)));
      }
      // 볼터치
      canvas.drawOval(
        _rect(s * 0.57, 0.3, 0.3, 0.18),
        Paint()
          ..color = _blush.withOpacity(0.5)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.03),
      );
    }

    switch (_kind) {
      case BallCharacter.cat:
        canvas.drawPath(
          _poly(1, [(-0.05, 0.17), (0.05, 0.17), (0, 0.22)]),
          _fill(const Color(0xFFFF7A93)),
        );
        // 활짝 웃는 입 + 혀
        final mouth = Path()
          ..moveTo(_p(-0.11, 0.25).dx, _p(-0.11, 0.25).dy)
          ..quadraticBezierTo(_p(0, 0.46).dx, _p(0, 0.46).dy, _p(0.11, 0.25).dx,
              _p(0.11, 0.25).dy)
          ..close();
        canvas.drawPath(mouth, _fill(const Color(0xFFE85C7A)));
        canvas.save();
        canvas.clipPath(mouth);
        canvas.drawOval(
            _rect(0, 0.38, 0.14, 0.12), _fill(const Color(0xFFFF9DB0)));
        canvas.restore();
        canvas.drawPath(mouth, _stroke(_ink, 0.03));
      case BallCharacter.rabbit:
        canvas.drawOval(
            _rect(0, 0.18, 0.1, 0.07), _fill(const Color(0xFFFF7A93)));
        _omega(0.24);
      case BallCharacter.dog:
        canvas.drawOval(_rect(0, 0.2, 0.17, 0.12), ink);
        canvas.drawOval(
            _rect(0, 0.36, 0.1, 0.1), _fill(const Color(0xFFFF7A93)));
        _omega(0.28);
      case BallCharacter.bear:
        canvas.drawOval(_rect(0, 0.17, 0.18, 0.12), ink);
        _omega(0.24);
      case BallCharacter.penguin:
        final beak = _poly(1, [(-0.1, 0.2), (0.1, 0.2), (0, 0.32)]);
        const orange = Color(0xFFFFB03A);
        canvas.drawPath(beak, _fill(orange));
        canvas.drawPath(beak, _stroke(orange, 0.06));
    }
  }

  /// ω 입
  void _omega(double y) {
    for (final s in const [-1.0, 1.0]) {
      canvas.drawArc(
        Rect.fromCircle(center: _p(s * 0.065, y), radius: 0.065 * r),
        0,
        math.pi,
        false,
        _stroke(_ink, 0.035),
      );
    }
  }

  // ---------------------------------------------------------------- 소품

  void _prop() {
    switch (_kind) {
      case BallCharacter.rabbit:
        _carrot();
      case BallCharacter.bear:
        _star(_p(0, 0.56), 0.27, 0.13, _gold, const Color(0xFFE0A800));
      case BallCharacter.dog:
        _bone();
      case BallCharacter.cat:
        _isSsr ? _heart() : _fish();
      case BallCharacter.penguin:
        break;
    }
  }

  void _carrot() {
    canvas.save();
    canvas.translate(_p(0, 0.55).dx, _p(0, 0.55).dy);
    canvas.rotate(-0.6);
    Offset q(double x, double y) => Offset(x * r, y * r);
    for (final a in const [-0.5, 0.0, 0.5]) {
      canvas.save();
      canvas.translate(q(0, -0.26).dx, q(0, -0.26).dy);
      canvas.rotate(a);
      canvas.drawOval(
        Rect.fromCenter(center: q(0, -0.08), width: 0.09 * r, height: 0.2 * r),
        _fill(const Color(0xFF6CC070)),
      );
      canvas.restore();
    }
    final body = Path()
      ..moveTo(q(-0.12, -0.24).dx, q(-0.12, -0.24).dy)
      ..quadraticBezierTo(
          q(0, -0.3).dx, q(0, -0.3).dy, q(0.12, -0.24).dx, q(0.12, -0.24).dy)
      ..quadraticBezierTo(
          q(0.06, 0.1).dx, q(0.06, 0.1).dy, q(0, 0.32).dx, q(0, 0.32).dy)
      ..quadraticBezierTo(q(-0.06, 0.1).dx, q(-0.06, 0.1).dy,
          q(-0.12, -0.24).dx, q(-0.12, -0.24).dy)
      ..close();
    canvas.drawPath(body, _fill(const Color(0xFFFF9F43)));
    final line = Paint()
      ..color = const Color(0xFFE07B1F)
      ..strokeWidth = 0.02 * r
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(q(-0.06, -0.1), q(0.0, -0.1), line);
    canvas.drawLine(q(0.0, 0.04), q(0.05, 0.04), line);
    canvas.restore();
  }

  void _bone() {
    // 배가 크림색이라 테두리를 먼저 두껍게 깔고 그 위에 채워서 윤곽만 남긴다
    final bar = RRect.fromRectAndRadius(
        _rect(0, 0.6, 0.42, 0.12), Radius.circular(0.06 * r));
    const knobs = [(-0.21, 0.54), (-0.21, 0.66), (0.21, 0.54), (0.21, 0.66)];
    for (final paint in [
      _stroke(const Color(0xFFC9A77E), 0.07),
      _fill(const Color(0xFFFFFDF8)),
    ]) {
      for (final (x, y) in knobs) {
        canvas.drawCircle(_p(x, y), 0.075 * r, paint);
      }
      canvas.drawRRect(bar, paint);
    }
  }

  void _fish() {
    const blue = Color(0xFF7EC8F2);
    canvas.drawOval(_rect(-0.04, 0.56, 0.42, 0.22), _fill(blue));
    canvas.drawPath(
      _poly(1, [(0.14, 0.56), (0.3, 0.46), (0.3, 0.66)]),
      _fill(blue),
    );
    canvas.drawCircle(_p(-0.16, 0.54), 0.025 * r, _fill(_ink));
  }

  void _heart() {
    final h = Path()
      ..moveTo(_p(0, 0.72).dx, _p(0, 0.72).dy)
      ..cubicTo(_p(-0.34, 0.5).dx, _p(-0.34, 0.5).dy, _p(-0.2, 0.3).dx,
          _p(-0.2, 0.3).dy, _p(0, 0.44).dx, _p(0, 0.44).dy)
      ..cubicTo(_p(0.2, 0.3).dx, _p(0.2, 0.3).dy, _p(0.34, 0.5).dx,
          _p(0.34, 0.5).dy, _p(0, 0.72).dx, _p(0, 0.72).dy)
      ..close();
    canvas.drawPath(h, _fill(const Color(0xFFFF6F8E)));
    canvas.drawOval(
        _rect(-0.1, 0.45, 0.07, 0.05), _fill(Colors.white.withOpacity(0.8)));
  }

  // ---------------------------------------------------------------- SSR 장식

  void _crown() {
    canvas.save();
    final at = _p(0.12, -0.98);
    canvas.translate(at.dx, at.dy);
    canvas.rotate(0.18);
    Offset q(double x, double y) => Offset(x * r, y * r);
    final crown = Path()
      ..addPolygon([
        q(-0.24, 0.08),
        q(-0.28, -0.14),
        q(-0.12, -0.02),
        q(0, -0.2),
        q(0.12, -0.02),
        q(0.28, -0.14),
        q(0.24, 0.08),
      ], true);
    canvas.drawPath(crown, _fill(const Color(0xFFFFC83D)));
    canvas.drawPath(crown, _stroke(const Color(0xFFD99A00), 0.03));
    canvas.drawCircle(q(0, 0.0), 0.04 * r, _fill(const Color(0xFFFF6F8E)));
    for (final x in const [-0.28, 0.0, 0.28]) {
      canvas.drawCircle(q(x, x == 0 ? -0.2 : -0.14), 0.03 * r,
          _fill(const Color(0xFFFFF3C4)));
    }
    canvas.restore();
  }

  void _sparkles() {
    const around = [
      (-1.15, -0.55, 0.16),
      (1.18, -0.35, 0.12),
      (-1.1, 0.5, 0.1),
      (1.12, 0.65, 0.14),
    ];
    for (final (x, y, s) in around) {
      _star(_p(x, y), s, s * 0.28, _gold, null, points: 4);
    }
    // 어두운 몸통이면 몸 안에도 작은 별을 뿌린다 (밤하늘)
    if (_base.computeLuminance() < 0.2) {
      canvas.save();
      canvas.clipPath(_bodyPath());
      for (final (x, y) in const [(0.62, -0.42), (-0.7, -0.28), (0.82, 0.3)]) {
        _star(_p(x, y), 0.07, 0.02, ball.accent, null, points: 4);
      }
      canvas.restore();
    }
  }

  void _star(
      Offset center, double outer, double inner, Color color, Color? edge,
      {int points = 5}) {
    final path = Path();
    for (var i = 0; i < points * 2; i++) {
      final a = -math.pi / 2 + i * math.pi / points;
      final rad = (i.isEven ? outer : inner) * r;
      final pt = center + Offset(math.cos(a) * rad, math.sin(a) * rad);
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    path.close();
    if (edge != null) canvas.drawPath(path, _stroke(edge, 0.06));
    canvas.drawPath(path, _fill(color));
  }
}
