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
          "It's a draw!",
          style: TicTacToeTheme.of(context).textStyles.headerTextStyle.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        );
      }
      return Text(
        'Player ${controller.winner} wins!',
        style: TicTacToeTheme.of(context).textStyles.headerTextStyle.copyWith(
          fontWeight: FontWeight.bold,
          color: controller.winner == 'X' ? Colors.blue : Colors.red,
        ),
      );
    }
    return Text(
      'Player ${controller.isXTurn ? 'X' : 'O'}\'s turn',
      style: TicTacToeTheme.of(context).textStyles.headerTextStyle.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
