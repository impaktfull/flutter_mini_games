import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/game/stack/game/logic/stack_game_controller.dart';
import 'package:flutter_mini_games/src/game/stack/style/stack_theme.dart';

class StackHeader extends StatelessWidget {
  final StackGameController controller;

  const StackHeader({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = StackTheme.of(context);
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 4,
      children: [
        Text('Score: ${controller.score}', style: theme.textStyles.score),
        _buildStatus(theme),
      ],
    );
  }

  Widget _buildStatus(StackTheme theme) {
    if (controller.isGameOver) {
      return Text('Tower of ${controller.placedBlocks} blocks', style: theme.textStyles.status);
    }
    if (controller.lastDropWasPerfect) {
      final streak = controller.streak;
      return Text(streak > 1 ? 'Perfect! x$streak' : 'Perfect!', style: theme.textStyles.perfect);
    }
    return Text('${controller.placedBlocks} blocks', style: theme.textStyles.status);
  }
}
