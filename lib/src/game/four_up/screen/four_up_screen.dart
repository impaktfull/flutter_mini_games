import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/core/widget/components/button.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_stats_bar.dart';
import 'package:flutter_mini_games/src/core/widget/components/how_to_play.dart';
import 'package:flutter_mini_games/src/core/widget/provider/game_controller_provider.dart';
import 'package:flutter_mini_games/src/core/widget/screen/game_screen_layout.dart';
import 'package:flutter_mini_games/src/core/widget/screen/screen.dart';
import 'package:flutter_mini_games/src/game/four_up/game/logic/four_up_game_controller.dart';
import 'package:flutter_mini_games/src/game/four_up/screen/four_up_header.dart';
import 'package:flutter_mini_games/src/game/four_up/style/four_up_theme.dart';
import 'package:flutter_mini_games/src/game/four_up/widget/four_up_board.dart';

/// One shared board between the players: the turn banner of [DuelPlayer.top] sits above the
/// board (rotated, that player sits opposite), the banner of [DuelPlayer.bottom] below it.
class FourUpScreen extends StatelessWidget {
  final CoreGameTheme? coreTheme;
  final GameThemeOverride<FourUpTheme>? theme;

  const FourUpScreen({
    this.coreTheme,
    this.theme,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GameControllerProvider(
      create: FourUpGameController.new,
      coreTheme: coreTheme,
      theme: (core) {
        final defaults = FourUpTheme.fromCore(core);
        return theme?.call(defaults) ?? defaults;
      },
      builder: (context, controller, theme, coreTheme) => FlutterMiniGamesScreen(
        title: 'Four Up',
        child: GameScreenLayout(
          header: FourUpHeader(controller: controller, player: DuelPlayer.top),
          boardAspectRatio: FourUpBoard.aspectRatio,
          board: FourUpBoard(controller: controller),
          controls: Column(
            spacing: 8,
            children: [
              FourUpHeader(controller: controller, player: DuelPlayer.bottom),
              // Stats next to the button instead of in the header: the wide board keeps its
              // full width on small phones
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 16,
                children: [
                  Flexible(child: GameStatsBar(controller: controller)),
                  GameButton(
                    onTap: controller.resetGame,
                    icon: Icons.refresh,
                    label: controller.isGameOver ? 'Play Again' : 'Reset',
                  ),
                ],
              ),
            ],
          ),
          footer: const GameHowToPlay(
            items: [
              GameHowToPlayItem(icon: Icons.touch_app, text: 'Take turns, tap a column\nto drop your disc'),
              GameHowToPlayItem(icon: Icons.linear_scale, text: 'Get four in a row: across,\ndown or diagonally'),
              GameHowToPlayItem(icon: Icons.keyboard, text: 'Keyboard: arrow left/right\nto pick, down/space to drop'),
            ],
          ),
        ),
      ),
    );
  }
}
