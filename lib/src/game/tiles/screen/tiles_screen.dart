import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/core/widget/components/button.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_stats_bar.dart';
import 'package:flutter_mini_games/src/core/widget/components/how_to_play.dart';
import 'package:flutter_mini_games/src/core/widget/provider/game_controller_provider.dart';
import 'package:flutter_mini_games/src/core/widget/screen/game_screen_layout.dart';
import 'package:flutter_mini_games/src/core/widget/screen/screen.dart';
import 'package:flutter_mini_games/src/game/tiles/game/logic/tiles_game_controller.dart';
import 'package:flutter_mini_games/src/game/tiles/screen/tiles_header.dart';
import 'package:flutter_mini_games/src/game/tiles/style/tiles_theme.dart';
import 'package:flutter_mini_games/src/game/tiles/widget/tiles_board.dart';

class TilesScreen extends StatelessWidget {
  final CoreGameTheme? coreTheme;
  final GameThemeOverride<TilesTheme>? theme;

  const TilesScreen({
    this.coreTheme,
    this.theme,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GameControllerProvider(
      create: TilesGameController.new,
      coreTheme: coreTheme,
      theme: (core) {
        final defaults = TilesTheme.fromCore(core);
        return theme?.call(defaults) ?? defaults;
      },
      builder: (context, controller, theme, coreTheme) => FlutterMiniGamesScreen(
        title: 'Tiles',
        child: GameScreenLayout(
          header: Column(
            spacing: 8,
            children: [
              TilesHeader(controller: controller),
              GameStatsBar(controller: controller),
            ],
          ),
          boardAspectRatio: TilesGameController.boardAspectRatio,
          board: TilesBoard(controller: controller),
          controls: GameButton(
            onTap: controller.isReady ? null : controller.resetGame,
            icon: controller.isGameOver ? Icons.replay : Icons.refresh,
            label: controller.isGameOver ? 'Play again' : 'Restart',
          ),
          footer: const GameHowToPlay(
            items: [
              GameHowToPlayItem(icon: Icons.touch_app, text: 'Tap the dark tile in every\nrow, the lowest one first'),
              GameHowToPlayItem(icon: Icons.block, text: 'Tapping a light tile\nends the game'),
              GameHowToPlayItem(icon: Icons.speed, text: "Don't let a dark tile pass,\nthe rows get faster"),
            ],
          ),
        ),
      ),
    );
  }
}
