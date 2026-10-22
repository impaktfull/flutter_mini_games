import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/core/widget/components/button.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_board.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_stats_bar.dart';
import 'package:flutter_mini_games/src/core/widget/components/how_to_play.dart';
import 'package:flutter_mini_games/src/core/widget/provider/game_controller_provider.dart';
import 'package:flutter_mini_games/src/core/widget/screen/game_screen_layout.dart';
import 'package:flutter_mini_games/src/core/widget/screen/screen.dart';
import 'package:flutter_mini_games/src/game/pairs/game/logic/pairs_game_controller.dart';
import 'package:flutter_mini_games/src/game/pairs/game/model/pairs_difficulty.dart';
import 'package:flutter_mini_games/src/game/pairs/screen/pairs_header.dart';
import 'package:flutter_mini_games/src/game/pairs/style/pairs_theme.dart';
import 'package:flutter_mini_games/src/game/pairs/widget/pairs_grid.dart';

class PairsScreen extends StatelessWidget {
  final CoreGameTheme? coreTheme;
  final GameThemeOverride<PairsTheme>? theme;
  final PairsDifficulty difficulty;
  final Random? random;

  const PairsScreen({
    required this.difficulty,
    this.coreTheme,
    this.theme,
    this.random,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GameControllerProvider(
      create: () => PairsGameController(difficulty: difficulty, random: random),
      coreTheme: coreTheme,
      theme: (core) {
        final defaults = PairsTheme.fromCore(core);
        return theme?.call(defaults) ?? defaults;
      },
      builder: (context, controller, theme, coreTheme) => FlutterMiniGamesScreen(
        title: 'Pairs',
        child: GameScreenLayout(
          header: Column(
            spacing: 8,
            children: [
              PairsHeader(controller: controller),
              GameStatsBar(controller: controller),
            ],
          ),
          boardAspectRatio: controller.cols / controller.rows,
          board: GameBoard(
            aspectRatio: controller.cols / controller.rows,
            padding: EdgeInsets.all(theme.dimens.boardPadding),
            child: PairsGrid(controller: controller),
          ),
          controls: controller.isWon
              ? GameButton(onTap: controller.resetGame, icon: Icons.replay, label: 'Play again')
              : GameButton(onTap: controller.resetGame, icon: Icons.refresh, label: 'Reset'),
          footer: const GameHowToPlay(
            items: [
              GameHowToPlayItem(icon: Icons.touch_app, text: 'Tap a card to flip it'),
              GameHowToPlayItem(icon: Icons.style, text: 'Find all matching\npairs of icons'),
              GameHowToPlayItem(icon: Icons.timer_outlined, text: 'Fewer moves and less\ntime score more'),
            ],
          ),
        ),
      ),
    );
  }
}
