import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_layout.dart';
import 'package:flutter_mini_games/src/core/duel/duel_phase_overlay.dart';
import 'package:flutter_mini_games/src/core/widget/game_loop.dart';
import 'package:flutter_mini_games/src/game/push/game/logic/push_game_controller.dart';
import 'package:flutter_mini_games/src/game/push/style/push_theme.dart';
import 'package:flutter_mini_games/src/game/push/widget/push_painter.dart';
import 'package:flutter_mini_games/src/game/push/widget/push_touch_area.dart';

/// The shared ring fills the space, each player's half on top of it takes their taps
/// and shows the match flow (ready, countdown, round result, winner)
class PushArena extends StatelessWidget {
  final PushGameController controller;

  const PushArena({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = PushTheme.of(context);
    return GameLoop(
      controller: controller,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: CustomPaint(
              painter: PushPainter(controller: controller, theme: theme),
            ),
          ),
          DuelLayout(
            side: (context, player) => PushTouchArea(
              controller: controller,
              player: player,
              child: DuelPhaseOverlay(controller: controller, player: player),
            ),
          ),
        ],
      ),
    );
  }
}
