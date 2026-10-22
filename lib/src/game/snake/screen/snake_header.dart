import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/game/snake/game/logic/snake_game_controller.dart';
import 'package:flutter_mini_games/src/game/snake/style/snake_theme.dart';

class SnakeHeader extends StatelessWidget {
  final SnakeGameController controller;

  const SnakeHeader({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SnakeTheme.of(context);
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 24,
      runSpacing: 8,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Icon(Icons.star_rounded, color: theme.colors.score),
            Text('${controller.score}', style: theme.textStyles.score),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Icon(Icons.straighten, size: 18, color: theme.colors.score),
            Text('Length ${controller.snake.length}', style: theme.textStyles.length),
          ],
        ),
      ],
    );
  }
}
