import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/ball.dart';
import 'ball_view.dart';

/// 실물 캡슐토이 자판기 모양의 가챠 머신. 이미지 없이 도형과 색만으로 그린다.
///
/// - [turn]  : 핸들 회전 진행도 0→1
/// - [drop]  : 배출구로 캡슐이 떨어지는 진행도 0→1
/// - [capsuleColor] : 배출된 캡슐 색 (null이면 배출구는 비어 있음)
class GachaMachine extends StatelessWidget {
  const GachaMachine({
    super.key,
    required this.showcase,
    required this.turn,
    required this.drop,
    this.capsuleColor,
    this.onCrankTap,
  });

  final List<Ball> showcase;
  final double turn;
  final double drop;
  final Color? capsuleColor;
  final VoidCallback? onCrankTap;

  static const _body = Color(0xFFF3F3F1);
  static const _bodyEdge = Color(0xFFD6D6D2);
  static const _panel = Color(0xFFE7E7E3);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 270,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, _body, Color(0xFFE9E9E6)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _bodyEdge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            children: [
              _SerialLabel('SB0001-1'),
              Spacer(),
              _Screw(),
              Spacer(),
              SizedBox(width: 74),
            ],
          ),
          const SizedBox(height: 8),
          _DisplayWindow(showcase: showcase),
          const SizedBox(height: 12),
          SizedBox(
            height: 190,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _panel,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _bodyEdge),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [_CoinSlot(), _CoinSlot()],
                        ),
                        const Spacer(),
                        _Crank(turn: turn, onTap: onCrankTap),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 96,
                  child: Column(
                    children: [
                      const _NoteSticker(),
                      const SizedBox(height: 8),
                      Expanded(
                        child: _Outlet(drop: drop, capsuleColor: capsuleColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const _Screw(),
        ],
      ),
    );
  }
}

/// 상단 창: 투명 아크릴 너머로 라인업 포스터가 보인다.
class _DisplayWindow extends StatelessWidget {
  const _DisplayWindow({required this.showcase});

