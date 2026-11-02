import 'package:flutter/material.dart';

import '../../domain/rarity.dart';

class RarityBadge extends StatelessWidget {
  const RarityBadge(this.rarity, {super.key, this.compact = false});

  final Rarity rarity;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 10,
        vertical: compact ? 1 : 3,
      ),
      decoration: BoxDecoration(
        color: rarity.color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        rarity.label,
        style: TextStyle(
          color: Colors.white,
          fontSize: compact ? 10 : 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
