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
import 'package:flutter_mini_games/src/game/whack/game/logic/whack_game_controller.dart';
import 'package:flutter_mini_games/src/game/whack/screen/whack_header.dart';
import 'package:flutter_mini_games/src/game/whack/style/whack_theme.dart';
import 'package:flutter_mini_games/src/game/whack/widget/whack_field.dart';

class WhackScreen extends StatelessWidget {
  final CoreGameTheme? coreTheme;
  final GameThemeOverride<WhackTheme>? theme;

  const WhackScreen({
    this.coreTheme,
    this.theme,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GameControllerProvider(
      create: WhackGameController.new,
      coreTheme: coreTheme,
      theme: (core) {
        final defaults = WhackTheme.fromCore(core);
        return theme?.call(defaults) ?? defaults;
      },
      builder: (context, controller, theme, coreTheme) => FlutterMiniGamesScreen(
        title: 'Whack',
        child: GameScreenLayout(
          header: Column(
            spacing: 8,
            children: [
              WhackHeader(controller: controller),
              GameStatsBar(controller: controller),
            ],
          ),
          board: GameBoard(
            padding: EdgeInsets.all(theme.dimens.boardPadding),
            child: GameLoop(
              controller: controller,
              child: GameInputDetector(
                // Starts the round; the holes handle their own taps (several fingers at once)
                onTap: controller.start,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    WhackField(controller: controller),
                    if (controller.isReady) const GameOverlay(title: 'Tap to start', subtitle: 'Tap the critters, skip the spikes'),
                    if (controller.isGameOver) GameOverlay(title: "Time's up!", subtitle: 'Score: ${controller.score}'),
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
              GameHowToPlayItem(icon: Icons.touch_app, text: 'Tap the round critters\nbefore they hide: +1'),
              GameHowToPlayItem(icon: Icons.dangerous_outlined, text: 'Spiky decoys\ncost a point: -1'),
              GameHowToPlayItem(icon: Icons.timer_outlined, text: '30 seconds, they get\nfaster as time runs out'),
            ],
          ),
        ),
      ),
    );
  }
}
