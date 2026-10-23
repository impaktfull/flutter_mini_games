import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_pair.dart';
import 'package:flutter_mini_games/src/core/duel/duel_layout.dart';
import 'package:flutter_mini_games/src/core/duel/duel_phase_overlay.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/core/widget/components/cached_text_painter.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_board.dart';
import 'package:flutter_mini_games/src/core/widget/components/how_to_play.dart';
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

  /// Goals of each player, only laid out when they change
  final DuelPair<CachedTextPainter> _scores = DuelPair.generate((player) => CachedTextPainter());

  @override
  void dispose() {
    for (final score in _scores.values) {
      score.dispose();
    }
    super.dispose();
  }

  void _onDown(PointerDownEvent event, double scale) {
    final position = event.localPosition / scale;
    final player = PuckGameController.halfAt(position);
    _pointers[event.pointer] = player;
    widget.controller.touchMallet(player, position);
  }

  void _onMove(PointerMoveEvent event, double scale) {
    final player = _pointers[event.pointer];
    if (player == null) return;
    widget.controller.moveMallet(player, event.localPosition / scale);
  }

  void _onEnd(PointerEvent event) => _pointers.remove(event.pointer);

  List<GameHowToPlayItem> get _rules => [
    const GameHowToPlayItem(icon: Icons.pan_tool, text: 'Drag your mallet\nin your half'),
    const GameHowToPlayItem(icon: Icons.sports_hockey, text: 'Shoot the puck into\nthe other goal'),
    GameHowToPlayItem(icon: Icons.emoji_events, text: 'First to ${widget.controller.goalsToWin}\ngoals wins'),
  ];

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
                    painter: _PuckPainter(controller: controller, scores: _scores, theme: theme),
                  ),
                ),
                // Lets touches through to the table while a round is playing
                DuelLayout(
                  side: (context, player) => DuelPhaseOverlay(
                    controller: controller,
                    player: player,
                    rules: _rules,
                    roundMessage: controller.roundWinner == null ? null : (controller.roundWinner == player ? 'Goal!' : 'Conceded'),
                    // The table paints the goals next to the center line
                    showScore: false,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Reads the controller while painting, repaints every frame of the controller
class _PuckPainter extends CustomPainter {
  final PuckGameController controller;
  final DuelPair<CachedTextPainter> scores;
  final PuckTheme theme;

  _PuckPainter({
    required this.controller,
    required this.scores,
    required this.theme,
  }) : super(repaint: controller.frame);

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

    _paintMallet(canvas, controller.mallet(DuelPlayer.bottom) * scale, PuckGameController.malletRadius * scale, DuelPlayer.bottom);
    _paintMallet(canvas, controller.mallet(DuelPlayer.top) * scale, PuckGameController.malletRadius * scale, DuelPlayer.top);

    final puck = controller.puck;
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

    final bottom = scores[DuelPlayer.bottom].layout('${controller.goals(DuelPlayer.bottom)}', theme.textStyles.bottomScore);
    bottom.paint(canvas, Offset(size.width - dimens.scoreMargin - bottom.width, centerY + gap));

    final top = scores[DuelPlayer.top].layout('${controller.goals(DuelPlayer.top)}', theme.textStyles.topScore);
    canvas
      ..save()
      ..translate(size.width - dimens.scoreMargin - top.width / 2, centerY - gap - top.height / 2)
      ..rotate(pi);
    top.paint(canvas, Offset(-top.width / 2, -top.height / 2));
    canvas.restore();
  }

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
  bool shouldRepaint(covariant _PuckPainter oldDelegate) => oldDelegate.controller != controller || oldDelegate.scores != scores || oldDelegate.theme != theme;
}
