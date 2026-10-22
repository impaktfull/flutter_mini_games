import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/core/widget/components/button.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_stats_bar.dart';
import 'package:flutter_mini_games/src/core/widget/components/how_to_play.dart';
import 'package:flutter_mini_games/src/core/widget/provider/game_controller_provider.dart';
import 'package:flutter_mini_games/src/core/widget/screen/screen.dart';
import 'package:flutter_mini_games/src/game/twenty_forty_eight/game/logic/twenty_forty_eight_game_controller.dart';
import 'package:flutter_mini_games/src/game/twenty_forty_eight/screen/twenty_forty_eight_header.dart';
import 'package:flutter_mini_games/src/game/twenty_forty_eight/style/twenty_forty_eight_theme.dart';
import 'package:flutter_mini_games/src/game/twenty_forty_eight/widget/twenty_forty_eight_board.dart';

class TwentyFortyEightScreen extends StatelessWidget {
  final CoreGameTheme? coreTheme;
  final GameThemeOverride<TwentyFortyEightTheme>? theme;

  const TwentyFortyEightScreen({
    this.coreTheme,
    this.theme,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GameControllerProvider(
      create: TwentyFortyEightGameController.new,
      coreTheme: coreTheme,
      theme: (core) {
        final defaults = TwentyFortyEightTheme.fromCore(core);
        return theme?.call(defaults) ?? defaults;
      },
      builder: (context, controller, theme, coreTheme) => FlutterMiniGamesScreen(
        title: '2048',
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 24,
          children: [
            TwentyFortyEightHeader(controller: controller),
            GameStatsBar(controller: controller),
            Flexible(
              fit: FlexFit.loose,
              child: TwentyFortyEightBoard(controller: controller),
            ),
            GameButton(
              onTap: controller.resetGame,
              icon: controller.isFinished ? Icons.replay : Icons.refresh,
              label: controller.isFinished ? 'New game' : 'Restart',
            ),
            const GameHowToPlay(
              items: [
                GameHowToPlayItem(icon: Icons.swipe, text: 'Swipe to slide\nall tiles'),
                GameHowToPlayItem(icon: Icons.merge, text: 'Merge equal tiles\nto reach 2048'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
