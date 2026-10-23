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
      painter: _StackPainter(controller: controller, theme: theme),
      child: const SizedBox.expand(),
    );
  }
}

/// Reads the controller while painting, repaints every frame of the controller
class _StackPainter extends CustomPainter {
  final StackGameController controller;
  final StackTheme theme;

  _StackPainter({
    required this.controller,
    required this.theme,
  }) : super(repaint: controller.frame);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width;
    final cameraY = controller.cameraY;
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

    for (final piece in controller.fallingPieces) {
      drawBlock(piece.block, drop: piece.drop);
    }
    for (final block in controller.tower) {
      drawBlock(block);
    }
    if (!controller.isGameOver) drawBlock(controller.current);
  }

  @override
  bool shouldRepaint(covariant _StackPainter oldDelegate) => oldDelegate.controller != controller || oldDelegate.theme != theme;
}
