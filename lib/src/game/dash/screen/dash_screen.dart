import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/core/widget/components/button.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_stats_bar.dart';
import 'package:flutter_mini_games/src/core/widget/components/how_to_play.dart';
import 'package:flutter_mini_games/src/core/widget/provider/game_controller_provider.dart';
import 'package:flutter_mini_games/src/core/widget/screen/screen.dart';
import 'package:flutter_mini_games/src/game/dash/game/logic/dash_game_controller.dart';
import 'package:flutter_mini_games/src/game/dash/screen/dash_header.dart';
import 'package:flutter_mini_games/src/game/dash/style/dash_theme.dart';
import 'package:flutter_mini_games/src/game/dash/widget/dash_field.dart';

class DashScreen extends StatelessWidget {
  final CoreGameTheme? coreTheme;
  final GameThemeOverride<DashTheme>? theme;

  const DashScreen({
    this.coreTheme,
    this.theme,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GameControllerProvider(
      create: DashGameController.new,
      coreTheme: coreTheme,
      theme: (core) {
        final defaults = DashTheme.fromCore(core);
        return theme?.call(defaults) ?? defaults;
      },
      builder: (context, controller, theme, coreTheme) => FlutterMiniGamesScreen(
        title: 'Dash',
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 24,
          children: [
            DashHeader(controller: controller),
            GameStatsBar(controller: controller),
            Flexible(child: DashField(controller: controller)),
            if (controller.isFinished)
              GameButton(onTap: controller.resetGame, icon: Icons.replay, label: 'Play again')
            else
              GameButton(onTap: controller.isRunning ? controller.resetGame : null, icon: Icons.refresh, label: 'Restart'),
            const GameHowToPlay(
              items: [
                GameHowToPlayItem(icon: Icons.touch_app, text: 'Tap, space or up\nto jump'),
                GameHowToPlayItem(icon: Icons.swipe_down, text: 'Swipe down to duck\nor drop faster'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
