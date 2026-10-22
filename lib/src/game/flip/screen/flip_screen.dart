import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/core/widget/components/button.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_board.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_stats_bar.dart';
import 'package:flutter_mini_games/src/core/widget/components/how_to_play.dart';
import 'package:flutter_mini_games/src/core/widget/provider/game_controller_provider.dart';
import 'package:flutter_mini_games/src/core/widget/screen/game_screen_layout.dart';
import 'package:flutter_mini_games/src/core/widget/screen/screen.dart';
import 'package:flutter_mini_games/src/game/flip/game/logic/flip_game_controller.dart';
import 'package:flutter_mini_games/src/game/flip/screen/flip_header.dart';
import 'package:flutter_mini_games/src/game/flip/style/flip_theme.dart';
import 'package:flutter_mini_games/src/game/flip/widget/flip_board.dart';

class FlipScreen extends StatelessWidget {
  final CoreGameTheme? coreTheme;
  final GameThemeOverride<FlipTheme>? theme;

  const FlipScreen({
    this.coreTheme,
    this.theme,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GameControllerProvider(
      create: FlipGameController.new,
      coreTheme: coreTheme,
      theme: (core) {
        final defaults = FlipTheme.fromCore(core);
        return theme?.call(defaults) ?? defaults;
      },
      builder: (context, controller, theme, coreTheme) => FlutterMiniGamesScreen(
        title: 'Flip',
        child: GameScreenLayout(
          header: Column(
            spacing: 8,
            children: [
              // Player 2 sits opposite: their banner is rotated towards them
              RotatedBox(
                quarterTurns: 2,
                child: FlipHeader(controller: controller, player: DuelPlayer.top),
              ),
              GameStatsBar(controller: controller),
            ],
          ),
          board: GameBoard(
            padding: EdgeInsets.all(theme.dimens.boardPadding),
            child: FlipBoard(controller: controller),
          ),
          controls: Column(
            spacing: 8,
            children: [
              FlipHeader(controller: controller, player: DuelPlayer.bottom),
              GameButton(
                onTap: controller.resetGame,
                icon: Icons.refresh,
                label: controller.isGameOver ? 'Play Again' : 'Reset',
              ),
            ],
          ),
          footer: const GameHowToPlay(
            items: [
              GameHowToPlayItem(icon: Icons.touch_app, text: 'Tap a hinted cell\nto place a disc'),
              GameHowToPlayItem(icon: Icons.swap_horiz, text: 'Outflank lines of\nopponent discs to flip them'),
              GameHowToPlayItem(icon: Icons.skip_next, text: 'No legal move?\nYour turn is passed'),
              GameHowToPlayItem(icon: Icons.emoji_events_outlined, text: 'Most discs wins\nwhen nobody can move'),
            ],
          ),
        ),
      ),
    );
  }
}
