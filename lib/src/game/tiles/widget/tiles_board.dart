import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_board.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_overlay.dart';
import 'package:flutter_mini_games/src/core/widget/game_loop.dart';
import 'package:flutter_mini_games/src/core/widget/input/game_input_detector.dart';
import 'package:flutter_mini_games/src/game/tiles/game/logic/tiles_game_controller.dart';
import 'package:flutter_mini_games/src/game/tiles/game/model/tiles_row.dart';
import 'package:flutter_mini_games/src/game/tiles/style/tiles_theme.dart';

/// Playing field of Tiles: runs the game loop, handles touches and draws the rows.
///
/// Every finger that goes down counts ([GameInputDetector.onPointerDownAt]), also when two
/// tiles are tapped at once.
class TilesBoard extends StatelessWidget {
  final TilesGameController controller;

  const TilesBoard({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = TilesTheme.of(context);
    return GameBoard(
      aspectRatio: TilesGameController.boardAspectRatio,
      child: GameLoop(
        controller: controller,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;
            return GameInputDetector(
              onPointerDownAt: (position) => _onPointerDown(position, size),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(
                    painter: _TilesPainter(controller: controller, theme: theme),
                  ),
                  if (controller.isReady)
                    const _HalfBoard(
                      top: true,
                      child: GameOverlay(title: 'Tap the dark tiles', subtitle: 'Start with the bottom one'),
                    )
                  else if (controller.isGameOver)
                    _HalfBoard(
                      // Keeps the mistake visible
                      top: (_mistakeTop ?? 0) + 0.5 >= TilesGameController.visibleRows / 2,
                      child: GameOverlay(
                        title: controller.mistake?.kind == TilesMistakeKind.missedTile ? 'Missed a tile!' : 'Wrong tile!',
                        subtitle: 'You tapped ${controller.score} ${controller.score == 1 ? 'tile' : 'tiles'}',
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  double? get _mistakeTop {
    final mistake = controller.mistake;
    return mistake == null ? null : controller.topOf(mistake.row);
  }

  void _onPointerDown(Offset position, Size size) {
    if (size.isEmpty) return;
    final column = (position.dx / size.width * TilesGameController.columns).floor();
    controller.tap(column, position.dy / size.height * TilesGameController.visibleRows);
  }
}

/// Places [child] centered in the top or bottom half of the board
class _HalfBoard extends StatelessWidget {
  final bool top;
  final Widget child;

  const _HalfBoard({
    required this.top,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: top ? Alignment.topCenter : Alignment.bottomCenter,
      child: FractionallySizedBox(heightFactor: 0.5, widthFactor: 1, child: child),
    );
  }
}

/// Reads the controller while painting, repaints every frame of the controller
class _TilesPainter extends CustomPainter {
  final TilesGameController controller;
  final TilesTheme theme;

  _TilesPainter({
    required this.controller,
    required this.theme,
  }) : super(repaint: controller.frame);

  @override
  void paint(Canvas canvas, Size size) {
    final colors = theme.colors;
    final dimens = theme.dimens;
    final cellWidth = size.width / TilesGameController.columns;
    final cellHeight = size.height / TilesGameController.visibleRows;

    canvas.drawRect(Offset.zero & size, Paint()..color = colors.lightTile);

    final linePaint = Paint()
      ..color = colors.gridLine
      ..strokeWidth = dimens.gridLineWidth;
    for (var column = 1; column < TilesGameController.columns; column++) {
      canvas.drawLine(Offset(column * cellWidth, 0), Offset(column * cellWidth, size.height), linePaint);
    }
    final rows = controller.rows;
    for (final row in rows) {
      final y = (controller.topOf(row.index) + 1) * cellHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    Rect cell(int column, double top) => Rect.fromLTWH(column * cellWidth, top * cellHeight, cellWidth, cellHeight).deflate(dimens.tileInset + dimens.gridLineWidth / 2);
    final radius = Radius.circular(dimens.tileRadius);

    for (final row in rows) {
      final flash = controller.flashOf(row);
      final color = flash == null ? colors.darkTile : Color.lerp(colors.flash, colors.tappedTile, Curves.easeOut.transform(flash))!;
      final rect = cell(row.darkColumn, controller.topOf(row.index));
      canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), Paint()..color = color);
      if (controller.isReady && row.index == 0) _paintStartLabel(canvas, rect);
    }

    final mistake = controller.mistake;
    if (mistake != null) {
      final rect = cell(mistake.column, controller.topOf(mistake.row));
      canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), Paint()..color = colors.mistake);
      final markPaint = Paint()
        ..color = colors.mistakeMark
        ..strokeWidth = dimens.markStrokeWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final markRadius = min(rect.width, rect.height) * 0.22;
      final center = rect.center;
      if (mistake.kind == TilesMistakeKind.wrongTile) {
        // One path, so the crossing lines don't paint twice
        canvas.drawPath(
          Path()
            ..moveTo(center.dx - markRadius, center.dy - markRadius)
            ..lineTo(center.dx + markRadius, center.dy + markRadius)
            ..moveTo(center.dx + markRadius, center.dy - markRadius)
            ..lineTo(center.dx - markRadius, center.dy + markRadius),
          markPaint,
        );
      } else {
        canvas.drawCircle(center, markRadius, markPaint);
      }
    }
  }

  void _paintStartLabel(Canvas canvas, Rect rect) {
    final painter = TextPainter(
      text: TextSpan(text: 'Start', style: theme.textStyles.startLabel),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: rect.width);
    painter
      ..paint(canvas, rect.center - Offset(painter.width / 2, painter.height / 2))
      ..dispose();
  }

  @override
  bool shouldRepaint(covariant _TilesPainter oldDelegate) => oldDelegate.controller != controller || oldDelegate.theme != theme;
}
