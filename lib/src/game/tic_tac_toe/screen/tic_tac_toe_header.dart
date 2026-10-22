import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/game/tic_tac_toe/game/logic/tic_tac_toe_game_controller.dart';
import 'package:flutter_mini_games/src/game/tic_tac_toe/style/tic_tac_toe_theme.dart';

class TicTacToeHeader extends StatelessWidget {
  final TicTacToeGameController controller;

  const TicTacToeHeader({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isGameOver = controller.isGameOver;
    if (isGameOver) {
      final isDraw = controller.winner == null;
      if (isDraw) {
        return Text(
          textAlign: TextAlign.center,
          "It's a draw!",
          style: TicTacToeTheme.of(context).textStyles.headerDraw,
        );
      }
      return Text(
        textAlign: TextAlign.center,
        'Player ${controller.winner} wins!',
        style: controller.winner == 'X' ? TicTacToeTheme.of(context).textStyles.headerWinnerX : TicTacToeTheme.of(context).textStyles.headerWinnerO,
      );
    }
    return Text(
      textAlign: TextAlign.center,
      'Player ${controller.isXTurn ? 'X' : 'O'}\'s turn',
      style: TicTacToeTheme.of(context).textStyles.header,
    );
  }
}
