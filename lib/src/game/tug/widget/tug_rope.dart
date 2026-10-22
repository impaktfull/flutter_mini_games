import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/game/tug/game/logic/tug_game_controller.dart';
import 'package:flutter_mini_games/src/game/tug/style/tug_theme.dart';

/// The rope between the two halves: a vertical lane with each player's colored edge
/// and the marker that is pulled toward the edges. The marker slides to its new place on every tap.
class TugRope extends StatelessWidget {
  static const pullDuration = Duration(milliseconds: 90);

  final TugGameController controller;

  const TugRope({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = TugTheme.of(context);
    final core = CoreGameTheme.of(context);
    final leader = controller.leader;
    return TweenAnimationBuilder<double>(
      tween: Tween(end: controller.progress),
      duration: pullDuration,
      curve: Curves.easeOut,
      builder: (context, progress, child) => CustomPaint(
        painter: _TugRopePainter(
          progress: progress,
          colors: theme.colors,
          dimens: theme.dimens,
          bottomColor: core.playerColor(DuelPlayer.bottom),
          topColor: core.playerColor(DuelPlayer.top),
          markerColor: leader == null ? theme.colors.marker : core.playerColor(leader),
        ),
      ),
    );
  }
}

class _TugRopePainter extends CustomPainter {
  /// -1 (top edge) to 1 (bottom edge)
  final double progress;
  final TugColors colors;
  final TugDimens dimens;
  final Color bottomColor;
  final Color topColor;
  final Color markerColor;

  const _TugRopePainter({
    required this.progress,
    required this.colors,
    required this.dimens,
    required this.bottomColor,
    required this.topColor,
    required this.markerColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final middleY = size.height / 2;
    final trackWidth = dimens.trackWidth.clamp(0.0, size.width);
    final track = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(centerX, middleY), width: trackWidth, height: size.height),
      Radius.circular(dimens.trackRadius),
    );

    // Lane with the colored edge of each player
    canvas
      ..save()
      ..clipRRect(track)
      ..drawRect(track.outerRect, Paint()..color = colors.track)
      ..drawRect(Rect.fromLTWH(track.left, 0, trackWidth, dimens.edgeLength), Paint()..color = topColor)
      ..drawRect(Rect.fromLTWH(track.left, size.height - dimens.edgeLength, trackWidth, dimens.edgeLength), Paint()..color = bottomColor)
      ..drawLine(
        Offset(track.left, middleY),
        Offset(track.right, middleY),
        Paint()
          ..color = colors.middle
          ..strokeWidth = 2,
      )
      ..restore();

    // The marker moves between the two edges
    final travel = (middleY - dimens.edgeLength).clamp(0.0, middleY);
    final markerY = middleY + progress * travel;

    // Rope with twisted strands that slide along with the marker
    final rope = Rect.fromCenter(center: Offset(centerX, middleY), width: dimens.ropeThickness, height: size.height);
    canvas
      ..save()
      ..clipRect(rope)
      ..drawRect(rope, Paint()..color = colors.rope);
    final strand = Paint()
      ..color = colors.ropeStrand
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final spacing = dimens.strandSpacing;
    final shift = (markerY - middleY) % spacing;
    for (var y = -spacing + shift; y < size.height + spacing; y += spacing) {
      canvas.drawLine(Offset(rope.left, y + spacing / 2), Offset(rope.right, y), strand);
    }
    canvas.restore();

    // Marker: a knot in the leading player's color
    final markerCenter = Offset(centerX, markerY);
    canvas
      ..drawCircle(markerCenter, dimens.markerRadius + dimens.markerBorder, Paint()..color = colors.markerBorder)
      ..drawCircle(markerCenter, dimens.markerRadius, Paint()..color = markerColor);
  }

  @override
  bool shouldRepaint(covariant _TugRopePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.colors != colors ||
      oldDelegate.dimens != dimens ||
      oldDelegate.bottomColor != bottomColor ||
      oldDelegate.topColor != topColor ||
      oldDelegate.markerColor != markerColor;
}
