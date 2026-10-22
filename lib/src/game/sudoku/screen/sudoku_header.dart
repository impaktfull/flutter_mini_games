import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/game/sudoku/game/logic/sudoku_game_controller.dart';
import 'package:flutter_mini_games/src/game/sudoku/style/sudoku_theme.dart';

class SudokuHeader extends StatelessWidget {
  final SudokuGameController controller;

  const SudokuHeader({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SudokuTheme.of(context);
    final mistakes = controller.mistakes;
    final mistakesLabel = '$mistakes ${mistakes == 1 ? 'mistake' : 'mistakes'}';

    if (controller.isWon) {
      return Column(
        spacing: 4,
        children: [
          Text('🎉 Puzzle Complete!', textAlign: TextAlign.center, style: theme.textStyles.headerWin),
          Text(
            'Score: ${controller.result?.score ?? 0} · $mistakesLabel',
            textAlign: TextAlign.center,
            style: theme.textStyles.info,
          ),
        ],
      );
    }

    return Column(
      spacing: 4,
      children: [
        Text(controller.puzzle.name ?? 'Sudoku', textAlign: TextAlign.center, style: theme.textStyles.header),
        Text(
          '${controller.difficulty.label} · $mistakesLabel',
          textAlign: TextAlign.center,
          style: theme.textStyles.info,
        ),
      ],
    );
  }
}
