import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/game/pairs/game/logic/pairs_game_controller.dart';
import 'package:flutter_mini_games/src/game/pairs/game/model/pairs_difficulty.dart';
import 'package:flutter_mini_games/src/game/pairs/style/pairs_theme.dart';

class PairsHeader extends StatelessWidget {
  final PairsGameController controller;

  const PairsHeader({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = PairsTheme.of(context);
    return Column(
      spacing: 8,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final difficulty in PairsDifficulty.values) _buildDifficulty(theme, difficulty),
          ],
        ),
        _buildStatus(theme),
      ],
    );
  }

  Widget _buildDifficulty(PairsTheme theme, PairsDifficulty difficulty) {
    final isSelected = difficulty == controller.difficulty;
    return GestureDetector(
      key: ValueKey('pairs_difficulty_${difficulty.name}'),
      onTap: isSelected ? null : () => controller.newGame(difficulty: difficulty),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? theme.colors.difficultySelected : theme.colors.difficulty,
          borderRadius: BorderRadius.circular(theme.dimens.difficultyRadius),
        ),
        child: Text(
          '${difficulty.label} ${difficulty.cols}x${difficulty.rows}',
          style: theme.textStyles.difficulty.copyWith(
            color: isSelected ? theme.colors.onDifficultySelected : theme.colors.onDifficulty,
          ),
        ),
      ),
    );
  }

  Widget _buildStatus(PairsTheme theme) {
    if (controller.isWon) {
      return Column(
        spacing: 2,
        children: [
          Text('All pairs found!', textAlign: TextAlign.center, style: theme.textStyles.header),
          Text('Score: ${controller.result?.score ?? 0}', textAlign: TextAlign.center, style: theme.textStyles.status),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        Icon(Icons.style, size: 22, color: theme.colors.progress),
        Text('${controller.pairsFound} / ${controller.totalPairs}', style: theme.textStyles.header),
        Flexible(
          child: Text('pairs found', overflow: TextOverflow.ellipsis, style: theme.textStyles.status),
        ),
      ],
    );
  }
}
