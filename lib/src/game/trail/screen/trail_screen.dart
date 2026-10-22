import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/core/widget/components/button.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_stats_bar.dart';
import 'package:flutter_mini_games/src/core/widget/components/how_to_play.dart';
import 'package:flutter_mini_games/src/core/widget/provider/game_controller_provider.dart';
import 'package:flutter_mini_games/src/core/widget/screen/game_screen_layout.dart';
import 'package:flutter_mini_games/src/core/widget/screen/screen.dart';
import 'package:flutter_mini_games/src/game/trail/game/logic/trail_game_controller.dart';
import 'package:flutter_mini_games/src/game/trail/game/model/trail_difficulty.dart';
import 'package:flutter_mini_games/src/game/trail/game/model/trail_puzzle.dart';
import 'package:flutter_mini_games/src/game/trail/screen/trail_header.dart';
import 'package:flutter_mini_games/src/game/trail/style/trail_theme.dart';
import 'package:flutter_mini_games/src/game/trail/widget/trail_grid.dart';

class TrailScreen extends StatelessWidget {
  final CoreGameTheme? coreTheme;
  final GameThemeOverride<TrailTheme>? theme;
  final List<TrailPuzzle>? puzzles;
  final TrailDifficulty difficulty;

  const TrailScreen({
    required this.difficulty,
    this.coreTheme,
    this.theme,
    this.puzzles,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GameControllerProvider(
      create: () => TrailGameController(
        puzzles: puzzles,
        difficulty: difficulty,
      ),
      coreTheme: coreTheme,
      theme: (core) {
        final defaults = TrailTheme.fromCore(core);
        return theme?.call(defaults) ?? defaults;
      },
      builder: (context, controller, theme, coreTheme) => FlutterMiniGamesScreen(
        title: 'Trail',
        child: GameScreenLayout(
          header: Column(
            spacing: 8,
            children: [
              TrailHeader(controller: controller),
              GameStatsBar(controller: controller),
            ],
          ),
          boardAspectRatio: controller.puzzle.cols / controller.puzzle.rows,
          board: Container(
            decoration: BoxDecoration(
              color: theme.colors.gridBackground,
              borderRadius: BorderRadius.circular(theme.dimens.gridRadius),
              boxShadow: [
                BoxShadow(
                  color: theme.colors.gridShadow.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(8),
            child: TrailGrid(controller: controller),
          ),
          controls: _buildButtons(controller),
          footer: const GameHowToPlay(
            items: [
              GameHowToPlayItem(icon: Icons.swipe, text: 'Pass the checkpoints\nin order'),
              GameHowToPlayItem(icon: Icons.grid_on, text: 'Fill every cell'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtons(TrailGameController controller) {
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
          onTap: controller.canUndo ? controller.undo : null,
          icon: Icons.undo,
          label: 'Undo',
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
