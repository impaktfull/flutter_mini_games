import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_board.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_overlay.dart';
import 'package:flutter_mini_games/src/core/widget/game_loop.dart';
import 'package:flutter_mini_games/src/game/echo/game/logic/echo_game_controller.dart';
import 'package:flutter_mini_games/src/game/echo/style/echo_theme.dart';
import 'package:flutter_mini_games/src/game/echo/widget/echo_pad.dart';

/// The four pads in a 2x2 grid with the playback loop and the overlays
class EchoBoard extends StatelessWidget {
  final EchoGameController controller;

  const EchoBoard({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = EchoTheme.of(context);
    final gap = theme.dimens.padGap;
    return GameBoard(
      padding: EdgeInsets.all(gap),
      child: GameLoop(
        controller: controller,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              spacing: gap,
              children: [
                for (var row = 0; row < 2; row++)
                  Expanded(
                    child: Row(
                      spacing: gap,
                      children: [
                        for (var col = 0; col < 2; col++) Expanded(child: _buildPad(row * 2 + col)),
                      ],
                    ),
                  ),
              ],
            ),
            if (controller.isReady) const GameOverlay(title: 'Tap to start', subtitle: 'Watch the pads, then repeat'),
            if (controller.isGameOver) GameOverlay(title: 'Game over', subtitle: 'Score: ${controller.score}'),
          ],
        ),
      ),
    );
  }

  Widget _buildPad(int pad) {
    return EchoPad(
      key: ValueKey('echo_pad_$pad'),
      pad: pad,
      isLit: controller.litPad == pad || controller.expectedPad == pad,
      isWrong: controller.wrongPad == pad,
      onTap: () {
        if (controller.isAwaitingInput) HapticFeedback.selectionClick();
        controller.tapPad(pad);
      },
    );
  }
}
