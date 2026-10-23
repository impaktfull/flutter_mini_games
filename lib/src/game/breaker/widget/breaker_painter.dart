import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/game/breaker/game/logic/breaker_game_controller.dart';
import 'package:flutter_mini_games/src/game/breaker/style/breaker_theme.dart';

/// Draws the bricks, the paddle and the ball, scaled from world units to the canvas
class BreakerPainter extends CustomPainter {
  final BreakerGameController controller;
  final BreakerColors colors;
  final BreakerDimens dimens;

  BreakerPainter({
    required this.controller,
    required this.colors,
    required this.dimens,
  }) : super(repaint: controller.frame);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / BreakerGameController.worldWidth;
    final rows = controller.rows;

    for (final brick in controller.bricks) {
      final rect = Rect.fromLTWH(brick.left * scale, brick.top * scale, brick.width * scale, brick.height * scale);
      final radius = Radius.circular(min(dimens.brickRadius, rect.height / 2));
      canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), Paint()..color = colors.brickColor(brick.row, rows));
    }

    const paddleWidth = BreakerGameController.paddleWidth;
    const paddleHeight = BreakerGameController.paddleHeight;
    final paddle = Rect.fromLTWH(
      (controller.paddleX - paddleWidth / 2) * scale,
      BreakerGameController.paddleTop * scale,
      paddleWidth * scale,
      paddleHeight * scale,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(paddle, Radius.circular(paddle.height / 2)), Paint()..color = colors.paddle);

    // The ball fell out of the board when the game is over
    if (controller.isGameOver) return;
    canvas.drawCircle(
      Offset(controller.ballX * scale, controller.ballY * scale),
      BreakerGameController.ballRadius * scale,
      Paint()..color = colors.ball,
    );
  }

  @override
  bool shouldRepaint(covariant BreakerPainter oldDelegate) => oldDelegate.controller != controller || oldDelegate.colors != colors || oldDelegate.dimens != dimens;
}
