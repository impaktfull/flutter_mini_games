import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/game/reflex/game/logic/reflex_game_controller.dart';
import 'package:flutter_mini_games/src/game/reflex/game/model/reflex_phase.dart';
import 'package:flutter_mini_games/src/game/reflex/style/reflex_theme.dart';

/// The playing field: changes color per phase, with a big icon and message so it never relies on color alone.
///
/// The color changes instantly (no animation), an animation would delay the moment the player can react.
class ReflexBoard extends StatelessWidget {
  final ReflexGameController controller;

  const ReflexBoard({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ReflexTheme.of(context);
    final colors = theme.colors;
    final (background, foreground) = switch (controller.phase) {
      ReflexPhase.waiting => (colors.waiting, colors.onWaiting),
      ReflexPhase.go => (colors.go, colors.onGo),
      ReflexPhase.tooEarly => (colors.tooEarly, colors.onTooEarly),
      ReflexPhase.ready || ReflexPhase.measured || ReflexPhase.finished => (colors.idle, colors.onIdle),
    };
    final (icon, message, hint) = _content();
    return ColoredBox(
      color: background,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          // Scales down on small boards instead of overflowing
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 12,
              children: [
                Icon(icon, size: theme.dimens.iconSize, color: foreground),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textStyles.message.copyWith(color: foreground),
                ),
                if (hint != null)
                  Text(
                    hint,
                    textAlign: TextAlign.center,
                    style: theme.textStyles.hint.copyWith(color: foreground),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  (IconData, String, String?) _content() {
    const tries = ReflexGameController.tries;
    return switch (controller.phase) {
      ReflexPhase.ready => (Icons.touch_app, 'Tap to start', '$tries tries, tap when\nthe color changes'),
      ReflexPhase.waiting => (Icons.hourglass_top, 'Wait...', 'Tap when the color changes'),
      ReflexPhase.go => (Icons.bolt, 'TAP!', null),
      ReflexPhase.tooEarly => (Icons.front_hand, 'Too early!', 'Tap to retry try ${controller.currentTry}'),
      ReflexPhase.measured => (Icons.timer_outlined, '${controller.lastTime} ms', 'Tap for try ${controller.currentTry + 1} of $tries'),
      ReflexPhase.finished => (Icons.emoji_events, '${controller.averageMs} ms', 'Average, score ${controller.score}'),
    };
  }
}
