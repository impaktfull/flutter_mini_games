import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/game/flit/game/logic/flit_game_controller.dart';
import 'package:flutter_mini_games/src/game/flit/style/flit_theme.dart';

class FlitHeader extends StatelessWidget {
  final FlitGameController controller;

  const FlitHeader({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FlitTheme.of(context);
    final text = switch (controller) {
      FlitGameController(isReady: true) => 'Get ready',
      FlitGameController(isGameOver: true) => 'Crashed!',
      _ => 'Keep flying',
    };
    return Text(text, textAlign: TextAlign.center, style: theme.textStyles.header);
  }
}
