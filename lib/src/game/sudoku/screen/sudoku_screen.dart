import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/core/widget/components/button.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_board.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_stats_bar.dart';
import 'package:flutter_mini_games/src/core/widget/components/how_to_play.dart';
import 'package:flutter_mini_games/src/core/widget/provider/game_controller_provider.dart';
import 'package:flutter_mini_games/src/core/widget/screen/game_screen_layout.dart';
import 'package:flutter_mini_games/src/core/widget/screen/screen.dart';
import 'package:flutter_mini_games/src/game/sudoku/game/logic/sudoku_game_controller.dart';
import 'package:flutter_mini_games/src/game/sudoku/game/model/sudoku_difficulty.dart';
import 'package:flutter_mini_games/src/game/sudoku/game/model/sudoku_puzzle.dart';
import 'package:flutter_mini_games/src/game/sudoku/screen/sudoku_header.dart';
import 'package:flutter_mini_games/src/game/sudoku/style/sudoku_theme.dart';
import 'package:flutter_mini_games/src/game/sudoku/widget/sudoku_board.dart';
import 'package:flutter_mini_games/src/game/sudoku/widget/sudoku_number_pad.dart';

class SudokuScreen extends StatelessWidget {
  final CoreGameTheme? coreTheme;
  final GameThemeOverride<SudokuTheme>? theme;
  final List<SudokuPuzzle>? puzzles;
  final SudokuDifficulty difficulty;

  const SudokuScreen({
    required this.difficulty,
    this.coreTheme,
    this.theme,
    this.puzzles,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GameControllerProvider(
      create: () => SudokuGameController(
        puzzles: puzzles,
        difficulty: difficulty,
      ),
      coreTheme: coreTheme,
      theme: (core) {
        final defaults = SudokuTheme.fromCore(core);
        return theme?.call(defaults) ?? defaults;
      },
      builder: (context, controller, theme, coreTheme) => FlutterMiniGamesScreen(
        title: 'Sudoku',
        child: GameScreenLayout(
          header: Column(
            spacing: 8,
            children: [
              SudokuHeader(controller: controller),
              GameStatsBar(controller: controller),
            ],
          ),
          board: GameBoard(
            padding: EdgeInsets.all(theme.dimens.boardPadding),
            child: SudokuBoard(controller: controller),
          ),
          controls: SudokuNumberPad(
            controller: controller,
            trailing: controller.isWon
                ? GameButton(
                    onTap: controller.nextPuzzle,
                    icon: Icons.arrow_forward,
                    label: 'Next Puzzle',
                  )
                : GameButton(
                    onTap: controller.resetGame,
                    icon: Icons.refresh,
                    label: 'Reset',
                  ),
          ),
          footer: const GameHowToPlay(
            items: [
              GameHowToPlayItem(icon: Icons.grid_3x3, text: 'Fill every row, column\nand box with 1-9'),
              GameHowToPlayItem(icon: Icons.touch_app, text: 'Tap a cell,\nthen a number'),
            ],
          ),
        ),
      ),
    );
  }
}
