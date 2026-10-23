import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/game/hop/game/logic/hop_game_controller.dart';
import 'package:flutter_mini_games/src/game/hop/game/model/hop_platform.dart';
import 'package:flutter_mini_games/src/game/hop/game/model/hop_steer.dart';
import 'package:flutter_mini_games/src/game/hop/style/hop_theme.dart';

/// Draws the visible part of the world: steering highlight, platforms and the character.
class HopPainter extends CustomPainter {
  final HopGameController controller;
  final HopColors colors;
  final HopDimens dimens;

  HopPainter({
    required this.controller,
    required this.colors,
    required this.dimens,
  }) : super(repaint: controller.frame);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / HopGameController.worldWidth;
    final cameraY = controller.cameraY;
    double toScreenY(double worldY) => size.height - (worldY - cameraY) * scale;

    _paintSteer(canvas, size);

    final thickness = dimens.platformThickness * scale;
    for (final platform in controller.platforms) {
      final top = toScreenY(platform.y);
      if (top > size.height || top + thickness < 0) continue;
      _paintPlatform(canvas, platform, Rect.fromLTWH(platform.left * scale, top, platform.width * scale, thickness));
    }

    // Draw the character twice near the edges, so it wraps smoothly
    final x = controller.characterX;
    const r = HopGameController.characterRadius * 1.2;
    final feetY = toScreenY(controller.characterY);
    for (final offset in [0.0, if (x - r < 0) HopGameController.worldWidth, if (x + r > HopGameController.worldWidth) -HopGameController.worldWidth]) {
      _paintCharacter(canvas, Offset((x + offset) * scale, feetY), scale);
    }
  }

  void _paintSteer(Canvas canvas, Size size) {
    final steer = controller.steer;
    if (steer == HopSteer.none) return;
    final half = size.width / 2;
    final rect = steer == HopSteer.left ? Rect.fromLTWH(0, 0, half, size.height) : Rect.fromLTWH(half, 0, half, size.height);
    canvas.drawRect(rect, Paint()..color = colors.steerIndicator);
  }

  void _paintPlatform(Canvas canvas, HopPlatform platform, Rect rect) {
    final radius = Radius.circular(min(dimens.platformRadius, rect.height / 2));
    switch (platform.type) {
      case HopPlatformType.normal:
        canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), Paint()..color = colors.platform);
      case HopPlatformType.moving:
        canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), Paint()..color = colors.movingPlatform);
      case HopPlatformType.breakable:
        final fill = Paint()..color = colors.breakablePlatform;
        final stroke = Paint()
          ..color = colors.breakablePlatformCrack
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        if (platform.isBroken) {
          // Two halves drifting apart
          final gap = rect.width * 0.08;
          final halfWidth = rect.width / 2 - gap;
          for (final left in [rect.left, rect.center.dx + gap]) {
            final half = RRect.fromRectAndRadius(Rect.fromLTWH(left, rect.top, halfWidth, rect.height), radius);
            canvas
              ..drawRRect(half, fill)
              ..drawRRect(half, stroke);
          }
          return;
        }
        final shape = RRect.fromRectAndRadius(rect, radius);
        canvas
          ..drawRRect(shape, fill)
          ..drawRRect(shape, stroke);
        final crack = Path()
          ..moveTo(rect.center.dx - rect.height * 0.3, rect.top)
          ..lineTo(rect.center.dx + rect.height * 0.3, rect.center.dy)
          ..lineTo(rect.center.dx - rect.height * 0.2, rect.bottom);
        canvas.drawPath(crack, stroke);
    }
  }

  void _paintCharacter(Canvas canvas, Offset feet, double scale) {
    // Stretches while moving fast, squashes while slow (around the top of a jump)
    final speed = (controller.velocityY / HopGameController.jumpVelocity).abs().clamp(0.0, 1.0);
    final stretch = 0.94 + speed * 0.12;
    final width = HopGameController.characterRadius * 2.2 * scale / stretch;
    final height = HopGameController.characterHeight * scale * stretch;
    final body = Rect.fromLTWH(feet.dx - width / 2, feet.dy - height, width, height);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        body,
        topLeft: Radius.circular(width / 2),
        topRight: Radius.circular(width / 2),
        bottomLeft: Radius.circular(width * 0.3),
        bottomRight: Radius.circular(width * 0.3),
      ),
      Paint()..color = colors.character,
    );

    final face = Paint()..color = colors.characterFace;
    final look = controller.facing.sign * width * 0.08;
    final eyeY = body.top + height * 0.4;
    final eyeRadius = width * 0.09;
    canvas
      ..drawCircle(Offset(body.center.dx - width * 0.18 + look, eyeY), eyeRadius, face)
      ..drawCircle(Offset(body.center.dx + width * 0.18 + look, eyeY), eyeRadius, face);

    final smile = Rect.fromCenter(center: Offset(body.center.dx + look, body.top + height * 0.58), width: width * 0.32, height: height * 0.2);
    canvas.drawArc(
      smile,
      0.2,
      pi - 0.4,
      false,
      Paint()
        ..color = colors.characterFace
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(1.5, width * 0.06)
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant HopPainter oldDelegate) => oldDelegate.controller != controller || oldDelegate.colors != colors || oldDelegate.dimens != dimens;
}
