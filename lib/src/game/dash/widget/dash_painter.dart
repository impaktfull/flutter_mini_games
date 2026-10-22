import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/game/dash/game/logic/dash_game_controller.dart';
import 'package:flutter_mini_games/src/game/dash/game/model/dash_obstacle.dart';
import 'package:flutter_mini_games/src/game/dash/style/dash_theme.dart';

/// Draws the world of [DashGameController] scaled to the canvas. Repaints when the controller changes.
class DashPainter extends CustomPainter {
  static const _pebbleSpacing = 0.9;
  static const _cloudParallax = 0.15;

  final DashGameController controller;
  final DashTheme theme;

  DashPainter({
    required this.controller,
    required this.theme,
  }) : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / DashGameController.worldWidth;
    final groundY = size.height - DashGameController.groundHeight * scale;
    final world = _World(scale: scale, groundY: groundY);

    _paintClouds(canvas, world);
    _paintGround(canvas, size, world);
    for (final obstacle in controller.obstacles) {
      if (obstacle.isFlyer) {
        _paintFlyer(canvas, world, obstacle);
      } else {
        _paintBlock(canvas, world, obstacle);
      }
    }
    _paintRunner(canvas, world);
  }

  void _paintClouds(Canvas canvas, _World world) {
    final paint = Paint()..color = theme.colors.cloud;
    const span = DashGameController.worldWidth + 3;
    final offset = controller.distance * _cloudParallax;
    for (var i = 0; i < 3; i++) {
      final x = (i * 4.6 + 2 - offset) % span - 1.5;
      final y = 5.3 - (i % 2) * 1.1;
      final center = world.offset(x, y);
      final s = world.scale;
      canvas
        ..drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: 2 * s, height: 0.5 * s), Radius.circular(0.25 * s)), paint)
        ..drawCircle(center.translate(-0.3 * s, -0.25 * s), 0.38 * s, paint)
        ..drawCircle(center.translate(0.35 * s, -0.2 * s), 0.3 * s, paint);
    }
  }

  void _paintGround(Canvas canvas, Size size, _World world) {
    final paint = Paint()
      ..color = theme.colors.ground
      ..strokeWidth = theme.dimens.groundThickness
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, world.groundY), Offset(size.width, world.groundY), paint);

    // Pebbles scroll with the ground
    final pebblePaint = Paint()
      ..color = theme.colors.ground
      ..strokeWidth = max(1, theme.dimens.groundThickness / 2)
      ..strokeCap = StrokeCap.round;
    final first = (controller.distance / _pebbleSpacing).floor();
    final count = (DashGameController.worldWidth / _pebbleSpacing).ceil() + 1;
    for (var i = 0; i <= count; i++) {
      final index = first + i;
      final hash = (index * 7919) % 13;
      final x = index * _pebbleSpacing - controller.distance;
      final depth = -0.25 - (hash % 3) * 0.3;
      final length = 0.1 + (hash % 4) * 0.08;
      canvas.drawLine(world.offset(x, depth), world.offset(x + length, depth), pebblePaint);
    }
  }

  void _paintBlock(Canvas canvas, _World world, DashObstacle obstacle) {
    final rect = world.rect(obstacle.x, obstacle.bottom, obstacle.right, obstacle.top);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        rect,
        topLeft: Radius.circular(theme.dimens.obstacleRadius),
        topRight: Radius.circular(theme.dimens.obstacleRadius),
      ),
      Paint()..color = theme.colors.obstacle,
    );

    // Seams make wide and tall blocks look like stacked crates
    final seam = Paint()
      ..color = theme.colors.obstacleDetail
      ..strokeWidth = 1.5;
    final columns = max(1, (obstacle.width / 0.6).round());
    for (var i = 1; i < columns; i++) {
      final x = rect.left + rect.width * i / columns;
      canvas.drawLine(Offset(x, rect.top + 3), Offset(x, rect.bottom), seam);
    }
    if (obstacle.height >= 1.1) {
      canvas.drawLine(Offset(rect.left, rect.center.dy), Offset(rect.right, rect.center.dy), seam);
    }
  }

  void _paintFlyer(Canvas canvas, _World world, DashObstacle obstacle) {
    final s = world.scale;
    final paint = Paint()..color = theme.colors.obstacle;
    final center = world.offset(obstacle.x + obstacle.width / 2, obstacle.bottom + obstacle.height / 2);
    final body = Rect.fromCenter(center: center, width: obstacle.width * 0.8 * s, height: obstacle.height * 0.8 * s);
    canvas.drawOval(body, paint);

    // Beak points to the runner
    final beak = Path()
      ..moveTo(body.left + 0.05 * s, center.dy - 0.1 * s)
      ..lineTo(world.offset(obstacle.x, 0).dx, center.dy)
      ..lineTo(body.left + 0.05 * s, center.dy + 0.1 * s)
      ..close();
    canvas.drawPath(beak, paint);

    // Flapping wing, always visible above or below the body
    final flap = sin(controller.distance * 2.5 + obstacle.x);
    final wingTip = (flap >= 0 ? 1 : -1) * (0.25 + 0.25 * flap.abs());
    final wing = _polygon([
      Offset(center.dx - 0.2 * s, center.dy),
      Offset(center.dx + 0.3 * s, center.dy),
      Offset(center.dx + 0.15 * s, center.dy - wingTip * s),
    ]);
    canvas
      ..drawPath(wing, paint)
      ..drawCircle(Offset(body.left + body.width * 0.28, center.dy - body.height * 0.15), 0.06 * s, Paint()..color = theme.colors.obstacleDetail);
  }

  void _paintRunner(Canvas canvas, _World world) {
    final s = world.scale;
    final paint = Paint()..color = theme.colors.runner;
    final isDucking = controller.isDucking;
    final width = controller.runnerWidthNow;
    final height = controller.runnerHeightNow;
    const left = DashGameController.runnerX;
    final bottom = controller.runnerY;
    final legHeight = isDucking ? 0.15 : 0.25;
    final bodyBottom = bottom + legHeight;
    final top = bottom + height;

    // Legs: alternate while running, tucked in the air
    final phase = controller.distance * 2.2;
    final onGround = controller.isOnGround;
    final legWidth = 0.16 * s;
    for (final (position, lift) in [
      (0.25, onGround ? max(0.0, sin(phase)) * 0.12 : 0.1),
      (0.68, onGround ? max(0.0, -sin(phase)) * 0.12 : 0.1),
    ]) {
      final legRect = world.rect(left + width * position, bottom + lift, left + width * position, bodyBottom + 0.05);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTRB(legRect.left - legWidth / 2, legRect.top, legRect.left + legWidth / 2, legRect.bottom), Radius.circular(legWidth / 2)),
        paint,
      );
    }

    // Tail
    final tailBase = bodyBottom + (top - bodyBottom) * 0.35;
    final tail = _polygon([
      world.offset(left + 0.15, tailBase),
      world.offset(left - 0.4, tailBase + (isDucking ? 0.1 : 0.4)),
      world.offset(left + 0.15, tailBase + 0.3),
    ]);
    canvas.drawPath(tail, paint);

    // Ears
    final earHeight = isDucking ? 0.12 : 0.28;
    for (final (from, to) in [(0.48, 0.66), (0.7, 0.88)]) {
      final ear = _polygon([
        world.offset(left + width * from, top - 0.05),
        world.offset(left + width * (from + to) / 2 - (isDucking ? 0.1 : 0), top + earHeight),
        world.offset(left + width * to, top - 0.05),
      ]);
      canvas.drawPath(ear, paint);
    }

    // Body
    canvas.drawRRect(RRect.fromRectAndRadius(world.rect(left, bodyBottom, left + width, top), Radius.circular(theme.dimens.runnerRadius)), paint);

    // Eye looks ahead
    final eye = world.offset(left + width * 0.74, top - (isDucking ? 0.22 : 0.3));
    canvas
      ..drawCircle(eye, 0.13 * s, Paint()..color = theme.colors.runnerEye)
      ..drawCircle(eye.translate(0.04 * s, 0), 0.07 * s, Paint()..color = theme.colors.runnerPupil);
  }

  static Path _polygon(List<Offset> points) => Path()..addPolygon(points, true);

  @override
  bool shouldRepaint(covariant DashPainter oldDelegate) => oldDelegate.controller != controller || oldDelegate.theme != theme;
}

/// Converts world units (y up from the ground) to canvas pixels
class _World {
  final double scale;
  final double groundY;

  const _World({
    required this.scale,
    required this.groundY,
  });

  Offset offset(double x, double y) => Offset(x * scale, groundY - y * scale);

  Rect rect(double left, double bottom, double right, double top) => Rect.fromPoints(offset(left, bottom), offset(right, top));
}
