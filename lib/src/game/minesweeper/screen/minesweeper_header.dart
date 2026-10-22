import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/game/minesweeper/game/logic/minesweeper_game_controller.dart';
import 'package:flutter_mini_games/src/game/minesweeper/game/model/minesweeper_difficulty.dart';
import 'package:flutter_mini_games/src/game/minesweeper/style/minesweeper_theme.dart';

class MinesweeperHeader extends StatelessWidget {
  final MinesweeperGameController controller;

  const MinesweeperHeader({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = MinesweeperTheme.of(context);
    return Column(
      spacing: 8,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final difficulty in MinesweeperDifficulty.values) _buildDifficulty(theme, difficulty),
          ],
        ),
        _buildStatus(theme),
      ],
    );
  }

  Widget _buildDifficulty(MinesweeperTheme theme, MinesweeperDifficulty difficulty) {
    final isSelected = difficulty == controller.difficulty;
    return GestureDetector(
      onTap: isSelected ? null : () => controller.newGame(difficulty: difficulty),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? theme.colors.difficultySelected : theme.colors.difficulty,
          borderRadius: BorderRadius.circular(theme.dimens.difficultyRadius),
        ),
        child: Text(
          difficulty.label,
          style: theme.textStyles.difficulty.copyWith(
            color: isSelected ? theme.colors.onDifficultySelected : theme.colors.onDifficulty,
          ),
        ),
      ),
    );
  }

  Widget _buildStatus(MinesweeperTheme theme) {
    if (controller.isWon) {
      return Text(
        'Cleared! Score: ${controller.result?.score ?? 0}',
        textAlign: TextAlign.center,
        style: theme.textStyles.header,
      );
    }
    if (controller.isLost) {
      return Text('Boom! Game over', textAlign: TextAlign.center, style: theme.textStyles.header);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        Icon(Icons.flag, size: 22, color: theme.colors.counter),
        Text('${controller.remainingMines}', style: theme.textStyles.header),
        Flexible(
          child: Text(
            controller.remainingMines == 1 ? 'mine left' : 'mines left',
            overflow: TextOverflow.ellipsis,
            style: theme.textStyles.status,
          ),
        ),
      ],
    );
  }
}
