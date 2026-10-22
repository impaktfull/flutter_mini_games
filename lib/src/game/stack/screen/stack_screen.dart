import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/core/widget/components/button.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_board.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_overlay.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_stats_bar.dart';
import 'package:flutter_mini_games/src/core/widget/components/how_to_play.dart';
import 'package:flutter_mini_games/src/core/widget/game_loop.dart';
import 'package:flutter_mini_games/src/core/widget/input/game_input_detector.dart';
import 'package:flutter_mini_games/src/core/widget/provider/game_controller_provider.dart';
import 'package:flutter_mini_games/src/core/widget/screen/game_screen_layout.dart';
import 'package:flutter_mini_games/src/core/widget/screen/screen.dart';
import 'package:flutter_mini_games/src/game/stack/game/logic/stack_game_controller.dart';
import 'package:flutter_mini_games/src/game/stack/screen/stack_header.dart';
import 'package:flutter_mini_games/src/game/stack/style/stack_theme.dart';
import 'package:flutter_mini_games/src/game/stack/widget/stack_tower.dart';

class StackScreen extends StatelessWidget {
  final CoreGameTheme? coreTheme;
  final GameThemeOverride<StackTheme>? theme;

  const StackScreen({
    this.coreTheme,
    this.theme,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GameControllerProvider(
      create: StackGameController.new,
      coreTheme: coreTheme,
      theme: (core) {
        final defaults = StackTheme.fromCore(core);
        return theme?.call(defaults) ?? defaults;
      },
      builder: (context, controller, theme, coreTheme) => FlutterMiniGamesScreen(
        title: 'Stack',
        child: GameScreenLayout(
          header: Column(
            spacing: 8,
            children: [
              StackHeader(controller: controller),
              GameStatsBar(controller: controller),
            ],
          ),
          boardAspectRatio: StackGameController.aspectRatio,
          board: GameBoard(
            aspectRatio: StackGameController.aspectRatio,
            child: GameLoop(
              controller: controller,
              child: GameInputDetector(
                onTap: controller.onTap,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    StackTower(controller: controller),
                    if (controller.isReady) const GameOverlay(title: 'Tap to start', subtitle: 'Build the highest tower'),
                    if (controller.isGameOver) GameOverlay(title: 'Game over', subtitle: 'Score: ${controller.score}'),
                  ],
                ),
              ),
            ),
          ),
          controls: controller.isGameOver
              ? GameButton(onTap: controller.resetGame, icon: Icons.replay, label: 'Play again')
              : GameButton(onTap: controller.isRunning ? controller.resetGame : null, icon: Icons.refresh, label: 'Restart'),
          footer: const GameHowToPlay(
            items: [
              GameHowToPlayItem(icon: Icons.touch_app, text: 'Tap to drop,\noverhang is cut off'),
              GameHowToPlayItem(icon: Icons.star, text: 'Perfect drops\ngive a bonus'),
            ],
          ),
        ),
      ),
    );
  }
}
