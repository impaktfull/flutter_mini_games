import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';

/// Draws a disc: filled for [DuelPlayer.bottom], a ring for [DuelPlayer.top],
/// so the players never differ by color alone
class FlipDiscPainter extends CustomPainter {
  final DuelPlayer player;
  final Color color;

  /// Ring width as a fraction of the radius
  final double ringWidth;

  const FlipDiscPainter({
    required this.player,
    required this.color,
    required this.ringWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = min(size.width, size.height) / 2;
    if (radius <= 0) return;
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..color = color
      ..isAntiAlias = true;
    if (player == DuelPlayer.bottom) {
      canvas.drawCircle(center, radius, paint);
      return;
    }
    final stroke = radius * ringWidth;
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawCircle(center, radius - stroke / 2, paint);
  }

  @override
  bool shouldRepaint(FlipDiscPainter oldDelegate) => oldDelegate.player != player || oldDelegate.color != color || oldDelegate.ringWidth != ringWidth;
}

/// A disc on the board that flips (turns around its vertical axis) when its owner changes
/// and pops in when it is placed
class FlipDisc extends StatefulWidget {
  static const flipDuration = Duration(milliseconds: 320);
  static const placeDuration = Duration(milliseconds: 180);

  final DuelPlayer owner;
  final Color Function(DuelPlayer player) colorOf;
  final double ringWidth;

  /// Pops in on the first build (a newly placed disc)
  final bool animateIn;

  const FlipDisc({
    required this.owner,
    required this.colorOf,
    required this.ringWidth,
    this.animateIn = false,
    super.key,
  });

  @override
  State<FlipDisc> createState() => _FlipDiscState();
}

class _FlipDiscState extends State<FlipDisc> with TickerProviderStateMixin {
  late final AnimationController _flip = AnimationController(vsync: this, duration: FlipDisc.flipDuration, value: 1);
  late final AnimationController _place = AnimationController(
    vsync: this,
    duration: FlipDisc.placeDuration,
    value: widget.animateIn ? 0 : 1,
  );
  late DuelPlayer _previous = widget.owner;

  @override
  void initState() {
    super.initState();
    if (widget.animateIn) unawaited(_place.forward());
  }

  @override
  void didUpdateWidget(covariant FlipDisc oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.owner != widget.owner) {
      _previous = oldWidget.owner;
      unawaited(_flip.forward(from: 0));
    }
  }

  @override
  void dispose() {
    _flip.dispose();
    _place.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_flip, _place]),
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_flip.value);
        // First half: the old side turns away, second half: the new side turns in
        final player = t < 0.5 ? _previous : widget.owner;
        final scaleX = (1 - 2 * t).abs();
        final scale = Curves.easeOutBack.transform(_place.value);
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.diagonal3Values(scaleX * scale, scale, 1),
          child: CustomPaint(
            size: Size.infinite,
            painter: FlipDiscPainter(player: player, color: widget.colorOf(player), ringWidth: widget.ringWidth),
          ),
        );
      },
    );
  }
}
