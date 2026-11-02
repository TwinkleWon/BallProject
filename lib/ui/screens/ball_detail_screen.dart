import 'package:flutter/material.dart';

import '../../application/app_scope.dart';
import '../../domain/ball.dart';
import '../theme.dart';
import '../widgets/ball_view.dart';
import '../widgets/rarity_badge.dart';

/// 볼을 크게 보고 눌러보는 화면.
///
/// 지금의 "누르면 납작, 떼면 통통" 은 UI 흐름 확인용 임시 표현.
/// 11월에 터치 위치 기반 변형 + 스프링 흔들림으로 교체한다.
class BallDetailScreen extends StatefulWidget {
  const BallDetailScreen({
    super.key,
    required this.ball,
    required this.heroTag,
  });

  final Ball ball;

  /// 탭마다 같은 볼이 동시에 존재하므로 Hero 태그는 호출하는 쪽에서 구분해서 넘긴다.
  final String heroTag;

  @override
  State<BallDetailScreen> createState() => _BallDetailScreenState();
}

class _BallDetailScreenState extends State<BallDetailScreen> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final ball = widget.ball;
    final count = AppScope.of(context).countOf(ball);

    return Scaffold(
      appBar: AppBar(title: Text(ball.name)),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            GestureDetector(
              onTapDown: (_) => setState(() => _pressed = true),
              onTapUp: (_) => setState(() => _pressed = false),
              onTapCancel: () => setState(() => _pressed = false),
              child: AnimatedScale(
                scale: _pressed ? 0.9 : 1.0,
                duration: Duration(milliseconds: _pressed ? 120 : 600),
                curve: _pressed ? Curves.easeOut : Curves.elasticOut,
                child: Hero(
                  tag: widget.heroTag,
                  child: BallView(ball: ball, size: 260),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'ボールを押してみよう',
              style: TextStyle(color: AppColors.inkSoft),
            ),
            const Spacer(),
            Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      RarityBadge(ball.rarity),
                      const SizedBox(width: 10),
                      Text(
                        ball.name,
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Text('×$count',
                          style: const TextStyle(color: AppColors.inkSoft)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (ball.character != null)
                    _InfoRow(label: 'キャラ', value: ball.character!.label),
                  _InfoRow(label: 'かたち', value: ball.shape.label),
                  _InfoRow(label: 'もよう', value: ball.pattern.label),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child:
                Text(label, style: const TextStyle(color: AppColors.inkSoft)),
          ),
          Text(value, style: const TextStyle(color: AppColors.ink)),
        ],
      ),
    );
  }
}
