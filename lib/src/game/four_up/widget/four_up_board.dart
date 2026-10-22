import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_board.dart';
import 'package:flutter_mini_games/src/core/widget/input/game_input_detector.dart';
import 'package:flutter_mini_games/src/game/four_up/game/logic/four_up_game_controller.dart';
import 'package:flutter_mini_games/src/game/four_up/style/four_up_theme.dart';
import 'package:flutter_mini_games/src/game/four_up/widget/four_up_disc.dart';

/// The 7x6 grid. Tap a column to drop a disc; arrow keys / swipes left and right select a
/// column and arrow down / swipe down drops in the selected column.
class FourUpBoard extends StatelessWidget {
  static const aspectRatio = FourUpGameController.columns / FourUpGameController.rows;

  /// Time of the drop animation from above the board to the bottom row
  static const maxDropDuration = Duration(milliseconds: 450);

  final FourUpGameController controller;

  const FourUpBoard({
    required this.controller,
    super.key,
  });

  void _onSwipe(GameDirection direction) {
    switch (direction) {
      case GameDirection.left:
        controller.moveSelection(-1);
      case GameDirection.right:
        controller.moveSelection(1);
      case GameDirection.down:
        controller.dropSelected();
      case GameDirection.up:
        controller.clearSelection();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FourUpTheme.of(context);
    final lastMove = controller.lastMove;
    final dropRows = lastMove == null ? 0 : lastMove.row + 1;
    final cells = [
      for (var row = 0; row < FourUpGameController.rows; row++)
        for (var col = 0; col < FourUpGameController.columns; col++) controller.cellAt(col, row),
    ];
    return GameBoard(
      aspectRatio: aspectRatio,
      padding: EdgeInsets.all(theme.dimens.boardPadding),
      child: LayoutBuilder(
        builder: (context, constraints) => GameInputDetector(
          onTapAt: (position) {
            final col = (position.dx / constraints.maxWidth * FourUpGameController.columns).floor();
            controller
              ..clearSelection()
              ..dropDisc(col.clamp(0, FourUpGameController.columns - 1));
          },
          onSwipe: _onSwipe,
          repeatSwipes: false,
          child: TweenAnimationBuilder<double>(
            // A new disc restarts the drop animation
            key: ValueKey(controller.moves),
            tween: Tween(begin: 0, end: 1),
            duration: maxDropDuration * (dropRows / FourUpGameController.rows),
            curve: Curves.bounceOut,
            builder: (context, progress, child) => CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: FourUpBoardPainter(
                cells: cells,
                colors: theme.colors,
                dimens: theme.dimens,
                currentPlayer: controller.currentPlayer,
                selectedColumn: controller.selectedColumn,
                winningCells: controller.winningCells,
                lastMove: lastMove,
                dropProgress: progress,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FourUpBoardPainter extends CustomPainter {
  /// Row by row from the top, [FourUpGameController.columns] cells per row
  final List<DuelPlayer?> cells;
  final FourUpColors colors;
  final FourUpDimens dimens;
  final DuelPlayer currentPlayer;
  final int? selectedColumn;
  final Set<FourUpCell> winningCells;
  final FourUpCell? lastMove;

  /// 0 when the last disc is above the board, 1 when it landed
  final double dropProgress;

  const FourUpBoardPainter({
    required this.cells,
    required this.colors,
    required this.dimens,
    required this.currentPlayer,
    required this.selectedColumn,
    required this.winningCells,
    required this.lastMove,
    required this.dropProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const columns = FourUpGameController.columns;
    const rows = FourUpGameController.rows;
    final cellWidth = size.width / columns;
    final cellHeight = size.height / rows;
    final radius = (cellWidth < cellHeight ? cellWidth : cellHeight) * dimens.discSizeFactor / 2;
    Offset centerOf(int col, double row) => Offset((col + 0.5) * cellWidth, (row + 0.5) * cellHeight);

    final landed = dropProgress >= 1;
    final hasWinner = winningCells.isNotEmpty && landed;
    final selectedSlot = Color.lerp(colors.slot, colors.disc(currentPlayer), 0.3)!;

    // Empty slots, the selected column is tinted in the color of the current player
    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < columns; col++) {
        final color = col == selectedColumn ? selectedSlot : colors.slot;
        canvas.drawCircle(centerOf(col, row.toDouble()), radius, Paint()..color = color);
      }
    }

    void paintDisc(int col, double row, DuelPlayer player, {required bool dimmed}) {
      var color = colors.disc(player);
      var patternColor = colors.onDisc(player);
      if (dimmed) {
        // Solid blend instead of alpha, so nothing shines through
        color = Color.lerp(color, colors.slot, 0.6)!;
        patternColor = Color.lerp(patternColor, colors.slot, 0.6)!;
      }
      paintFourUpDisc(
        canvas,
        center: centerOf(col, row),
        radius: radius,
        player: player,
        color: color,
        patternColor: patternColor,
        patternStrokeWidth: dimens.patternStrokeWidth,
      );
    }

    final lastMove = this.lastMove;
    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < columns; col++) {
        final player = cells[row * columns + col];
        if (player == null) continue;
        if (!landed && lastMove != null && lastMove.col == col && lastMove.row == row) continue;
        final isWinning = winningCells.contains((col: col, row: row));
        paintDisc(col, row.toDouble(), player, dimmed: hasWinner && !isWinning);
      }
    }

    // The falling disc, from one row above the board to its row
    if (!landed && lastMove != null) {
      final player = cells[lastMove.row * columns + lastMove.col];
      if (player != null) {
        final row = -1 + (lastMove.row + 1) * dropProgress;
        paintDisc(lastMove.col, row, player, dimmed: false);
      }
    }

    if (hasWinner) {
      final ring = Paint()
        ..color = colors.winHighlight
        ..style = PaintingStyle.stroke
        ..strokeWidth = dimens.winRingWidth;
      for (final cell in winningCells) {
        canvas.drawCircle(centerOf(cell.col, cell.row.toDouble()), radius + dimens.winRingWidth / 2, ring);
      }
    }
  }

  @override
  bool shouldRepaint(covariant FourUpBoardPainter oldDelegate) =>
      !listEquals(oldDelegate.cells, cells) ||
      oldDelegate.colors != colors ||
      oldDelegate.dimens != dimens ||
      oldDelegate.currentPlayer != currentPlayer ||
      oldDelegate.selectedColumn != selectedColumn ||
      !setEquals(oldDelegate.winningCells, winningCells) ||
      oldDelegate.lastMove != lastMove ||
      oldDelegate.dropProgress != dropProgress;
}
