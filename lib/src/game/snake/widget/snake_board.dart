import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/game/snake/game/logic/snake_game_controller.dart';
import 'package:flutter_mini_games/src/game/snake/game/model/snake_cell.dart';
import 'package:flutter_mini_games/src/game/snake/style/snake_theme.dart';

/// Draws the board, the food and the snake. The snake is interpolated between two steps.
class SnakeBoard extends StatelessWidget {
  final SnakeGameController controller;

  const SnakeBoard({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SnakeTheme.of(context);
    return CustomPaint(
      size: Size.infinite,
      painter: _SnakePainter(controller: controller, colors: theme.colors, dimens: theme.dimens),
    );
  }
}

/// Reads the controller while painting, repaints every frame of the controller
class _SnakePainter extends CustomPainter {
  final SnakeGameController controller;
  final SnakeColors colors;
  final SnakeDimens dimens;

  _SnakePainter({
    required this.controller,
    required this.colors,
    required this.dimens,
  }) : super(repaint: controller.frame);

  @override
  void paint(Canvas canvas, Size size) {
    final gridSize = controller.gridSize;
    final snake = controller.snake;
    final progress = controller.stepProgress;
    final cellSize = size.width / gridSize;
    Offset center(double x, double y) => Offset((x + 0.5) * cellSize, (y + 0.5) * cellSize);
    Offset lerpCell(SnakeCell from, SnakeCell to) => center(lerpDouble(from.x, to.x, progress)!, lerpDouble(from.y, to.y, progress)!);

    // Checkerboard
    canvas.drawRect(Offset.zero & size, Paint()..color = colors.cell);
    final alternate = Paint()..color = colors.cellAlternate;
    for (var y = 0; y < gridSize; y++) {
      for (var x = 0; x < gridSize; x++) {
        if ((x + y).isOdd) canvas.drawRect(Rect.fromLTWH(x * cellSize, y * cellSize, cellSize, cellSize), alternate);
      }
    }

    // Food
    final food = controller.food;
    if (food != null) {
      canvas.drawCircle(center(food.x.toDouble(), food.y.toDouble()), cellSize * dimens.foodSize / 2, Paint()..color = colors.food);
    }

    // Body: one stroked path, so segments never overlap each other
    final headPosition = lerpCell(snake[1], snake[0]);
    final path = Path()..moveTo(headPosition.dx, headPosition.dy);
    for (final cell in snake.skip(1)) {
      final point = center(cell.x.toDouble(), cell.y.toDouble());
      path.lineTo(point.dx, point.dy);
    }
    final removedTail = controller.removedTail;
    if (removedTail != null) {
      final tail = lerpCell(removedTail, snake.last);
      path.lineTo(tail.dx, tail.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = colors.snakeBody
        ..style = PaintingStyle.stroke
        ..strokeWidth = cellSize * dimens.snakeThickness
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Head with eyes looking in the direction of movement
    canvas.drawCircle(headPosition, cellSize * dimens.headSize / 2, Paint()..color = colors.snakeHead);
    final forward = Offset((snake[0].x - snake[1].x).toDouble(), (snake[0].y - snake[1].y).toDouble());
    final side = Offset(-forward.dy, forward.dx);
    final eyePaint = Paint()..color = colors.snakeEye;
    for (final sign in const [-1.0, 1.0]) {
      final eye = headPosition + forward * cellSize * 0.18 + side * sign * cellSize * 0.2;
      canvas.drawCircle(eye, cellSize * 0.09, eyePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SnakePainter oldDelegate) => oldDelegate.controller != controller || oldDelegate.colors != colors || oldDelegate.dimens != dimens;
}
