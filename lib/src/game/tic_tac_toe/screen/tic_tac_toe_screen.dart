import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/core/widget/components/button.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_stats_bar.dart';
import 'package:flutter_mini_games/src/core/widget/components/how_to_play.dart';
import 'package:flutter_mini_games/src/core/widget/provider/game_controller_provider.dart';
import 'package:flutter_mini_games/src/core/widget/screen/game_screen_layout.dart';
import 'package:flutter_mini_games/src/core/widget/screen/screen.dart';
import 'package:flutter_mini_games/src/game/tic_tac_toe/game/logic/tic_tac_toe_game_controller.dart';
import 'package:flutter_mini_games/src/game/tic_tac_toe/screen/tic_tac_toe_header.dart';
import 'package:flutter_mini_games/src/game/tic_tac_toe/style/tic_tac_toe_theme.dart';
import 'package:flutter_mini_games/src/game/tic_tac_toe/widget/tic_tac_toe_board.dart';

/// One shared board between the players: the turn banner of [DuelPlayer.top] sits above the
/// board (rotated, that player sits opposite), the banner of [DuelPlayer.bottom] below it.
class TicTacToeScreen extends StatelessWidget {
  final CoreGameTheme? coreTheme;
  final GameThemeOverride<TicTacToeTheme>? theme;

  const TicTacToeScreen({
    this.coreTheme,
    this.theme,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GameControllerProvider(
      create: TicTacToeGameController.new,
      coreTheme: coreTheme,
      theme: (core) {
        final defaults = TicTacToeTheme.fromCore(core);
        return theme?.call(defaults) ?? defaults;
      },
      builder: (context, controller, theme, coreTheme) => FlutterMiniGamesScreen(
        title: 'Tic Tac Toe',
        child: GameScreenLayout(
          header: Column(
            spacing: 8,
            children: [
              TicTacToeHeader(controller: controller, player: DuelPlayer.top),
              GameStatsBar(controller: controller),
            ],
          ),
          board: TicTacToeBoard(controller: controller),
          controls: Column(
            spacing: 8,
            children: [
              TicTacToeHeader(controller: controller, player: DuelPlayer.bottom),
              GameButton(
                onTap: controller.resetGame,
                icon: Icons.refresh,
                label: controller.isGameOver ? 'Play Again' : 'Reset Game',
              ),
            ],
          ),
          footer: const GameHowToPlay(
            items: [
              GameHowToPlayItem(icon: Icons.people_outline, text: 'Player 1 is X and starts,\nPlayer 2 is O'),
              GameHowToPlayItem(icon: Icons.touch_app, text: 'Take turns, tap an\nempty cell'),
              GameHowToPlayItem(icon: Icons.linear_scale, text: 'Get three\nin a row'),
            ],
          ),
        ),
      ),
    );
  }
}