  final List<Ball> showcase;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 214,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFDADAD6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _Poster(showcase: showcase),
            // 아크릴 반사광
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.45),
                    Colors.white.withOpacity(0.0),
                    Colors.white.withOpacity(0.0),
                    Colors.white.withOpacity(0.18),
                  ],
                  stops: const [0.0, 0.35, 0.8, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Poster extends StatelessWidget {
  const _Poster({required this.showcase});

  final List<Ball> showcase;

  @override
  Widget build(BuildContext context) {
    // 무대 위에 볼을 앞뒤 2줄로 배치
    const slots = [
      (0.04, 0.50, 54.0),
      (0.26, 0.40, 60.0),
      (0.50, 0.42, 58.0),
      (0.73, 0.50, 54.0),
      (0.15, 0.62, 50.0),
      (0.60, 0.62, 52.0),
    ];
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFBFE6FF), Color(0xFFFFE3EE)],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, box) => Stack(
          children: [
            // 타이틀
            Positioned(
              left: 0,
              right: 0,
              top: 8,
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8FA3),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'ぷにぷに',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'ストレスボール',
                    style: TextStyle(
                      color: Color(0xFF3A3550),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      shadows: [
                        Shadow(color: Colors.white, offset: Offset(2, 2)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 무대
            Positioned(
              left: box.maxWidth * 0.06,
              right: box.maxWidth * 0.06,
              bottom: 26,
              height: 44,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius:
                      const BorderRadius.all(Radius.elliptical(200, 44)),
                ),
              ),
            ),
            for (var i = 0; i < slots.length && i < showcase.length; i++)
              Positioned(
                left: slots[i].$1 * box.maxWidth,
                top: slots[i].$2 * box.maxHeight,
                child: BallView(ball: showcase[i], size: slots[i].$3),
              ),
            // 하단 정보 띠
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 22,
              child: Container(
                color: const Color(0xFF3A3550),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '全20種',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '1回 1コイン',
                      style: TextStyle(
                        color: Color(0xFFFFE27A),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoinSlot extends StatelessWidget {
  const _CoinSlot();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          padding: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFE53935),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Column(
            children: [
              Text(
                'COIN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Icon(Icons.arrow_downward_rounded, color: Colors.white, size: 16),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // 투입구
        Container(
          width: 40,
          height: 12,
          decoration: BoxDecoration(
            color: const Color(0xFFBDBDB8),
            borderRadius: BorderRadius.circular(3),
          ),
          alignment: Alignment.center,
          child: Container(
            width: 26,
            height: 3,
            color: const Color(0xFF4A4A48),
          ),
        ),
      ],
    );
  }
}

/// 은색 회전 핸들. 탭하면 돌린다.
class _Crank extends StatelessWidget {
  const _Crank({required this.turn, this.onTap});

  final double turn;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const metal = [Color(0xFFFFFFFF), Color(0xFFC9CBCE), Color(0xFF8E9196)];
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              center: Alignment(-0.4, -0.5),
              colors: metal,
            ),
            border: Border.all(color: const Color(0xFF9EA1A6), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Transform.rotate(
            // 실물처럼 시계 방향으로 한 바퀴
            angle: Curves.easeInOut.transform(turn) * math.pi * 2,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 손잡이 바
                Container(
                  width: 84,
                  height: 26,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFF5F5F5),
                        Color(0xFFB5B8BC),
                        Color(0xFF7D8085),
                      ],
                    ),
                    border: Border.all(color: const Color(0xFF8A8D92)),
                  ),
                ),
                // 중심 축
                Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: Alignment(-0.3, -0.3),
                      colors: metal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NoteSticker extends StatelessWidget {
  const _NoteSticker();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE2DFCF)),
      ),
      child: const Text(
        'ハンドルを\nまわしてね',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 10,
          height: 1.3,
          color: Color(0xFF4F7A4F),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// 캡슐 배출구. 검은 덮개 안으로 캡슐이 떨어진다.
class _Outlet extends StatelessWidget {
  const _Outlet({required this.drop, required this.capsuleColor});

  final double drop;
  final Color? capsuleColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFDADAD6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF111111), Color(0xFF3A3A3A)],
            ),
          ),
          child: LayoutBuilder(
            builder: (context, box) {
              const capsule = 52.0;
              final restTop = box.maxHeight - capsule - 6;
              final top = -capsule +
                  (restTop + capsule) * Curves.bounceOut.transform(drop);
              return Stack(
                children: [
                  if (capsuleColor != null)
                    Positioned(
                      left: (box.maxWidth - capsule) / 2,
                      top: top,
                      child: _Capsule(color: capsuleColor!, size: capsule),
                    ),
                  // 주의 스티커
                  Positioned(
                    left: 10,
                    right: 10,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD54F),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Text(
                        '取り出し口',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF3A3A3A),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// 위 반쪽은 볼 색의 반투명, 아래 반쪽은 흰색인 캡슐.
class _Capsule extends StatelessWidget {
  const _Capsule({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(color, Colors.white, 0.25)!,
            color,
            const Color(0xFFBDBDBD),
            Colors.white,
            const Color(0xFFE0E0E0),
          ],
          stops: const [0.0, 0.47, 0.47, 0.53, 1.0],
        ),
      ),
    );
  }
}

class _Screw extends StatelessWidget {
  const _Screw();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.3, -0.3),
          colors: [Colors.white, Color(0xFFB0B2B5)],
        ),
        border: Border.all(color: const Color(0xFF9EA1A6)),
      ),
    );
  }
}

/// 상단 관리 라벨 (바코드 + 기기 번호)
class _SerialLabel extends StatelessWidget {
  const _SerialLabel(this.code);

  final String code;

  static const _bars = [1, 2, 1, 1, 3, 1, 2, 1, 1, 2, 1, 3, 1, 1, 2];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 74,
      padding: const EdgeInsets.fromLTRB(4, 3, 4, 2),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFCCCCC8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var i = 0; i < _bars.length; i++)
                Container(
                  width: _bars[i].toDouble(),
                  height: 8,
                  margin: const EdgeInsets.only(right: 1.5),
                  color: i.isEven ? Colors.black87 : Colors.transparent,
                ),
            ],
          ),
          const SizedBox(height: 1),
          Text(
            code,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
