import 'package:flutter/material.dart';

import '../../application/app_scope.dart';
import '../../domain/ball.dart';
import '../theme.dart';
import '../widgets/ball_tile.dart';
import 'ball_detail_screen.dart';

/// 컬렉션 선반. 전체 볼 칸을 깔아두고, 가진 볼만 활성화된다.
/// 아직 없는 볼은 흑백·반투명의 비활성 칸으로 보인다.
class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key, required this.onGoToGacha});

  final VoidCallback onGoToGacha;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final catalog = controller.catalog;
    final ownedKinds = controller.ownedKinds;

    return Scaffold(
      appBar: AppBar(title: const Text('コレクション')),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: ownedKinds == 0
                  ? _EmptyBanner(onGoToGacha: onGoToGacha)
                  : Text(
                      '持っているボール $ownedKinds / ${catalog.length}種 · '
                      '合計 ${controller.totalPulls}個',
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: catalog.length,
              itemBuilder: (context, i) {
                final ball = catalog[i];
                final count = controller.countOf(ball);
                final tag = 'collection-${ball.id}';
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
                      : () => _showLockedHint(context, ball),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showLockedHint(BuildContext context, Ball ball) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('「${ball.name}」はまだ持っていません'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

/// 아직 하나도 없을 때 선반 위에 띄우는 안내
class _EmptyBanner extends StatelessWidget {
  const _EmptyBanner({required this.onGoToGacha});

  final VoidCallback onGoToGacha;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'まだボールを持っていません',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'ガチャを回してボールを集めよう',
                  style: TextStyle(color: AppColors.inkSoft, fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onGoToGacha, child: const Text('ガチャへ')),
        ],
      ),
    );
  }
}
