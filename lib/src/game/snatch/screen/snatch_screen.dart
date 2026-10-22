import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_game_controller.dart';
import 'package:flutter_mini_games/src/core/duel/duel_layout.dart';
import 'package:flutter_mini_games/src/core/duel/duel_phase_overlay.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/core/widget/components/how_to_play.dart';
import 'package:flutter_mini_games/src/core/widget/game_loop.dart';
import 'package:flutter_mini_games/src/core/widget/provider/game_controller_provider.dart';
import 'package:flutter_mini_games/src/core/widget/screen/screen.dart';
import 'package:flutter_mini_games/src/game/snatch/game/logic/snatch_game_controller.dart';
import 'package:flutter_mini_games/src/game/snatch/style/snatch_theme.dart';
import 'package:flutter_mini_games/src/game/snatch/widget/snatch_half.dart';
import 'package:flutter_mini_games/src/game/snatch/widget/snatch_target.dart';

class SnatchScreen extends StatelessWidget {
  static const _rules = [
    GameHowToPlayItem(icon: Icons.visibility, text: 'Find the symbol\nin the middle'),
    GameHowToPlayItem(icon: Icons.touch_app, text: 'Tap it first\nin your half'),
    GameHowToPlayItem(icon: Icons.emoji_events, text: 'Wrong tap: -1,\nfirst to ${SnatchGameController.pointsToWin} wins'),
  ];

  final CoreGameTheme? coreTheme;
  final GameThemeOverride<SnatchTheme>? theme;

  const SnatchScreen({
    this.coreTheme,
    this.theme,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GameControllerProvider(
      create: SnatchGameController.new,
      coreTheme: coreTheme,
      theme: (core) {
        final defaults = SnatchTheme.fromCore(core);
        return theme?.call(defaults) ?? defaults;
      },
      builder: (context, controller, theme, coreTheme) => FlutterMiniGamesScreen(
        title: 'Snatch',
        child: GameLoop(
          controller: controller,
          child: DuelLayout(
            side: (context, player) => Stack(
              fit: StackFit.expand,
              children: [
                SnatchHalf(controller: controller, player: player),
                DuelPhaseOverlay(
                  controller: controller,
                  player: player,
                  rules: _rules,
                  // 0 – 0 says nothing yet and would run into the ready button
                  showScore: controller.phase != DuelPhase.ready,
                ),
              ],
            ),
            center: SnatchTarget(controller: controller),
          ),
        ),
      ),
    );
  }
}
