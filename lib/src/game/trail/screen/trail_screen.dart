import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/core/widget/components/button.dart';
import 'package:flutter_mini_games/src/core/widget/provider/game_controller_provider.dart';
import 'package:flutter_mini_games/src/core/widget/screen/screen.dart';
import 'package:flutter_mini_games/src/game/trail/game/logic/trail_game_controller.dart';
import 'package:flutter_mini_games/src/game/trail/game/model/trail_difficulty.dart';
import 'package:flutter_mini_games/src/game/trail/game/model/trail_puzzle.dart';
import 'package:flutter_mini_games/src/game/trail/screen/trail_header.dart';
import 'package:flutter_mini_games/src/game/trail/style/trail_theme.dart';
import 'package:flutter_mini_games/src/game/trail/widget/trail_grid.dart';

class TrailScreen extends StatelessWidget {
  final TrailTheme Function(CoreGameTheme) themeBuilder;
  final CoreGameTheme coreTheme;
  final List<TrailPuzzle>? puzzles;
  final TrailDifficulty difficulty;

  const TrailScreen({
    required this.themeBuilder,
    required this.coreTheme,
    required this.difficulty,
    this.puzzles,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GameControllerProvider(
      controller: TrailGameController(
        puzzles: puzzles,
        difficulty: difficulty,
      ),
      themeBuilder: themeBuilder,
      coreTheme: coreTheme,
      builder: (context, controller, theme, coreTheme) => FlutterMiniGamesScreen(
        title: 'Trail',
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 24,
          children: [
            TrailHeader(controller: controller),
            Flexible(
              fit: FlexFit.loose,
              child: AspectRatio(
                aspectRatio: controller.puzzle.cols / controller.puzzle.rows,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colors.gridBackground,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colors.shadow.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: TrailGrid(controller: controller),
                ),
              ),
            ),
            _buildButtons(controller),
            _buildHowToPlay(theme),
          ],
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 16,
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

  Widget _buildHowToPlay(TrailTheme theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colors.howToPlayBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text(
            'How to play',
            style: theme.textStyles.header.copyWith(fontSize: 16),
          ),
          Row(
            spacing: 24,
            children: [
              _buildHowToPlayItem(
                icon: Icons.swipe,
                text: 'Pass the checkpoints\nin order',
                theme: theme,
              ),
              _buildHowToPlayItem(
                icon: Icons.grid_on,
                text: 'Fill every cell',
                theme: theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHowToPlayItem({
    required IconData icon,
    required String text,
    required TrailTheme theme,
  }) {
    return Row(
      spacing: 8,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colors.cellFilled.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: theme.colors.cellFilled),
        ),
        Text(
          text,
          style: theme.textStyles.progress.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}
