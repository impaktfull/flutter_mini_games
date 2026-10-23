import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_board.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_overlay.dart';
import 'package:flutter_mini_games/src/core/widget/game_loop.dart';
import 'package:flutter_mini_games/src/core/widget/input/game_input_detector.dart';
import 'package:flutter_mini_games/src/game/flit/game/logic/flit_game_controller.dart';
import 'package:flutter_mini_games/src/game/flit/game/model/flit_column.dart';
import 'package:flutter_mini_games/src/game/flit/style/flit_theme.dart';

/// Playing field of Flit: runs the game loop, handles taps and draws the world.
class FlitBoard extends StatefulWidget {
  final FlitGameController controller;

  const FlitBoard({
    required this.controller,
    super.key,
  });

  @override
  State<FlitBoard> createState() => _FlitBoardState();
}

class _FlitBoardState extends State<FlitBoard> with SingleTickerProviderStateMixin {
  /// Lets the flyer hover up and down while waiting for the first tap
  late final AnimationController _hover = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

  @override
  void initState() {
    super.initState();
    _syncHover();
  }

  @override
  void didUpdateWidget(covariant FlitBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncHover();
  }

  void _syncHover() {
    if (widget.controller.isReady) {
      if (!_hover.isAnimating) unawaited(_hover.repeat());
    } else if (_hover.isAnimating) {
      _hover
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _hover.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final theme = FlitTheme.of(context);
    return GameBoard(
      aspectRatio: FlitGameController.worldWidth,
      child: GameLoop(
        controller: controller,
        child: GameInputDetector(
          onTap: controller.flap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AnimatedBuilder(
                animation: _hover,
                builder: (context, child) => CustomPaint(
                  painter: _FlitPainter(
                    columns: controller.columns,
                    flyerY: controller.flyerY + (controller.isReady ? sin(_hover.value * 2 * pi) * 0.015 : 0),
                    flyerRotation: controller.isReady ? 0 : controller.flyerRotation,
                    isWingUp: controller.velocity < 0,
                    theme: theme,
                  ),
                ),
              ),
              if (!controller.isReady)
                Positioned(
                  top: 12,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: theme.colors.scoreBackground,
                          borderRadius: BorderRadius.circular(theme.dimens.scoreRadius),
                        ),
                        child: Text('${controller.score}', textAlign: TextAlign.center, style: theme.textStyles.score),
                      ),
                    ),
                  ),
                ),
              if (controller.isReady)
                const GameOverlay(title: 'Tap to start', subtitle: 'Tap, space or ↑ to flap')
              else if (controller.isGameOver)
                GameOverlay(title: 'Game over', subtitle: 'You passed ${controller.score} ${controller.score == 1 ? 'column' : 'columns'}'),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlitPainter extends CustomPainter {
  final List<FlitColumn> columns;
  final double flyerY;
  final double flyerRotation;
  final bool isWingUp;
  final FlitTheme theme;

  const _FlitPainter({
    required this.columns,
    required this.flyerY,
    required this.flyerRotation,
    required this.isWingUp,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final colors = theme.colors;
    final dimens = theme.dimens;
    // World units to pixels: the world is 1.0 high
    final scale = size.height;
    final groundTop = FlitGameController.groundY * scale;

    canvas.drawRect(Offset.zero & size, Paint()..color = colors.sky);

    final columnPaint = Paint()..color = colors.column;
    final capPaint = Paint()..color = colors.columnCap;
    final radius = Radius.circular(dimens.columnRadius);
    for (final column in columns) {
      final left = column.x * scale;
      final right = (column.x + FlitGameController.columnWidth) * scale;
      final gapTop = column.gapTop * scale;
      final gapBottom = column.gapBottom * scale;
      final capLeft = left - dimens.columnCapOverhang;
      final capRight = right + dimens.columnCapOverhang;

      canvas
        ..drawRRect(RRect.fromLTRBR(left, -dimens.columnRadius, right, gapTop, radius), columnPaint)
        ..drawRRect(RRect.fromLTRBR(capLeft, gapTop - dimens.columnCapHeight, capRight, gapTop, radius), capPaint)
        ..drawRRect(RRect.fromLTRBR(left, gapBottom, right, groundTop + dimens.columnRadius, radius), columnPaint)
        ..drawRRect(RRect.fromLTRBR(capLeft, gapBottom, capRight, gapBottom + dimens.columnCapHeight, radius), capPaint);
    }

    canvas
      ..drawRect(Rect.fromLTRB(0, groundTop, size.width, size.height), Paint()..color = colors.ground)
      ..drawRect(Rect.fromLTRB(0, groundTop, size.width, groundTop + dimens.groundLineThickness), Paint()..color = colors.groundLine);

    _paintFlyer(canvas, Offset(FlitGameController.flyerX * scale, flyerY * scale), FlitGameController.flyerRadius * scale);
  }

  void _paintFlyer(Canvas canvas, Offset center, double radius) {
    final colors = theme.colors;
    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..rotate(flyerRotation)
      ..drawCircle(Offset.zero, radius, Paint()..color = colors.flyer)
      // Wing: points up while rising, down while falling
      ..drawOval(
        Rect.fromCenter(
          center: Offset(-radius * 0.25, isWingUp ? -radius * 0.05 : radius * 0.25),
          width: radius * 1.1,
          height: radius * 0.6,
        ),
        Paint()..color = colors.flyerWing,
      )
      ..drawCircle(Offset(radius * 0.4, -radius * 0.3), radius * 0.32, Paint()..color = colors.flyerEye)
      ..drawCircle(Offset(radius * 0.5, -radius * 0.3), radius * 0.15, Paint()..color = colors.flyerPupil)
      ..restore();
  }

  @override
  bool shouldRepaint(covariant _FlitPainter oldDelegate) =>
      oldDelegate.flyerY != flyerY ||
      oldDelegate.flyerRotation != flyerRotation ||
      oldDelegate.isWingUp != isWingUp ||
      oldDelegate.theme != theme ||
      !_sameColumns(oldDelegate.columns, columns);

  static bool _sameColumns(List<FlitColumn> a, List<FlitColumn> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].x != b[i].x || a[i].gapCenter != b[i].gapCenter) return false;
    }
    return true;
  }
}
