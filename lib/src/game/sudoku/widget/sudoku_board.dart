import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/game/sudoku/game/logic/sudoku_game_controller.dart';
import 'package:flutter_mini_games/src/game/sudoku/style/sudoku_theme.dart';
import 'package:flutter_mini_games/src/game/sudoku/widget/sudoku_cell.dart';

/// The 9x9 grid: cells with the thin cell lines and thick box lines painted on top
class SudokuBoard extends StatelessWidget {
  final SudokuGameController controller;

  const SudokuBoard({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SudokuTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = constraints.biggest.shortestSide / 9;
        return Center(
          child: SizedBox.square(
            dimension: cellSize * 9,
            child: Stack(
              children: [
                for (var row = 0; row < 9; row++)
                  for (var col = 0; col < 9; col++)
                    Positioned(
                      left: col * cellSize,
                      top: row * cellSize,
                      width: cellSize,
                      height: cellSize,
                      child: SudokuCell(
                        key: ValueKey('sudoku_cell_${row}_$col'),
                        value: controller.valueAt(row, col),
                        notes: controller.notesAt(row, col),
                        isGiven: controller.isGiven(row, col),
                        isWrong: controller.isWrong(row, col),
                        isSelected: controller.isSelected(row, col),
                        isPeer: controller.isPeerOfSelected(row, col),
                        hasSameValue: controller.hasSameValueAsSelected(row, col),
                        onTap: controller.isFinished ? null : () => controller.select(row, col),
                      ),
                    ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _SudokuLinesPainter(
                        gridLine: theme.colors.gridLine,
                        boxLine: theme.colors.boxLine,
                        gridLineWidth: theme.dimens.gridLineWidth,
                        boxLineWidth: theme.dimens.boxLineWidth,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SudokuLinesPainter extends CustomPainter {
  final Color gridLine;
  final Color boxLine;
  final double gridLineWidth;
  final double boxLineWidth;

  const _SudokuLinesPainter({
    required this.gridLine,
    required this.boxLine,
    required this.gridLineWidth,
    required this.boxLineWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / 9;
    // Solid colors only: the thick lines are drawn over the thin ones
    final thin = Paint()
      ..color = gridLine
      ..strokeWidth = gridLineWidth;
    final thick = Paint()
      ..color = boxLine
      ..strokeWidth = boxLineWidth;

    for (var i = 1; i < 9; i++) {
      if (i % 3 == 0) continue;
      final offset = i * cellSize;
      canvas.drawLine(Offset(offset, 0), Offset(offset, size.height), thin);
      canvas.drawLine(Offset(0, offset), Offset(size.width, offset), thin);
    }
    for (var i = 3; i < 9; i += 3) {
      final offset = i * cellSize;
      canvas.drawLine(Offset(offset, 0), Offset(offset, size.height), thick);
      canvas.drawLine(Offset(0, offset), Offset(size.width, offset), thick);
    }
    // Border, inset so the full width stays visible
    final inset = boxLineWidth / 2;
    canvas.drawRect(
      Rect.fromLTRB(inset, inset, size.width - inset, size.height - inset),
      thick..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_SudokuLinesPainter oldDelegate) =>
      gridLine != oldDelegate.gridLine || boxLine != oldDelegate.boxLine || gridLineWidth != oldDelegate.gridLineWidth || boxLineWidth != oldDelegate.boxLineWidth;
}
