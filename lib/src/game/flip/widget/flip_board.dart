import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/widget/input/game_input_detector.dart';
import 'package:flutter_mini_games/src/game/flip/game/logic/flip_game_controller.dart';
import 'package:flutter_mini_games/src/game/flip/style/flip_theme.dart';
import 'package:flutter_mini_games/src/game/flip/widget/flip_disc.dart';

/// The 8x8 board: discs, legal move hints and one input detector that maps a tap to a cell
class FlipBoard extends StatelessWidget {
  final FlipGameController controller;

  const FlipBoard({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FlipTheme.of(context);
    const size = FlipGameController.size;
    return LayoutBuilder(
      builder: (context, constraints) {
        final extent = max(0.0, min(constraints.maxWidth, constraints.maxHeight));
        // Smaller gaps on tiny boards, so the cells always fit
        final spacing = min(theme.dimens.cellSpacing, extent / size * 0.1);
        final cellSize = max(0.0, (extent - spacing * (size - 1)) / size);
        final step = cellSize + spacing;
        return Center(
          child: SizedBox.square(
            dimension: extent,
            child: GameInputDetector(
              onTapAt: (position) {
                if (step <= 0) return;
                final row = (position.dy / step).floor().clamp(0, size - 1);
                final col = (position.dx / step).floor().clamp(0, size - 1);
                controller.play(row, col);
              },
              child: Stack(
                children: [
                  for (var row = 0; row < size; row++)
                    for (var col = 0; col < size; col++)
                      Positioned(
                        left: col * step,
                        top: row * step,
                        width: cellSize,
                        height: cellSize,
                        child: _buildCell(theme, row, col, cellSize),
                      ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCell(FlipTheme theme, int row, int col, double cellSize) {
    final owner = controller.cellAt(row, col);
    final isLastMove = controller.lastMove == (row, col);
    final isHint = owner == null && controller.isLegalMove(row, col);
    final player = controller.currentPlayer;
    return Container(
      key: ValueKey('flip_cell_${row}_$col'),
      decoration: BoxDecoration(
        color: isLastMove ? theme.colors.lastMoveCell : theme.colors.cell,
        borderRadius: BorderRadius.circular(theme.dimens.cellRadius),
      ),
      padding: EdgeInsets.all(cellSize * theme.dimens.discInset),
      child: owner != null
          ? FlipDisc(
              // A new game starts without flip animations
              key: ValueKey('flip_disc_${controller.gameNumber}'),
              owner: owner,
              colorOf: theme.colors.player,
              ringWidth: theme.dimens.ringWidth,
              animateIn: isLastMove,
            )
          : isHint
          ? Center(
              child: SizedBox.square(
                dimension: cellSize * theme.dimens.hintSize,
                child: CustomPaint(
                  key: ValueKey('flip_hint_${row}_$col'),
                  painter: FlipDiscPainter(
                    player: player,
                    color: theme.colors.player(player),
                    ringWidth: theme.dimens.ringWidth * 1.5,
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
