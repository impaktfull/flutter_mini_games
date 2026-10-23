import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/game/snatch/game/logic/snatch_game_controller.dart';
import 'package:flutter_mini_games/src/game/snatch/style/snatch_theme.dart';
import 'package:flutter_mini_games/src/game/snatch/widget/snatch_symbols.dart';

/// Bar between the halves with the symbol to find, shown twice: upright for the bottom player
/// and rotated for the top player. After a point it takes the color of the player who scored.
class SnatchTarget extends StatelessWidget {
  final SnatchGameController controller;

  const SnatchTarget({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SnatchTheme.of(context);
    final scorer = controller.lastScorer;
    final background = scorer == null ? theme.colors.center : theme.colors.playerColor(scorer);
    final foreground = scorer == null ? theme.colors.target : theme.colors.onPlayerColor(scorer);
    final Widget symbol = controller.isTargetVisible
        ? Icon(SnatchSymbols.of(controller.target), size: theme.dimens.targetSize, color: foreground)
        : Text('?', style: theme.textStyles.hiddenTarget.copyWith(color: theme.colors.hiddenTarget));
    return SizedBox(
      height: theme.dimens.centerHeight,
      child: ColoredBox(
        color: background,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            RotatedBox(quarterTurns: 2, child: symbol),
            symbol,
          ],
        ),
      ),
    );
  }
}
