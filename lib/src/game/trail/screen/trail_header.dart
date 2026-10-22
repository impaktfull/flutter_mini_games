import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/game/trail/game/logic/trail_game_controller.dart';
import 'package:flutter_mini_games/src/game/trail/style/trail_theme.dart';

class TrailHeader extends StatelessWidget {
  final TrailGameController controller;

  const TrailHeader({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = TrailTheme.of(context);

    if (controller.isWon) {
      return Column(
        spacing: 4,
        children: [
          Text(
            '🎉 Puzzle Complete!',
            style: theme.textStyles.headerWin,
          ),
          Text(
            'Every cell filled, every checkpoint visited!',
            style: theme.textStyles.progress,
          ),
        ],
      );
    }

    if (controller.isGameOver) {
      return Column(
        spacing: 4,
        children: [
          Text(
            'No more moves!',
            style: theme.textStyles.headerLose,
          ),
          Text(
            'Undo or reset to try again',
            style: theme.textStyles.progress,
          ),
        ],
      );
    }

    final nextCheckpoint = controller.currentTargetCheckpoint;
    final totalCheckpoints = controller.puzzle.checkpoints.length;
    final filledCells = controller.filledCells;
    final totalCells = controller.totalCells;
    final allCheckpointsVisited = nextCheckpoint > totalCheckpoints;

    return Column(
      spacing: 8,
      children: [
        Text(
          controller.puzzle.name ?? 'Puzzle',
          style: theme.textStyles.header,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 24,
          children: [
            _buildProgressIndicator(
              icon: Icons.flag,
              label: allCheckpointsVisited ? 'End at $totalCheckpoints' : 'Next: $nextCheckpoint',
              current: allCheckpointsVisited ? totalCheckpoints : nextCheckpoint - 1,
              total: totalCheckpoints,
              theme: theme,
            ),
            _buildProgressIndicator(
              icon: Icons.grid_on,
              label: '$filledCells / $totalCells',
              current: filledCells,
              total: totalCells,
              theme: theme,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressIndicator({
    required IconData icon,
    required String label,
    required int current,
    required int total,
    required TrailTheme theme,
  }) {
    final progress = total > 0 ? current / total : 0.0;

    return Row(
      spacing: 4,
      children: [
        Icon(icon, size: 18, color: theme.colors.cellFilled),
        Text(label, style: theme.textStyles.progress),
        const SizedBox(width: 4),
        SizedBox(
          width: 60,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.colors.cellEmpty,
            valueColor: AlwaysStoppedAnimation(theme.colors.cellFilled),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}
