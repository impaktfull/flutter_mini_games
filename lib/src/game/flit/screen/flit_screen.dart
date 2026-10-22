import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/core/widget/components/button.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_stats_bar.dart';
import 'package:flutter_mini_games/src/core/widget/components/how_to_play.dart';
import 'package:flutter_mini_games/src/core/widget/provider/game_controller_provider.dart';
import 'package:flutter_mini_games/src/core/widget/screen/screen.dart';
import 'package:flutter_mini_games/src/game/flit/game/logic/flit_game_controller.dart';
import 'package:flutter_mini_games/src/game/flit/screen/flit_header.dart';
import 'package:flutter_mini_games/src/game/flit/style/flit_theme.dart';
import 'package:flutter_mini_games/src/game/flit/widget/flit_board.dart';

class FlitScreen extends StatelessWidget {
  final CoreGameTheme? coreTheme;
  final GameThemeOverride<FlitTheme>? theme;

  const FlitScreen({
    this.coreTheme,
    this.theme,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GameControllerProvider(
      create: FlitGameController.new,
      coreTheme: coreTheme,
      theme: (core) {
        final defaults = FlitTheme.fromCore(core);
        return theme?.call(defaults) ?? defaults;
      },
      builder: (context, controller, theme, coreTheme) => FlutterMiniGamesScreen(
        title: 'Flit',
        child: Column(
          spacing: 12,
          children: [
            FlitHeader(controller: controller),
            GameStatsBar(controller: controller),
            Expanded(child: FlitBoard(controller: controller)),
            GameButton(
              onTap: controller.isReady ? null : controller.resetGame,
              icon: Icons.refresh,
              label: controller.isGameOver ? 'Play again' : 'Restart',
            ),
            const GameHowToPlay(
              items: [
                GameHowToPlayItem(icon: Icons.touch_app, text: 'Tap to flap'),
                GameHowToPlayItem(icon: Icons.view_column, text: 'Fly through the gaps'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
