import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/game/echo/game/logic/echo_game_controller.dart';
import 'package:flutter_mini_games/src/game/echo/style/echo_theme.dart';

class EchoHeader extends StatelessWidget {
  final EchoGameController controller;

  const EchoHeader({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = EchoTheme.of(context);
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

  Widget _buildStatus(EchoTheme theme) {
    return switch (controller.phase) {
      EchoPhase.ready => Text('Watch, then repeat', style: theme.textStyles.status),
      EchoPhase.playback => Text('Watch… (${controller.sequence.length})', style: theme.textStyles.status),
      EchoPhase.input => Text('Your turn ${controller.inputIndex}/${controller.sequence.length}', style: theme.textStyles.yourTurn),
      EchoPhase.gameOver => Text('Wrong pad', style: theme.textStyles.status),
    };
  }
}
