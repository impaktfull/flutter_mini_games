import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/core/widget/components/button.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_stats_bar.dart';
import 'package:flutter_mini_games/src/core/widget/components/how_to_play.dart';
import 'package:flutter_mini_games/src/core/widget/provider/game_controller_provider.dart';
import 'package:flutter_mini_games/src/core/widget/screen/game_screen_layout.dart';
import 'package:flutter_mini_games/src/core/widget/screen/screen.dart';
import 'package:flutter_mini_games/src/game/boxes/game/logic/boxes_game_controller.dart';
import 'package:flutter_mini_games/src/game/boxes/screen/boxes_header.dart';
import 'package:flutter_mini_games/src/game/boxes/style/boxes_theme.dart';
import 'package:flutter_mini_games/src/game/boxes/widget/boxes_board.dart';

class BoxesScreen extends StatelessWidget {
  final CoreGameTheme? coreTheme;
  final GameThemeOverride<BoxesTheme>? theme;

  const BoxesScreen({
    this.coreTheme,
    this.theme,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GameControllerProvider(
      create: BoxesGameController.new,
      coreTheme: coreTheme,
      theme: (core) {
        final defaults = BoxesTheme.fromCore(core);
        return theme?.call(defaults) ?? defaults;
      },
      builder: (context, controller, theme, coreTheme) => FlutterMiniGamesScreen(
        title: 'Boxes',
        child: GameScreenLayout(
          // Player 2 sits opposite: their banner is rotated, Player 1's banner is below the board
          header: Column(
            spacing: 8,
            children: [
              RotatedBox(
                quarterTurns: 2,
                child: BoxesHeader(controller: controller, player: DuelPlayer.top),
              ),
              GameStatsBar(controller: controller),
            ],
          ),
          board: BoxesBoard(controller: controller),
          controls: Column(
            spacing: 8,
            children: [
              BoxesHeader(controller: controller, player: DuelPlayer.bottom),
              GameButton(
                onTap: controller.resetGame,
                icon: Icons.refresh,
                label: controller.isGameOver ? 'Play Again' : 'Reset Game',
              ),
            ],
          ),
          footer: const GameHowToPlay(
            items: [
              GameHowToPlayItem(icon: Icons.touch_app, text: 'Tap between two\ndots to draw a line'),
              GameHowToPlayItem(icon: Icons.crop_square, text: 'Close the fourth side\nto claim a box'),
              GameHowToPlayItem(icon: Icons.replay, text: 'A claimed box gives\nyou another turn'),
              GameHowToPlayItem(icon: Icons.emoji_events_outlined, text: 'Most boxes wins'),
            ],
          ),
        ),
      ),
    );
  }
}
