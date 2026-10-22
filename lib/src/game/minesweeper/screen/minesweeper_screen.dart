import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/core/widget/components/button.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_board.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_stats_bar.dart';
import 'package:flutter_mini_games/src/core/widget/components/how_to_play.dart';
import 'package:flutter_mini_games/src/core/widget/provider/game_controller_provider.dart';
import 'package:flutter_mini_games/src/core/widget/screen/screen.dart';
import 'package:flutter_mini_games/src/game/minesweeper/game/logic/minesweeper_game_controller.dart';
import 'package:flutter_mini_games/src/game/minesweeper/game/model/minesweeper_difficulty.dart';
import 'package:flutter_mini_games/src/game/minesweeper/screen/minesweeper_header.dart';
import 'package:flutter_mini_games/src/game/minesweeper/style/minesweeper_theme.dart';
import 'package:flutter_mini_games/src/game/minesweeper/widget/minesweeper_grid.dart';

class MinesweeperScreen extends StatelessWidget {
  /// Keeps the board a comfortable size on tablets and desktop
  static const maxBoardWidth = 480.0;

  final CoreGameTheme? coreTheme;
  final GameThemeOverride<MinesweeperTheme>? theme;
  final MinesweeperDifficulty difficulty;
  final Random? random;

  const MinesweeperScreen({
    required this.difficulty,
    this.coreTheme,
    this.theme,
    this.random,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GameControllerProvider(
      create: () => MinesweeperGameController(difficulty: difficulty, random: random),
      coreTheme: coreTheme,
      theme: (core) {
        final defaults = MinesweeperTheme.fromCore(core);
        return theme?.call(defaults) ?? defaults;
      },
      builder: (context, controller, theme, coreTheme) => FlutterMiniGamesScreen(
        title: 'Minesweeper',
        padding: EdgeInsets.zero,
        // The board is sized by the width so the cells stay large enough to tap, the rules scroll below it
        child: SingleChildScrollView(
          padding: EdgeInsets.all(coreTheme.dimens.padding),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: maxBoardWidth),
              child: Column(
                spacing: 16,
                children: [
                  MinesweeperHeader(controller: controller),
                  GameStatsBar(controller: controller),
                  GameBoard(
                    aspectRatio: controller.cols / controller.rows,
                    padding: EdgeInsets.all(theme.dimens.boardPadding),
                    child: MinesweeperGrid(controller: controller),
                  ),
                  _buildButtons(controller),
                  const GameHowToPlay(
                    items: [
                      GameHowToPlayItem(icon: Icons.touch_app, text: 'Tap to reveal'),
                      GameHowToPlayItem(icon: Icons.flag, text: 'Long press to flag'),
                      GameHowToPlayItem(icon: Icons.looks_one_outlined, text: 'Numbers count the\nmines around a cell'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtons(MinesweeperGameController controller) {
    if (controller.isFinished) {
      return GameButton(
        onTap: controller.resetGame,
        icon: Icons.replay,
        label: 'New game',
      );
    }
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: [
        GameButton(
          onTap: controller.toggleFlagMode,
          icon: controller.isFlagMode ? Icons.flag : Icons.outlined_flag,
          label: controller.isFlagMode ? 'Flag: on' : 'Flag: off',
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
