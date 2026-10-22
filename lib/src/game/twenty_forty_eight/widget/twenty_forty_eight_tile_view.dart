import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/game/twenty_forty_eight/game/model/twenty_forty_eight_tile.dart';
import 'package:flutter_mini_games/src/game/twenty_forty_eight/style/twenty_forty_eight_theme.dart';

/// One numbered tile. Pops in when it spawns and pulses when it is the result of a merge.
class TwentyFortyEightTileView extends StatelessWidget {
  static const popDuration = Duration(milliseconds: 200);

  final TwentyFortyEightTile tile;
  final double size;

  const TwentyFortyEightTileView({
    required this.tile,
    required this.size,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = TwentyFortyEightTheme.of(context);
    final child = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      padding: EdgeInsets.all(size * 0.12),
      decoration: BoxDecoration(
        color: theme.colors.tile(tile.value),
        borderRadius: BorderRadius.circular(theme.dimens.tileRadius),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          '${tile.value}',
          maxLines: 1,
          style: theme.textStyles.tile.copyWith(
            fontSize: size * 0.4,
            color: theme.colors.tileText(tile.value),
          ),
        ),
      ),
    );
    if (!tile.isNew && !tile.isMerged) return child;

    // A new value gets a new animation, so a merge restarts the pop
    return TweenAnimationBuilder<double>(
      key: ValueKey(tile.value),
      tween: Tween(begin: 0, end: 1),
      duration: popDuration,
      builder: (context, progress, child) => Transform.scale(
        scale: tile.isNew ? Curves.easeOutBack.transform(progress) : 1 + 0.15 * sin(pi * progress),
        child: child,
      ),
      child: child,
    );
  }
}
