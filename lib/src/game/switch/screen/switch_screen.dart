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
import 'package:flutter_mini_games/src/game/switch/game/logic/switch_game_controller.dart';
import 'package:flutter_mini_games/src/game/switch/game/model/switch_difficulty.dart';
import 'package:flutter_mini_games/src/game/switch/game/model/switch_puzzle.dart';
import 'package:flutter_mini_games/src/game/switch/screen/switch_header.dart';
import 'package:flutter_mini_games/src/game/switch/style/switch_theme.dart';
import 'package:flutter_mini_games/src/game/switch/widget/switch_grid.dart';

class SwitchScreen extends StatelessWidget {
  final CoreGameTheme? coreTheme;
  final GameThemeOverride<SwitchGameTheme>? theme;
  final SwitchDifficulty difficulty;
  final List<SwitchPuzzle>? puzzles;
  final Random? random;

  const SwitchScreen({
    required this.difficulty,
    this.coreTheme,
    this.theme,
    this.puzzles,
    this.random,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GameControllerProvider(
      create: () => SwitchGameController(difficulty: difficulty, puzzles: puzzles, random: random),
      coreTheme: coreTheme,
      theme: (core) {
        final defaults = SwitchGameTheme.fromCore(core);
        return theme?.call(defaults) ?? defaults;
      },
      builder: (context, controller, theme, coreTheme) => FlutterMiniGamesScreen(
        title: 'Switch',
        child: GameScreenLayout(
          header: Column(
            spacing: 8,
            children: [
              SwitchHeader(controller: controller),
              GameStatsBar(controller: controller),
            ],
          ),
          board: GameBoard(
            padding: EdgeInsets.all(theme.dimens.boardPadding),
            child: SwitchGrid(controller: controller),
          ),
          controls: _buildButtons(controller),
          footer: const GameHowToPlay(
            items: [
              GameHowToPlayItem(icon: Icons.touch_app, text: 'Tap a light to switch it\nand its 4 neighbours'),
              GameHowToPlayItem(icon: Icons.lightbulb_outline, text: 'Turn off all the lights'),
              GameHowToPlayItem(icon: Icons.flag_outlined, text: 'Match par for\nthe best score'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtons(SwitchGameController controller) {
    if (controller.isWon) {
      return GameButton(
        onTap: controller.nextPuzzle,
        icon: Icons.arrow_forward,
        label: 'Next Puzzle',
      );
    }
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: [
        GameButton(
          onTap: controller.showHint,
          icon: Icons.tips_and_updates_outlined,
          label: 'Hint',
        ),
        GameButton(
          onTap: controller.resetGame,
          icon: Icons.refresh,
          label: 'Reset',
        ),
      ],
    );
  }
}
