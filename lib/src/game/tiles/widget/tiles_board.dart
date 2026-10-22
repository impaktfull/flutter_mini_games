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
                    painter: _TilesPainter(
                      tiles: [
                        for (final row in controller.rows)
                          _PaintedRow(
                            top: controller.topOf(row.index),
                            darkColumn: row.darkColumn,
                            flash: controller.flashOf(row),
                            isStart: controller.isReady && row.index == 0,
                          ),
                      ],
                      mistake: controller.mistake,
                      mistakeTop: _mistakeTop,
                      theme: theme,
                    ),
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

class _PaintedRow {
  /// Top of the row in rows from the top of the board
  final double top;
  final int darkColumn;

  /// Flash progress of a tapped tile (0..1), null when not tapped
  final double? flash;

  /// The first dark tile before the game starts
  final bool isStart;

  const _PaintedRow({
    required this.top,
    required this.darkColumn,
    required this.flash,
    required this.isStart,
  });

  @override
  bool operator ==(Object other) => other is _PaintedRow && other.top == top && other.darkColumn == darkColumn && other.flash == flash && other.isStart == isStart;

  @override
  int get hashCode => Object.hash(top, darkColumn, flash, isStart);
}

class _TilesPainter extends CustomPainter {
  final List<_PaintedRow> tiles;
  final TilesMistake? mistake;
  final double? mistakeTop;
  final TilesTheme theme;

  const _TilesPainter({
    required this.tiles,
    required this.mistake,
    required this.mistakeTop,
    required this.theme,
  });

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
    for (final row in tiles) {
      final y = (row.top + 1) * cellHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    Rect cell(int column, double top) => Rect.fromLTWH(column * cellWidth, top * cellHeight, cellWidth, cellHeight).deflate(dimens.tileInset + dimens.gridLineWidth / 2);
    final radius = Radius.circular(dimens.tileRadius);

    for (final row in tiles) {
      final flash = row.flash;
      final color = flash == null ? colors.darkTile : Color.lerp(colors.flash, colors.tappedTile, Curves.easeOut.transform(flash))!;
      final rect = cell(row.darkColumn, row.top);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), Paint()..color = color);
      if (row.isStart) _paintStartLabel(canvas, rect);
    }

    final mistake = this.mistake;
    final mistakeTop = this.mistakeTop;
    if (mistake != null && mistakeTop != null) {
      final rect = cell(mistake.column, mistakeTop);
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
  bool shouldRepaint(covariant _TilesPainter oldDelegate) =>
      oldDelegate.mistake != mistake || oldDelegate.mistakeTop != mistakeTop || oldDelegate.theme != theme || !_sameTiles(oldDelegate.tiles, tiles);

  static bool _sameTiles(List<_PaintedRow> a, List<_PaintedRow> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
