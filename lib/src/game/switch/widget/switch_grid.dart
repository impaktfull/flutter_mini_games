import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/game/switch/game/logic/switch_game_controller.dart';
import 'package:flutter_mini_games/src/game/switch/style/switch_theme.dart';
import 'package:flutter_mini_games/src/game/switch/widget/switch_light.dart';

/// The lights of the board, as large as possible within its parent and always square
class SwitchGrid extends StatelessWidget {
  final SwitchGameController controller;

  const SwitchGrid({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SwitchGameTheme.of(context);
    final size = controller.size;
    return LayoutBuilder(
      builder: (context, constraints) {
        final extent = max(0.0, min(constraints.maxWidth, constraints.maxHeight));
        // Smaller gaps on tiny boards, so the lights always fit
        final spacing = min(theme.dimens.cellSpacing, extent / size * 0.15);
        final cellSize = max(0.0, (extent - spacing * (size - 1)) / size);
        // The glows are painted in their own layer below all lights, so a glow never covers a neighbour
        return Center(
          child: Stack(
            children: [
              _buildLayer(spacing, size, (row, col) => SwitchLightGlow(isLit: controller.isLit(row, col), size: cellSize)),
              _buildLayer(
                spacing,
                size,
                (row, col) => SwitchLight(
                  key: ValueKey('switch_cell_${row}_$col'),
                  isLit: controller.isLit(row, col),
                  isHint: controller.isHint(row, col),
                  size: cellSize,
                  onTap: controller.isFinished ? null : () => controller.tap(row, col),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLayer(double spacing, int size, Widget Function(int row, int col) builder) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: spacing,
      children: [
        for (var row = 0; row < size; row++)
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: spacing,
            children: [
              for (var col = 0; col < size; col++) builder(row, col),
            ],
          ),
      ],
    );
  }
}
