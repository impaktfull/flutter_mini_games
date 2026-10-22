import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/game/snatch/game/logic/snatch_game_controller.dart';
import 'package:flutter_mini_games/src/game/snatch/style/snatch_theme.dart';
import 'package:flutter_mini_games/src/game/snatch/widget/snatch_symbols.dart';

/// One tile of a player's half.
///
/// Uses raw pointer events so every finger counts, also when both players tap at the same time.
class SnatchTile extends StatelessWidget {
  final DuelPlayer player;
  final int index;
  final int symbol;
  final SnatchTileState state;
  final bool isLocked;
  final VoidCallback onTap;

  const SnatchTile({
    required this.player,
    required this.index,
    required this.symbol,
    required this.state,
    required this.isLocked,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SnatchTheme.of(context);
    final core = CoreGameTheme.of(context);
    final colors = theme.colors;
    final (background, foreground) = switch (state) {
      SnatchTileState.hit => (core.playerColor(player), core.onPlayerColor(player)),
      SnatchTileState.wrong => (colors.wrongTile, colors.onWrongTile),
      SnatchTileState.missed || SnatchTileState.idle => (colors.tile, isLocked ? colors.lockedSymbol : colors.symbol),
    };
    final label = switch (state) {
      SnatchTileState.hit => '+1',
      SnatchTileState.wrong => '-1',
      _ => null,
    };
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => onTap(),
      child: LayoutBuilder(
        builder: (context, constraints) => DecoratedBox(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(theme.dimens.tileRadius),
            border: state == SnatchTileState.missed ? Border.all(color: colors.missedBorder, width: theme.dimens.missedBorderWidth) : null,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: Icon(
                  SnatchSymbols.of(symbol),
                  size: constraints.biggest.shortestSide * theme.dimens.symbolScale,
                  color: foreground,
                ),
              ),
              if (label != null)
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(label, style: theme.textStyles.points.copyWith(color: foreground)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
