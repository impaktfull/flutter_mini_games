import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_pair.dart';
import 'package:flutter_mini_games/src/core/duel/duel_game_controller.dart';
import 'package:flutter_mini_games/src/core/duel/duel_layout.dart';
import 'package:flutter_mini_games/src/core/duel/duel_phase_overlay.dart';
import 'package:flutter_mini_games/src/core/widget/components/cached_text_painter.dart';
import 'package:flutter_mini_games/src/core/widget/components/how_to_play.dart';
import 'package:flutter_mini_games/src/core/widget/game_loop.dart';
import 'package:flutter_mini_games/src/game/push/game/logic/push_game_controller.dart';
import 'package:flutter_mini_games/src/game/push/style/push_theme.dart';
import 'package:flutter_mini_games/src/game/push/widget/push_painter.dart';
import 'package:flutter_mini_games/src/game/push/widget/push_touch_area.dart';

/// The shared ring fills the space, each player's half on top of it takes their taps
/// and shows the match flow (ready, countdown, round result, winner)
class PushArena extends StatefulWidget {
  static const _rules = [
    GameHowToPlayItem(icon: Icons.touch_app, text: 'Tap your half\nto push'),
    GameHowToPlayItem(icon: Icons.swap_horiz, text: 'Aim left / right,\nhold to steer'),
    GameHowToPlayItem(icon: Icons.emoji_events, text: 'Push them out\nof the ring'),
  ];

  final PushGameController controller;

  const PushArena({
    required this.controller,
    super.key,
  });

  @override
  State<PushArena> createState() => _PushArenaState();
}

class _PushArenaState extends State<PushArena> {
  /// Player numbers on the discs, only laid out when they change
  final DuelPair<CachedTextPainter> _labels = DuelPair.generate((player) => CachedTextPainter());

  @override
  void dispose() {
    for (final label in _labels.values) {
      label.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final theme = PushTheme.of(context);
    return GameLoop(
      controller: controller,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: CustomPaint(
              painter: PushPainter(controller: controller, theme: theme, labels: _labels),
            ),
          ),
          DuelLayout(
            side: (context, player) => PushTouchArea(
              controller: controller,
              player: player,
              child: DuelPhaseOverlay(
                controller: controller,
                player: player,
                rules: PushArena._rules,
                // 0 – 0 says nothing yet and would run into the ready button
                showScore: controller.phase != DuelPhase.ready,
                roundMessage: switch (controller.roundWinner) {
                  null => 'Both out of the ring',
                  final winner when winner == player => 'Pushed out!',
                  _ => 'Out of the ring',
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
