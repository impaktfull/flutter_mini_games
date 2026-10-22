import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/game/trail/game/logic/trail_game_controller.dart';
import 'package:flutter_mini_games/src/game/trail/widget/trail_cell.dart';

class TrailGrid extends StatefulWidget {
  final TrailGameController controller;

  const TrailGrid({
    required this.controller,
    super.key,
  });

  @override
  State<TrailGrid> createState() => _TrailGridState();
}

class _TrailGridState extends State<TrailGrid> {
  final GlobalKey _gridKey = GlobalKey();

  (int row, int col)? _getCellFromPosition(Offset localPosition) {
    final renderBox = _gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;

    final size = renderBox.size;
    final rows = widget.controller.puzzle.rows;
    final cols = widget.controller.puzzle.cols;

    // Calculate cell size
    final cellWidth = size.width / cols;
    final cellHeight = size.height / rows;

    // Calculate row and col from position
    final col = (localPosition.dx / cellWidth).floor();
    final row = (localPosition.dy / cellHeight).floor();

    // Bounds check
    if (row < 0 || row >= rows || col < 0 || col >= cols) {
      return null;
    }

    return (row, col);
  }

  void _handleDragUpdate(Offset localPosition) {
    final cell = _getCellFromPosition(localPosition);
    if (cell == null) return;

    final (row, col) = cell;
    if (widget.controller.canMoveTo(row, col)) {
      widget.controller.moveTo(row, col);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return GestureDetector(
      onPanStart: (details) => _handleDragUpdate(details.localPosition),
      onPanUpdate: (details) => _handleDragUpdate(details.localPosition),
      child: GridView.builder(
        key: _gridKey,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: controller.puzzle.cols,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
        ),
        itemCount: controller.puzzle.rows * controller.puzzle.cols,
        itemBuilder: (context, index) {
          final row = index ~/ controller.puzzle.cols;
          final col = index % controller.puzzle.cols;
          final checkpointNumber = controller.getCheckpointNumber(row, col);

          return TrailCell(
            isFilled: controller.isInPath(row, col),
            checkpointNumber: checkpointNumber,
            isCurrentTarget: controller.isCurrentTarget(row, col),
            // Checkpoint already visited
            isCompleted: checkpointNumber != null && checkpointNumber < controller.currentTargetCheckpoint,
            pathDirections: controller.getPathDirections(row, col),
            // Keep tap for accessibility, but drag is primary interaction
            onTap: controller.canMoveTo(row, col) ? () => controller.moveTo(row, col) : null,
          );
        },
      ),
    );
  }
}
