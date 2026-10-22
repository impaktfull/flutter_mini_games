import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';

/// Split screen for two players on one device. Shared by all two-player games.
///
/// [side] builds the half of each player; the half of [DuelPlayer.top] is rotated 180°
/// so the opposite player reads it the right way up (touch positions inside are rotated too).
/// An optional [center] (e.g. a shared board or a divider) sits between the halves.
class DuelLayout extends StatelessWidget {
  final Widget Function(BuildContext context, DuelPlayer player) side;
  final Widget? center;

  const DuelLayout({
    required this.side,
    this.center,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final center = this.center;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: RotatedBox(quarterTurns: 2, child: side(context, DuelPlayer.top)),
        ),
        ?center,
        Expanded(child: side(context, DuelPlayer.bottom)),
      ],
    );
  }
}

/// Reports every finger that touches this area, also when the other player touches
/// their half at the same time (raw pointers, outside the gesture arena)
class DuelTapArea extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;

  const DuelTapArea({
    required this.onTap,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final onTap = this.onTap;
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: onTap == null ? null : (_) => onTap(),
      child: child,
    );
  }
}
