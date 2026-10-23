import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/game/tic_tac_toe/game/logic/tic_tac_toe_game_controller.dart';
import 'package:flutter_mini_games/src/game/tic_tac_toe/style/tic_tac_toe_theme.dart';

/// One cell of the board. The mark (X or O) shows the owner, so it never depends on color only
class TicTacToeCell extends StatelessWidget {
  final DuelPlayer? player;
  final bool isWinningCell;

  const TicTacToeCell({
    required this.isWinningCell,
    this.player,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = TicTacToeTheme.of(context);
    final player = this.player;
    final isWinning = isWinningCell && player != null;
    return Container(
      decoration: BoxDecoration(
        color: isWinning ? theme.colors.playerColor(player) : theme.colors.cellBackground,
        borderRadius: BorderRadius.circular(theme.dimens.cellRadius),
      ),
      alignment: Alignment.center,
      child: player == null
          ? null
          : FittedBox(
              child: Text(
                TicTacToeGameController.markOf(player),
                style: theme.textStyles.mark.copyWith(
                  color: isWinning ? theme.colors.onPlayerColor(player) : theme.colors.playerColor(player),
                ),
              ),
            ),
    );
  }
}
