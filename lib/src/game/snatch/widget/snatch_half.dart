import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/game/snatch/game/logic/snatch_game_controller.dart';
import 'package:flutter_mini_games/src/game/snatch/style/snatch_theme.dart';
import 'package:flutter_mini_games/src/game/snatch/widget/snatch_tile.dart';

/// The tiles of one player: 3 columns x 2 rows of square tiles, as large as they fit
class SnatchHalf extends StatelessWidget {
  static const columns = 3;
  static const rows = 2;

  final SnatchGameController controller;
  final DuelPlayer player;

  const SnatchHalf({
    required this.controller,
    required this.player,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final dimens = SnatchTheme.of(context).dimens;
    final layout = controller.layoutOf(player);
    final isLocked = controller.isLocked(player);
    return Padding(
      padding: EdgeInsets.fromLTRB(dimens.halfPadding, dimens.halfPadding, dimens.halfPadding, dimens.scoreSpace),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final gap = dimens.tileGap;
          final size = max(
            0.0,
            min((constraints.maxWidth - gap * (columns - 1)) / columns, (constraints.maxHeight - gap * (rows - 1)) / rows),
          );
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: gap,
              children: [
                for (var row = 0; row < rows; row++)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: gap,
                    children: [
                      for (var col = 0; col < columns; col++)
                        SizedBox.square(
                          dimension: size,
                          child: SnatchTile(
                            player: player,
                            index: row * columns + col,
                            symbol: layout[row * columns + col],
                            state: controller.tileState(player, row * columns + col),
                            isLocked: isLocked,
                            onTap: () => controller.tap(player, row * columns + col),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
