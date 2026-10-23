import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mini_games/src/core/duel/duel_game_controller.dart';
import 'package:flutter_mini_games/src/core/duel/duel_layout.dart';
import 'package:flutter_mini_games/src/core/duel/duel_phase_overlay.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/core/widget/components/how_to_play.dart';
import 'package:flutter_mini_games/src/game/tug/game/logic/tug_game_controller.dart';
import 'package:flutter_mini_games/src/game/tug/style/tug_theme.dart';

/// One player's half: tap anywhere to pull. Every finger counts, also while the
/// other player taps at the same time. A "Tap!" hint pulses on every pull.
class TugSide extends StatelessWidget {
  static const pulseDuration = Duration(milliseconds: 160);

  /// How to play, shown while the players get ready
  static const rules = [
    GameHowToPlayItem(icon: Icons.touch_app, text: 'Tap your half as fast as you can'),
    GameHowToPlayItem(icon: Icons.flag, text: 'Pull the marker to your edge to win the round'),
    GameHowToPlayItem(icon: Icons.emoji_events, text: 'Best of 3 rounds wins'),
  ];

  final TugGameController controller;
  final DuelPlayer player;

  const TugSide({
    required this.controller,
    required this.player,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = TugTheme.of(context);
    final isPlaying = controller.phase == DuelPhase.playing;
    return Stack(
      fit: StackFit.expand,
      children: [
        DuelTapArea(
          onTap: isPlaying ? _pull : null,
          child: ColoredBox(
            color: player == DuelPlayer.bottom ? theme.colors.bottomSide : theme.colors.topSide,
            child: isPlaying
                ? Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: TweenAnimationBuilder<double>(
                        // A new key restarts the pulse on every pull
                        key: ValueKey(controller.pulls(player)),
                        tween: Tween(begin: controller.pulls(player) == 0 ? 1 : 1.25, end: 1),
                        duration: pulseDuration,
                        curve: Curves.easeOut,
                        builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.touch_app, size: theme.dimens.hintIconSize, color: theme.colors.playerColor(player)),
                            Text('Tap!', style: theme.textStyles.hint),
                          ],
                        ),
                      ),
                    ),
                  )
                : const SizedBox.expand(),
          ),
        ),
        DuelPhaseOverlay(controller: controller, player: player, rules: rules),
      ],
    );
  }

  void _pull() {
    unawaited(HapticFeedback.selectionClick());
    controller.pull(player);
  }
}
