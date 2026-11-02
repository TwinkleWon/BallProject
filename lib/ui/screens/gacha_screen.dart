import 'package:flutter/material.dart';

import '../../application/app_scope.dart';
import '../../application/collection_controller.dart';
import '../theme.dart';
import '../widgets/ball_view.dart';
import '../widgets/gacha_machine.dart';
import '../widgets/rarity_badge.dart';

class GachaScreen extends StatefulWidget {
  const GachaScreen({super.key, required this.onOpenCollection});

  final VoidCallback onOpenCollection;

  @override
  State<GachaScreen> createState() => _GachaScreenState();
}

class _GachaScreenState extends State<GachaScreen>
    with TickerProviderStateMixin {
  // 포스터에 진열할 볼 (레어도가 골고루 보이게)
  static const _showcaseIds = ['r01', 'ssr01', 'sr03', 'n02', 'n04', 'r04'];

  late final AnimationController _turn = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final AnimationController _drop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  Color? _capsuleColor;
  bool _busy = false;

  @override
  void dispose() {
    _turn.dispose();
    _drop.dispose();
    super.dispose();
  }

  // 핸들 회전 → 캡슐 배출 → 결과 공개
  Future<void> _spin() async {
    final controller = AppScope.of(context);
    setState(() => _busy = true);
    await _turn.forward(from: 0);
    final result = await controller.pull();
    setState(() => _capsuleColor = result.ball.base);
    await _drop.forward(from: 0);
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    final openCollection = await showDialog<bool>(
      context: context,
      builder: (_) =>
          _ResultDialog(result: result, count: controller.countOf(result.ball)),
    );
    _turn.value = 0;
    _drop.value = 0;
    setState(() {
      _capsuleColor = null;
      _busy = false;
    });
    if (openCollection == true) widget.onOpenCollection();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final showcase = [
      for (final id in _showcaseIds)
        controller.catalog.firstWhere((b) => b.id == id),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('ストレスボールガチャ')),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            // 작은 화면에서는 머신을 축소해서 넘치지 않게 한다
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_turn, _drop]),
                    builder: (_, __) => GachaMachine(
                      showcase: showcase,
                      turn: _turn.value,
                      drop: _drop.value,
                      capsuleColor: _capsuleColor,
                      onCrankTap: _busy ? null : _spin,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: FilledButton(
                onPressed: _busy ? null : _spin,
                child: const Text('Start'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ResultDialog extends StatelessWidget {
  const _ResultDialog({required this.result, required this.count});

  final PullResult result;
  final int count;

  @override
  Widget build(BuildContext context) {
    final ball = result.ball;
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 28,
              child: result.isNew
                  ? const Text(
                      'NEW!',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    )
                  : null,
            ),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.2, end: 1),
              duration: const Duration(milliseconds: 700),
              curve: Curves.elasticOut,
              builder: (_, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: BallView(ball: ball, size: 170),
            ),
            const SizedBox(height: 12),
            RarityBadge(ball.rarity),
            const SizedBox(height: 8),
            Text(
              ball.name,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text('所持数 ×$count',
                style: const TextStyle(color: AppColors.inkSoft)),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('とじる'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('コレクションを見る'),
            ),
          ],
        ),
      ),
    );
  }
}
