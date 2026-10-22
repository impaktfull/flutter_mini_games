import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/core/widget/components/button.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_board.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_stats_bar.dart';
import 'package:flutter_mini_games/src/core/widget/components/how_to_play.dart';
import 'package:flutter_mini_games/src/core/widget/game_loop.dart';
import 'package:flutter_mini_games/src/core/widget/input/game_input_detector.dart';
import 'package:flutter_mini_games/src/core/widget/provider/game_controller_provider.dart';
import 'package:flutter_mini_games/src/core/widget/screen/game_screen_layout.dart';
import 'package:flutter_mini_games/src/core/widget/screen/screen.dart';
import 'package:flutter_mini_games/src/game/reflex/game/logic/reflex_game_controller.dart';
import 'package:flutter_mini_games/src/game/reflex/screen/reflex_header.dart';
import 'package:flutter_mini_games/src/game/reflex/style/reflex_theme.dart';
import 'package:flutter_mini_games/src/game/reflex/widget/reflex_board.dart';

class ReflexScreen extends StatelessWidget {
  /// Width / height of the playing field
  static const boardAspectRatio = 3 / 4;

  final CoreGameTheme? coreTheme;
  final GameThemeOverride<ReflexTheme>? theme;

  const ReflexScreen({
    this.coreTheme,
    this.theme,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GameControllerProvider(
      create: ReflexGameController.new,
      coreTheme: coreTheme,
      theme: (core) {
        final defaults = ReflexTheme.fromCore(core);
        return theme?.call(defaults) ?? defaults;
      },
      builder: (context, controller, theme, coreTheme) => FlutterMiniGamesScreen(
        title: 'Reflex',
        child: GameScreenLayout(
          header: Column(
            spacing: 8,
            children: [
              ReflexHeader(controller: controller),
              GameStatsBar(controller: controller),
            ],
          ),
          boardAspectRatio: boardAspectRatio,
          board: GameBoard(
            aspectRatio: boardAspectRatio,
            child: GameLoop(
              controller: controller,
              child: GameInputDetector(
                onTap: controller.onTap,
                child: ReflexBoard(controller: controller),
              ),
            ),
          ),
          controls: controller.isGameOver
              ? GameButton(onTap: controller.resetGame, icon: Icons.replay, label: 'Play again')
              : GameButton(onTap: controller.isReady ? null : controller.resetGame, icon: Icons.refresh, label: 'Restart'),
          footer: const GameHowToPlay(
            items: [
              GameHowToPlayItem(icon: Icons.touch_app, text: 'Tap as soon as\nthe color changes'),
              GameHowToPlayItem(icon: Icons.front_hand, text: 'Tapping too early\nretries that try'),
              GameHowToPlayItem(icon: Icons.emoji_events, text: 'Score: 1000 minus\nyour average in ms'),
            ],
          ),
        ),
      ),
    );
  }
}
