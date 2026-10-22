import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/game/push/game/logic/push_game_controller.dart';

/// One player's half: every finger down pushes, aimed by its horizontal position
/// (middle = straight at the opponent, edges = up to 60° left / right), and keeps a weak
/// push going while it is held. Raw pointers, so both players can play at the same time.
///
/// Inside `DuelLayout` the top half is rotated, so left and right are from the player's view.
class PushTouchArea extends StatefulWidget {
  final PushGameController controller;
  final DuelPlayer player;
  final Widget child;

  const PushTouchArea({
    required this.controller,
    required this.player,
    required this.child,
    super.key,
  });

  /// Maps a horizontal position in a half of [width] to an aim of -1 (left) .. 1 (right)
  static double aimFor(double x, double width) => width <= 0 ? 0 : ((x / width) * 2 - 1).clamp(-1.0, 1.0);

  @override
  State<PushTouchArea> createState() => _PushTouchAreaState();
}

class _PushTouchAreaState extends State<PushTouchArea> {
  /// Aim of every finger that is down, the last one steers
  final Map<int, double> _pointers = {};

  double _aim(PointerEvent event) => PushTouchArea.aimFor(event.localPosition.dx, context.size?.width ?? 0);

  void _onDown(PointerDownEvent event) {
    final aim = _aim(event);
    _pointers[event.pointer] = aim;
    widget.controller
      ..push(widget.player, aim: aim)
      ..hold(widget.player, aim);
  }

  void _onMove(PointerMoveEvent event) {
    if (!_pointers.containsKey(event.pointer)) return;
    final aim = _aim(event);
    _pointers
      ..remove(event.pointer)
      ..[event.pointer] = aim;
    widget.controller.hold(widget.player, aim);
  }

  void _onUp(PointerEvent event) {
    if (_pointers.remove(event.pointer) == null) return;
    widget.controller.hold(widget.player, _pointers.isEmpty ? null : _pointers.values.last);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _onDown,
      onPointerMove: _onMove,
      onPointerUp: _onUp,
      onPointerCancel: _onUp,
      child: widget.child,
    );
  }
}
