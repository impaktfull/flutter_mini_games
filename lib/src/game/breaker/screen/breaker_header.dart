import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/game/breaker/game/logic/breaker_game_controller.dart';
import 'package:flutter_mini_games/src/game/breaker/style/breaker_theme.dart';

/// Score, level and the remaining lives
class BreakerHeader extends StatelessWidget {
  final BreakerGameController controller;

  const BreakerHeader({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = BreakerTheme.of(context);
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
        Text('Level ${controller.level} / ${BreakerGameController.maxLevel}', style: theme.textStyles.label),
        Semantics(
          label: '${controller.lives} lives left',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 2,
            children: [
              for (var i = 0; i < BreakerGameController.startLives; i++)
                i < controller.lives
                    ? Icon(Icons.favorite_rounded, size: 20, color: theme.colors.lives)
                    : Icon(Icons.favorite_border_rounded, size: 20, color: theme.colors.livesLost),
            ],
          ),
        ),
      ],
    );
  }
}
