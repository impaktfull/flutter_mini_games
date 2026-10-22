import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/game/stack/game/logic/stack_game_controller.dart';
import 'package:flutter_mini_games/src/game/stack/game/model/stack_block.dart';
import 'package:flutter_mini_games/src/game/stack/style/stack_theme.dart';

/// Draws the tower, the moving block and the falling pieces
class StackTower extends StatelessWidget {
  final StackGameController controller;

  const StackTower({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = StackTheme.of(context);
    return CustomPaint(
      painter: _StackPainter(
        theme: theme,
        tower: controller.tower,
        current: controller.isGameOver ? null : controller.current,
        fallingPieces: controller.fallingPieces,
        cameraY: controller.cameraY,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _StackPainter extends CustomPainter {
  final StackTheme theme;
  final List<StackBlock> tower;
  final StackBlock? current;
  final List<StackFallingPiece> fallingPieces;
  final double cameraY;

  _StackPainter({
    required this.theme,
    required this.tower,
    required this.current,
    required this.fallingPieces,
    required this.cameraY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width;
    canvas.drawRect(Offset.zero & size, Paint()..color = theme.colors.background);

    // World y (up) to canvas y (down)
    double toCanvasY(double worldY) => size.height - (worldY - cameraY) * scale;

    final groundTop = toCanvasY(0);
    if (groundTop < size.height) {
      canvas.drawRect(Rect.fromLTRB(0, groundTop, size.width, size.height), Paint()..color = theme.colors.ground);
    }

    final visibleBottom = cameraY - StackGameController.blockHeight;
    final visibleTop = cameraY + size.height / scale;

    void drawBlock(StackBlock block, {double drop = 0}) {
      final bottom = block.level * StackGameController.blockHeight - drop;
      if (bottom < visibleBottom || bottom > visibleTop) return;
      final gap = theme.dimens.blockGap;
      final rect = Rect.fromLTRB(
        block.left * scale,
        toCanvasY(bottom + StackGameController.blockHeight) + gap / 2,
        block.right * scale,
        toCanvasY(bottom) - gap / 2,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(theme.dimens.blockRadius)),
        Paint()..color = theme.blockColor(block.level),
      );
    }

    for (final piece in fallingPieces) {
      drawBlock(piece.block, drop: piece.drop);
    }
    for (final block in tower) {
      drawBlock(block);
    }
    final current = this.current;
    if (current != null) drawBlock(current);
  }

  // The controller creates new lists on every frame, repaint whenever the widget rebuilds
  @override
  bool shouldRepaint(covariant _StackPainter oldDelegate) => true;
}
