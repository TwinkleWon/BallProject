import 'package:flutter/material.dart';

import '../../domain/ball.dart';
import '../theme.dart';
import 'ball_view.dart';
import 'rarity_badge.dart';

/// 그리드용 볼 카드. 컬렉션·도감에서 공통으로 쓴다.
class BallTile extends StatelessWidget {
  const BallTile({
    super.key,
    required this.ball,
    required this.heroTag,
    this.count = 0,
    this.onTap,
  });

  final Ball ball;
  final String heroTag;

  /// 0이면 미보유: 흑백·반투명으로 보여주고 「未入手」 표시.
  final int count;
  final VoidCallback? onTap;

  static const _grayscale = ColorFilter.matrix([
    0.33, 0.33, 0.33, 0, 0, //
    0.33, 0.33, 0.33, 0, 0, //
    0.33, 0.33, 0.33, 0, 0, //
    0, 0, 0, 1, 0, //
  ]);

  @override
  Widget build(BuildContext context) {
    final owned = count > 0;
    Widget ballView = BallView(ball: ball, size: 72);
    if (!owned) {
      ballView = Opacity(
        opacity: 0.45,
        child: ColorFiltered(colorFilter: _grayscale, child: ballView),
      );
    }

    return Material(
      // 미보유 칸은 배경도 한 톤 죽여서 비활성 느낌을 준다
      color: owned ? AppColors.surface : const Color(0xFFEFEDF4),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Row(
                children: [
                  RarityBadge(ball.rarity, compact: true),
                  const Spacer(),
                  if (owned)
                    Text(
                      '×$count',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.inkSoft,
                      ),
                    ),
                ],
              ),
              Expanded(
                child: Center(child: Hero(tag: heroTag, child: ballView)),
              ),
              Text(
                ball.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: owned ? AppColors.ink : AppColors.inkSoft,
                ),
              ),
              Text(
                owned ? '' : '未入手',
                style: const TextStyle(fontSize: 10, color: AppColors.inkSoft),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
