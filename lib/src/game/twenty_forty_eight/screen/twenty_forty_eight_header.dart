import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/game/twenty_forty_eight/game/logic/twenty_forty_eight_game_controller.dart';
import 'package:flutter_mini_games/src/game/twenty_forty_eight/style/twenty_forty_eight_theme.dart';

class TwentyFortyEightHeader extends StatelessWidget {
  final TwentyFortyEightGameController controller;

  const TwentyFortyEightHeader({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = TwentyFortyEightTheme.of(context);
    final title = switch (controller) {
      _ when controller.isWon => '🎉 You win!',
      _ when controller.isGameOver => 'Game over',
      _ => 'Reach ${TwentyFortyEightGameController.winValue}',
    };
    return Column(
      spacing: 4,
      children: [
        Text(title, textAlign: TextAlign.center, style: theme.textStyles.header),
        Text('Score: ${controller.score}', textAlign: TextAlign.center, style: theme.textStyles.score),
      ],
    );
  }
}
