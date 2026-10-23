import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/game/hop/game/logic/hop_game_controller.dart';
import 'package:flutter_mini_games/src/game/hop/style/hop_theme.dart';

class HopHeader extends StatelessWidget {
  final HopGameController controller;

  const HopHeader({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = HopTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The score changes every frame: only this text rebuilds and repaints
        RepaintBoundary(
          child: ListenableBuilder(
            listenable: controller.frame,
            builder: (context, child) => Text('${controller.score}', style: theme.textStyles.score),
          ),
        ),
        Text(controller.isGameOver ? 'Final height' : 'Height', style: theme.textStyles.scoreLabel),
      ],
    );
  }
}
