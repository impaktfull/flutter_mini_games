import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_board.dart';
import 'package:flutter_mini_games/src/core/widget/input/game_input_detector.dart';
import 'package:flutter_mini_games/src/game/boxes/game/logic/boxes_game_controller.dart';
import 'package:flutter_mini_games/src/game/boxes/game/model/boxes_board_geometry.dart';
import 'package:flutter_mini_games/src/game/boxes/game/model/boxes_edge.dart';
import 'package:flutter_mini_games/src/game/boxes/style/boxes_theme.dart';

/// The dots, lines and claimed boxes. A tap between two dots draws the nearest free line.
class BoxesBoard extends StatelessWidget {
  final BoxesGameController controller;

  const BoxesBoard({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = BoxesTheme.of(context);
    return GameBoard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final geometry = BoxesBoardGeometry(
            size: constraints.biggest,
            rows: controller.rows,
            cols: controller.cols,
            inset: theme.dimens.boardInset,
          );
          return GameInputDetector(
            onTapAt: (position) {
              if (controller.isGameOver) return;
              final edge = geometry.edgeAt(position, isFree: (edge) => !controller.isDrawn(edge));
              if (edge != null) controller.drawLine(edge);
            },
            child: CustomPaint(
              size: constraints.biggest,
              painter: _BoxesPainter(
                geometry: geometry,
                theme: theme,
                lines: controller.lines,
                boxes: [
                  for (var row = 0; row < controller.rows; row++)
                    for (var col = 0; col < controller.cols; col++) controller.boxOwner(row, col),
                ],
                lastLine: controller.lastLine,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BoxesPainter extends CustomPainter {
  final BoxesBoardGeometry geometry;
  final BoxesTheme theme;
  final Map<BoxesEdge, DuelPlayer> lines;
  final List<DuelPlayer?> boxes;
  final BoxesEdge? lastLine;

  const _BoxesPainter({
    required this.geometry,
    required this.theme,
    required this.lines,
    required this.boxes,
    required this.lastLine,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final colors = theme.colors;
    final dimens = theme.dimens;
    final rows = geometry.rows;
    final cols = geometry.cols;

    // Claimed boxes: filled in the player's color with the player's symbol
    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final owner = boxes[row * cols + col];
        if (owner == null) continue;
        final rect = geometry.box(row, col).deflate(dimens.lineWidth / 2 + dimens.boxInset);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(dimens.boxRadius)),
          Paint()..color = theme.playerColor(owner),
        );
        _paintSymbol(canvas, rect, owner);
      }
    }

    final guidePaint = Paint()
      ..color = colors.guide
      ..strokeWidth = dimens.guideWidth
      ..strokeCap = StrokeCap.round;
    final linePaint = Paint()
      ..strokeWidth = dimens.lineWidth
      ..strokeCap = StrokeCap.round;
    for (final edge in BoxesEdge.all(rows: rows, cols: cols)) {
      final (start, end) = geometry.endsOf(edge);
      final owner = lines[edge];
      if (owner == null) {
        canvas.drawLine(start, end, guidePaint);
      } else {
        canvas.drawLine(start, end, linePaint..color = theme.playerColor(owner));
      }
    }

    final dotPaint = Paint()..color = colors.dot;
    for (var row = 0; row <= rows; row++) {
      for (var col = 0; col <= cols; col++) {
        canvas.drawCircle(geometry.dot(row, col), dimens.dotRadius, dotPaint);
      }
    }

    // Marks the most recently drawn line, so the other player sees what changed
    final lastLine = this.lastLine;
    final lastOwner = lastLine == null ? null : lines[lastLine];
    if (lastLine != null && lastOwner != null) {
      final (start, end) = geometry.endsOf(lastLine);
      canvas.drawCircle((start + end) / 2, dimens.lastLineMarkerRadius, Paint()..color = theme.onPlayerColor(lastOwner));
    }
  }

  void _paintSymbol(Canvas canvas, Rect rect, DuelPlayer owner) {
    final style = theme.textStyles.boxSymbol;
    final painter = TextPainter(
      text: TextSpan(
        text: owner.symbol,
        style: style.copyWith(
          color: theme.onPlayerColor(owner),
          fontSize: min(style.fontSize ?? 24, rect.shortestSide * 0.6),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.save();
    canvas.translate(rect.center.dx, rect.center.dy);
    // The top player reads their boxes from the other side of the phone
    if (owner == DuelPlayer.top) canvas.rotate(pi);
    painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
    canvas.restore();
    painter.dispose();
  }

  @override
  bool shouldRepaint(_BoxesPainter oldDelegate) =>
      oldDelegate.geometry.size != geometry.size ||
      oldDelegate.geometry.inset != geometry.inset ||
      oldDelegate.theme != theme ||
      oldDelegate.lastLine != lastLine ||
      !_sameLines(oldDelegate.lines, lines) ||
      !_sameBoxes(oldDelegate.boxes, boxes);

  static bool _sameLines(Map<BoxesEdge, DuelPlayer> a, Map<BoxesEdge, DuelPlayer> b) => a.length == b.length && a.entries.every((entry) => b[entry.key] == entry.value);

  static bool _sameBoxes(List<DuelPlayer?> a, List<DuelPlayer?> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
