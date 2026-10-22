import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_board.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_overlay.dart';
import 'package:flutter_mini_games/src/core/widget/game_loop.dart';
import 'package:flutter_mini_games/src/core/widget/input/game_input_detector.dart';
import 'package:flutter_mini_games/src/game/hop/game/logic/hop_game_controller.dart';
import 'package:flutter_mini_games/src/game/hop/game/model/hop_steer.dart';
import 'package:flutter_mini_games/src/game/hop/style/hop_theme.dart';
import 'package:flutter_mini_games/src/game/hop/widget/hop_painter.dart';

/// The playing field: hold the left or right half of the board (or the arrow keys / A and D)
/// to steer, tap or press space to start.
class HopPlayfield extends StatelessWidget {
  /// Width / height of the board
  static const aspectRatio = HopGameController.worldWidth / HopGameController.viewHeight;

  final HopGameController controller;

  const HopPlayfield({
    required this.controller,
    super.key,
  });

  void _onHorizontalHold(GameDirection? direction) => controller.steerTo(switch (direction) {
    GameDirection.left => HopSteer.left,
    GameDirection.right => HopSteer.right,
    _ => HopSteer.none,
  });

  @override
  Widget build(BuildContext context) {
    final theme = HopTheme.of(context);
    return GameBoard(
      aspectRatio: aspectRatio,
      child: GameLoop(
        controller: controller,
        child: GameInputDetector(
          onTap: controller.start,
          onHorizontalHold: _onHorizontalHold,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(
                color: theme.colors.background,
                child: CustomPaint(
                  painter: HopPainter(controller: controller, colors: theme.colors, dimens: theme.dimens),
                ),
              ),
              if (controller.isReady) const GameOverlay(title: 'Tap to start', subtitle: 'Hold left or right to steer'),
              if (controller.isGameOver) GameOverlay(title: 'Game over', subtitle: 'Score: ${controller.score}'),
            ],
          ),
        ),
      ),
    );
  }
}
