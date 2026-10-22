import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_board.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_overlay.dart';
import 'package:flutter_mini_games/src/core/widget/game_loop.dart';
import 'package:flutter_mini_games/src/core/widget/input/game_input_detector.dart';
import 'package:flutter_mini_games/src/game/dash/game/logic/dash_game_controller.dart';
import 'package:flutter_mini_games/src/game/dash/style/dash_theme.dart';
import 'package:flutter_mini_games/src/game/dash/widget/dash_painter.dart';

/// The playing field: board, game loop, input, world and overlays
class DashField extends StatelessWidget {
  final DashGameController controller;

  const DashField({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = DashTheme.of(context);
    return GameBoard(
      aspectRatio: DashGameController.worldWidth / DashGameController.worldHeight,
      child: GameLoop(
        controller: controller,
        child: GameInputDetector(
          onTap: controller.jump,
          onSwipe: controller.onSwipe,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: DashPainter(controller: controller, theme: theme),
              ),
              if (controller.isReady) const GameOverlay(title: 'Tap to start', subtitle: 'Tap to jump'),
              if (controller.isGameOver) GameOverlay(title: 'Game over', subtitle: 'Score: ${controller.score}'),
            ],
          ),
        ),
      ),
    );
  }
}
