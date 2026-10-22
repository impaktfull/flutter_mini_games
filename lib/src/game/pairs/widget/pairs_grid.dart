import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/game/pairs/game/logic/pairs_game_controller.dart';
import 'package:flutter_mini_games/src/game/pairs/style/pairs_theme.dart';
import 'package:flutter_mini_games/src/game/pairs/widget/pairs_card_tile.dart';

/// The cards of the board, square and as large as possible within its parent
class PairsGrid extends StatelessWidget {
  final PairsGameController controller;

  const PairsGrid({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = PairsTheme.of(context);
    final spacing = theme.dimens.cardSpacing;
    final rows = controller.rows;
    final cols = controller.cols;
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardSize = max(
          0.0,
          min(
            (constraints.maxWidth - spacing * (cols - 1)) / cols,
            (constraints.maxHeight - spacing * (rows - 1)) / rows,
          ),
        );
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: spacing,
            children: [
              for (var row = 0; row < rows; row++)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: spacing,
                  children: [
                    for (var col = 0; col < cols; col++) _buildCard(row * cols + col, cardSize),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCard(int index, double size) {
    return PairsCardTile(
      key: ValueKey('pairs_card_$index'),
      card: controller.cardAt(index),
      size: size,
      onTap: controller.canFlip(index) ? () => controller.flip(index) : null,
    );
  }
}
