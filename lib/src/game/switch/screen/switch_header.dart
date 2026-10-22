import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/game/switch/game/logic/switch_game_controller.dart';
import 'package:flutter_mini_games/src/game/switch/game/model/switch_difficulty.dart';
import 'package:flutter_mini_games/src/game/switch/style/switch_theme.dart';

class SwitchHeader extends StatelessWidget {
  final SwitchGameController controller;

  const SwitchHeader({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SwitchGameTheme.of(context);
    final name = controller.puzzle.name;
    return Column(
      spacing: 8,
      children: [
        if (controller.hasCustomPuzzles)
          Text(name ?? 'Puzzle', textAlign: TextAlign.center, style: theme.textStyles.header)
        else
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final difficulty in SwitchDifficulty.values) _buildDifficulty(theme, difficulty),
            ],
          ),
        _buildStatus(theme),
      ],
    );
  }

  Widget _buildDifficulty(SwitchGameTheme theme, SwitchDifficulty difficulty) {
    final isSelected = difficulty == controller.difficulty;
    return GestureDetector(
      key: ValueKey('switch_difficulty_${difficulty.name}'),
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

  Widget _buildStatus(SwitchGameTheme theme) {
    if (controller.isWon) {
      final extra = controller.moves - controller.par;
      return Column(
        spacing: 4,
        children: [
          Text('Lights out!', textAlign: TextAlign.center, style: theme.textStyles.header),
          Text(
            'Score ${controller.result?.score ?? 0} · ${extra == 0 ? 'solved at par' : '$extra ${extra == 1 ? 'move' : 'moves'} above par'}',
            textAlign: TextAlign.center,
            style: theme.textStyles.status,
          ),
        ],
      );
    }
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 24,
      runSpacing: 8,
      children: [
        _buildCounter(theme, Icons.lightbulb, '${controller.litCount}', controller.litCount == 1 ? 'light on' : 'lights on'),
        _buildCounter(theme, Icons.flag_outlined, '${controller.par}', 'par'),
      ],
    );
  }

  Widget _buildCounter(SwitchGameTheme theme, IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        Icon(icon, size: 22, color: theme.colors.counter),
        Text(value, style: theme.textStyles.counter),
        Flexible(
          child: Text(label, overflow: TextOverflow.ellipsis, style: theme.textStyles.status),
        ),
      ],
    );
  }
}
