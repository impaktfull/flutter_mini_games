import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/game/dash/game/logic/dash_game_controller.dart';
import 'package:flutter_mini_games/src/game/dash/style/dash_theme.dart';

class DashHeader extends StatelessWidget {
  final DashGameController controller;

  const DashHeader({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = DashTheme.of(context);
    final status = switch (controller) {
      DashGameController(isReady: true) => 'Run as far as you can',
      DashGameController(isGameOver: true) => 'Game over',
      _ => 'Speed ${(controller.speed / DashGameController.initialSpeed).toStringAsFixed(1)}x',
    };
    return Column(
      spacing: 4,
      children: [
        Text('${controller.score}', style: theme.textStyles.score),
        Text(status, textAlign: TextAlign.center, style: theme.textStyles.status),
      ],
    );
  }
}
