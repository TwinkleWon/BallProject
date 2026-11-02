import 'package:flutter/material.dart';

import '../../application/app_scope.dart';
import '../../domain/rarity.dart';
import '../theme.dart';
import '../widgets/ball_tile.dart';
import '../widgets/rarity_badge.dart';
import 'ball_detail_screen.dart';

/// 도감: 전체 볼 종류를 레어도별로 보여준다. 미보유 볼도 흐리게 보여서
/// "어떤 볼이 있는지"와 "무엇이 남았는지"를 알 수 있게 한다.
class ZukanScreen extends StatelessWidget {
  const ZukanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final total = controller.catalog.length;
    final owned = controller.ownedKinds;

    return Scaffold(
      appBar: AppBar(title: const Text('図鑑')),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'コンプリート率',
                        style: TextStyle(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$owned / $total  '
                        '(${total == 0 ? 0 : (owned * 100 / total).round()}%)',
                        style: const TextStyle(color: AppColors.inkSoft),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: total == 0 ? 0 : owned / total,
                      minHeight: 10,
                      backgroundColor: AppColors.locked,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 높은 레어도부터
          for (final rarity in Rarity.values.reversed)
            ..._section(context, rarity),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  List<Widget> _section(BuildContext context, Rarity rarity) {
    final controller = AppScope.of(context);
    final balls = controller.catalog.where((b) => b.rarity == rarity).toList();
    if (balls.isEmpty) return const [];
    final ownedInRarity = balls.where(controller.isOwned).length;

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Row(
            children: [
              RarityBadge(rarity),
              const SizedBox(width: 8),
              Text(
                '排出率 ${rarity.weight}%',
                style: const TextStyle(color: AppColors.inkSoft, fontSize: 12),
              ),
              const Spacer(),
              Text(
                '$ownedInRarity / ${balls.length}',
                style: const TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemCount: balls.length,
          itemBuilder: (context, i) {
            final ball = balls[i];
            final count = controller.countOf(ball);
            final tag = 'zukan-${ball.id}';
            return BallTile(
              ball: ball,
              heroTag: tag,
              count: count,
              onTap: count > 0
                  ? () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              BallDetailScreen(ball: ball, heroTag: tag),
                        ),
                      )
                  : () => ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text('「${ball.name}」はガチャで手に入れよう！'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    ),
            );
          },
        ),
      ),
    ];
  }
}
