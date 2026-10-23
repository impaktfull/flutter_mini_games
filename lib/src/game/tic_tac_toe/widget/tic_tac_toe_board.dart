import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/widget/input/game_input_detector.dart';
import 'package:flutter_mini_games/src/game/tic_tac_toe/game/logic/tic_tac_toe_game_controller.dart';
import 'package:flutter_mini_games/src/game/tic_tac_toe/style/tic_tac_toe_theme.dart';
import 'package:flutter_mini_games/src/game/tic_tac_toe/widget/tic_tac_toe_cell.dart';

/// The 3x3 board: one input detector maps a tap to a cell
class TicTacToeBoard extends StatelessWidget {
  final TicTacToeGameController controller;

  const TicTacToeBoard({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = TicTacToeTheme.of(context);
    const size = TicTacToeGameController.size;
    return LayoutBuilder(
      builder: (context, constraints) => GameInputDetector(
        onTapAt: (position) {
          final row = (position.dy / constraints.maxHeight * size).floor();
          final col = (position.dx / constraints.maxWidth * size).floor();
          controller.makeMove(row.clamp(0, size - 1), col.clamp(0, size - 1));
        },
        child: Column(
          spacing: theme.dimens.cellSpacing,
          children: [
            for (var row = 0; row < size; row++)
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: theme.dimens.cellSpacing,
                  children: [
                    for (var col = 0; col < size; col++)
                      Expanded(
                        child: TicTacToeCell(
                          key: ValueKey('tic_tac_toe_cell_${row}_$col'),
                          player: controller.cellAt(row, col),
                          isWinningCell: controller.isWinningCell(row, col),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
