import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_board.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_overlay.dart';
import 'package:flutter_mini_games/src/core/widget/game_loop.dart';
import 'package:flutter_mini_games/src/core/widget/input/game_input_detector.dart';
import 'package:flutter_mini_games/src/game/echo/game/logic/echo_game_controller.dart';
import 'package:flutter_mini_games/src/game/echo/style/echo_theme.dart';
import 'package:flutter_mini_games/src/game/echo/widget/echo_pad.dart';

/// The four pads in a 2x2 grid with the playback loop and the overlays.
/// One input detector maps a tap to a pad; space / enter start the game.
class EchoBoard extends StatelessWidget {
  final EchoGameController controller;

  const EchoBoard({
    required this.controller,
    super.key,
  });

  /// The pad at [position] in a 2x2 grid of [size] with [gap] between the pads,
  /// null for a tap in the gap between two pads
  static int? padAt(Offset position, Size size, double gap) {
    int? indexOf(double value, double extent) {
      final padExtent = (extent - gap) / 2;
      if (value < 0 || value > extent) return null;
      if (value <= padExtent) return 0;
      if (value >= padExtent + gap) return 1;
      return null;
    }

    final row = indexOf(position.dy, size.height);
    final col = indexOf(position.dx, size.width);
    if (row == null || col == null) return null;
    return row * 2 + col;
  }

  void _onTapAt(Offset position, Size size, double gap) {
    final pad = padAt(position, size, gap);
    if (pad == null) return;
    if (controller.isAwaitingInput) unawaited(HapticFeedback.selectionClick());
    controller.tapPad(pad);
  }

  @override
  Widget build(BuildContext context) {
    final theme = EchoTheme.of(context);
    final gap = theme.dimens.padGap;
    return GameBoard(
      padding: EdgeInsets.all(gap),
      child: GameLoop(
        controller: controller,
        child: LayoutBuilder(
          builder: (context, constraints) => GameInputDetector(
            onTapAt: (position) => _onTapAt(position, constraints.biggest, gap),
            // Space / enter start the game; touches go to the pads
            onKeyConfirm: controller.start,
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
    );
  }
}
