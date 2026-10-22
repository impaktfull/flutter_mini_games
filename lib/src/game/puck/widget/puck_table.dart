import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_layout.dart';
import 'package:flutter_mini_games/src/core/duel/duel_phase_overlay.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_board.dart';
import 'package:flutter_mini_games/src/core/widget/game_loop.dart';
import 'package:flutter_mini_games/src/game/puck/game/logic/puck_game_controller.dart';
import 'package:flutter_mini_games/src/game/puck/style/puck_theme.dart';

/// The air hockey table: runs the game loop, moves the mallets with the fingers of both
/// players and shows the match flow of each player on their half.
class PuckTable extends StatefulWidget {
  final PuckGameController controller;

  const PuckTable({
    required this.controller,
    super.key,
  });

  @override
  State<PuckTable> createState() => _PuckTableState();
}

class _PuckTableState extends State<PuckTable> {
  /// Every finger stays with the half it went down in
  final Map<int, DuelPlayer> _pointers = {};

  void _onDown(PointerDownEvent event, double scale) {
    final position = event.localPosition / scale;
    final player = PuckGameController.halfAt(position);
    _pointers[event.pointer] = player;
    widget.controller.moveMallet(player, position);
  }

  void _onMove(PointerMoveEvent event, double scale) {
    final player = _pointers[event.pointer];
    if (player == null) return;
    widget.controller.moveMallet(player, event.localPosition / scale);
  }

  void _onEnd(PointerEvent event) => _pointers.remove(event.pointer);

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final theme = PuckTheme.of(context);
    return GameBoard(
      aspectRatio: PuckGameController.width / PuckGameController.height,
      child: GameLoop(
        controller: controller,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // World units to pixels
            final scale = constraints.maxWidth / PuckGameController.width;
            return Stack(
              fit: StackFit.expand,
              children: [
                Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (event) => _onDown(event, scale),
                  onPointerMove: (event) => _onMove(event, scale),
                  onPointerUp: _onEnd,
                  onPointerCancel: _onEnd,
                  child: CustomPaint(
                    painter: _PuckPainter(
                      puck: controller.puck,
                      bottomMallet: controller.mallet(DuelPlayer.bottom),
                      topMallet: controller.mallet(DuelPlayer.top),
                      bottomGoals: controller.goals(DuelPlayer.bottom),
                      topGoals: controller.goals(DuelPlayer.top),
                      theme: theme,
                    ),
                  ),
                ),
                // Lets touches through to the table while a round is playing
                DuelLayout(
                  side: (context, player) => DuelPhaseOverlay(controller: controller, player: player),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PuckPainter extends CustomPainter {
  final Offset puck;
  final Offset bottomMallet;
  final Offset topMallet;
  final int bottomGoals;
  final int topGoals;
  final PuckTheme theme;

  const _PuckPainter({
    required this.puck,
    required this.bottomMallet,
    required this.topMallet,
    required this.bottomGoals,
    required this.topGoals,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final colors = theme.colors;
    final dimens = theme.dimens;
    final scale = size.width / PuckGameController.width;
    final centerY = size.height / 2;
    final goalHalf = PuckGameController.goalWidth / 2 * scale;
    final linePaint = Paint()
      ..color = colors.line
      ..strokeWidth = dimens.lineWidth
      ..style = PaintingStyle.stroke;

    canvas
      ..drawRect(Offset.zero & size, Paint()..color = colors.table)
      ..drawLine(Offset(0, centerY), Offset(size.width, centerY), linePaint)
      ..drawCircle(Offset(size.width / 2, centerY), 0.15 * scale, linePaint)
      // Goal areas
      ..drawCircle(Offset(size.width / 2, 0), goalHalf, linePaint)
      ..drawCircle(Offset(size.width / 2, size.height), goalHalf, linePaint)
      // Goal mouths in the color of the player who defends them
      ..drawRect(Rect.fromLTRB(size.width / 2 - goalHalf, 0, size.width / 2 + goalHalf, dimens.goalThickness), Paint()..color = colors.topPlayer)
      ..drawRect(
        Rect.fromLTRB(size.width / 2 - goalHalf, size.height - dimens.goalThickness, size.width / 2 + goalHalf, size.height),
        Paint()..color = colors.bottomPlayer,
      );

    _paintScores(canvas, size);

    _paintMallet(canvas, bottomMallet * scale, PuckGameController.malletRadius * scale, DuelPlayer.bottom);
    _paintMallet(canvas, topMallet * scale, PuckGameController.malletRadius * scale, DuelPlayer.top);

    final puckRadius = PuckGameController.puckRadius * scale;
    canvas
      ..drawCircle(puck * scale, puckRadius, Paint()..color = colors.puck)
      ..drawCircle(
        puck * scale,
        puckRadius * 0.55,
        Paint()
          ..color = colors.puckRing
          ..strokeWidth = dimens.malletRingWidth
          ..style = PaintingStyle.stroke,
      );
  }

  /// Goals of both players next to the center line, the top one upside down
  void _paintScores(Canvas canvas, Size size) {
    final dimens = theme.dimens;
    final centerY = size.height / 2;
    final gap = dimens.lineWidth * 2;

    final bottom = _layout('$bottomGoals', theme.textStyles.bottomScore);
    bottom.paint(canvas, Offset(size.width - dimens.scoreMargin - bottom.width, centerY + gap));

    final top = _layout('$topGoals', theme.textStyles.topScore);
    canvas
      ..save()
      ..translate(size.width - dimens.scoreMargin - top.width / 2, centerY - gap - top.height / 2)
      ..rotate(pi);
    top.paint(canvas, Offset(-top.width / 2, -top.height / 2));
    canvas.restore();
    bottom.dispose();
    top.dispose();
  }

  TextPainter _layout(String text, TextStyle style) => TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
  )..layout();

  void _paintMallet(Canvas canvas, Offset center, double radius, DuelPlayer player) {
    canvas
      ..drawCircle(center, radius, Paint()..color = theme.playerColor(player))
      ..drawCircle(
        center,
        radius * 0.62,
        Paint()
          ..color = theme.onPlayerColor(player)
          ..strokeWidth = theme.dimens.malletRingWidth
          ..style = PaintingStyle.stroke,
      )
      ..drawCircle(center, radius * 0.25, Paint()..color = theme.onPlayerColor(player));
  }

  @override
  bool shouldRepaint(covariant _PuckPainter oldDelegate) =>
      oldDelegate.puck != puck ||
      oldDelegate.bottomMallet != bottomMallet ||
      oldDelegate.topMallet != topMallet ||
      oldDelegate.bottomGoals != bottomGoals ||
      oldDelegate.topGoals != topGoals ||
      oldDelegate.theme != theme;
}
