import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/core/widget/components/button.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_stats_bar.dart';
import 'package:flutter_mini_games/src/core/widget/components/how_to_play.dart';
import 'package:flutter_mini_games/src/core/widget/provider/game_controller_provider.dart';
import 'package:flutter_mini_games/src/core/widget/screen/game_screen_layout.dart';
import 'package:flutter_mini_games/src/core/widget/screen/screen.dart';
import 'package:flutter_mini_games/src/game/breaker/game/logic/breaker_game_controller.dart';
import 'package:flutter_mini_games/src/game/breaker/screen/breaker_header.dart';
import 'package:flutter_mini_games/src/game/breaker/style/breaker_theme.dart';
import 'package:flutter_mini_games/src/game/breaker/widget/breaker_playfield.dart';

class BreakerScreen extends StatelessWidget {
  final CoreGameTheme? coreTheme;
  final GameThemeOverride<BreakerTheme>? theme;

  const BreakerScreen({
    this.coreTheme,
    this.theme,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GameControllerProvider(
      create: BreakerGameController.new,
      coreTheme: coreTheme,
      theme: (core) {
        final defaults = BreakerTheme.fromCore(core);
        return theme?.call(defaults) ?? defaults;
      },
      builder: (context, controller, theme, coreTheme) => FlutterMiniGamesScreen(
        title: 'Breaker',
        child: GameScreenLayout(
          header: Column(
            spacing: 8,
            children: [
              BreakerHeader(controller: controller),
              GameStatsBar(controller: controller),
            ],
          ),
          boardAspectRatio: BreakerPlayfield.aspectRatio,
          board: BreakerPlayfield(controller: controller),
          controls: controller.isFinished
              ? GameButton(onTap: controller.resetGame, icon: Icons.replay, label: 'Play again')
              : GameButton(onTap: controller.isReady ? null : controller.resetGame, icon: Icons.refresh, label: 'Restart'),
          footer: const GameHowToPlay(
            items: [
              GameHowToPlayItem(icon: Icons.swipe, text: 'Drag or hold left / right\nto move the paddle'),
              GameHowToPlayItem(icon: Icons.touch_app, text: 'Tap to launch the ball'),
              GameHowToPlayItem(icon: Icons.grid_view_rounded, text: 'Break all bricks,\nevery level adds a row'),
            ],
          ),
        ),
      ),
    );
  }
}
