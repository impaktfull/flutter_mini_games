import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/game/whack/game/logic/whack_game_controller.dart';
import 'package:flutter_mini_games/src/game/whack/style/whack_theme.dart';
import 'package:flutter_mini_games/src/game/whack/widget/whack_hole.dart';

/// The 3x3 grid of holes
class WhackField extends StatelessWidget {
  final WhackGameController controller;

  const WhackField({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WhackTheme.of(context);
    final gap = theme.dimens.cellGap;
    // The targets move every frame: only the holes rebuild
    return ListenableBuilder(
      listenable: controller.frame,
      builder: (context, child) => Column(
        spacing: gap,
        children: [
          for (var row = 0; row < WhackGameController.rows; row++)
            Expanded(
              child: Row(
                spacing: gap,
                children: [
                  for (var column = 0; column < WhackGameController.columns; column++) Expanded(child: _buildHole(row * WhackGameController.columns + column)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHole(int hole) {
    final target = controller.targetAt(hole);
    return WhackHole(
      hole: hole,
      target: target,
      pop: target == null ? 0 : controller.popOf(target),
      onTap: () => controller.whack(hole),
    );
  }
}
