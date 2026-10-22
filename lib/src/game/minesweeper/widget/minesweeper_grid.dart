import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/game/minesweeper/game/logic/minesweeper_game_controller.dart';
import 'package:flutter_mini_games/src/game/minesweeper/style/minesweeper_theme.dart';
import 'package:flutter_mini_games/src/game/minesweeper/widget/minesweeper_cell_tile.dart';

/// The cells of the board, as large as possible within its parent and always square
class MinesweeperGrid extends StatelessWidget {
  final MinesweeperGameController controller;

  const MinesweeperGrid({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = MinesweeperTheme.of(context);
    final spacing = theme.dimens.cellSpacing;
    final rows = controller.rows;
    final cols = controller.cols;
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = max(
          0.0,
          min(
            (constraints.maxWidth - spacing * (cols - 1)) / cols,
            (constraints.maxHeight - spacing * (rows - 1)) / rows,
          ),
        );
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: spacing,
            children: [
              for (var row = 0; row < rows; row++)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: spacing,
                  children: [
                    for (var col = 0; col < cols; col++)
                      MinesweeperCellTile(
                        cell: controller.cellAt(row, col),
                        size: cellSize,
                        showMines: controller.isLost,
                        onTap: controller.isFinished ? null : () => controller.tap(row, col),
                        onLongPress: controller.isFinished ? null : () => controller.toggleFlag(row, col),
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
