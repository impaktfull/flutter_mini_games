import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/game/trail/game/logic/trail_game_controller.dart';
import 'package:flutter_mini_games/src/game/trail/widget/trail_cell.dart';

/// The puzzle grid. Drag over the cells to extend the trail; tapping the next cell works too.
class TrailGrid extends StatelessWidget {
  /// Space between two cells
  static const cellSpacing = 2.0;

  final TrailGameController controller;

  const TrailGrid({
    required this.controller,
    super.key,
  });

  void _moveToCellAt(Offset localPosition, Size size) {
    final rows = controller.puzzle.rows;
    final cols = controller.puzzle.cols;
    final col = (localPosition.dx / size.width * cols).floor();
    final row = (localPosition.dy / size.height * rows).floor();
    if (row < 0 || row >= rows || col < 0 || col >= cols) return;
    if (controller.canMoveTo(row, col)) controller.moveTo(row, col);
  }

  @override
  Widget build(BuildContext context) {
    final rows = controller.puzzle.rows;
    final cols = controller.puzzle.cols;
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (details) => _moveToCellAt(details.localPosition, size),
          onPanStart: (details) => _moveToCellAt(details.localPosition, size),
          onPanUpdate: (details) => _moveToCellAt(details.localPosition, size),
          child: Column(
            spacing: cellSpacing,
            children: [
              for (var row = 0; row < rows; row++)
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: cellSpacing,
                    children: [
                      for (var col = 0; col < cols; col++) Expanded(child: _buildCell(row, col)),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCell(int row, int col) {
    final checkpointNumber = controller.getCheckpointNumber(row, col);
    return TrailCell(
      key: ValueKey('trail_cell_${row}_$col'),
      isFilled: controller.isInPath(row, col),
      checkpointNumber: checkpointNumber,
      isCurrentTarget: controller.isCurrentTarget(row, col),
      // Checkpoint already visited
      isCompleted: checkpointNumber != null && checkpointNumber < controller.currentTargetCheckpoint,
      pathDirections: controller.getPathDirections(row, col),
    );
  }
}
