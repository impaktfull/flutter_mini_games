import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

enum GameDirection { up, down, left, right }

/// Shared input for all games: taps, swipes and the keyboard (web and desktop).
///
/// - Tap or space/enter: [onTap] (fires on touch down for a fast response)
/// - Swipe or arrow keys/WASD: [onSwipe]. Several swipes can be made in one drag.
/// - When [onSwipe] is null, arrow up and W also trigger [onTap] (jump games)
class GameInputDetector extends StatefulWidget {
  /// Distance a finger has to move before it counts as a swipe
  static const swipeThreshold = 24.0;

  final VoidCallback? onTap;
  final ValueChanged<GameDirection>? onSwipe;
  final Widget child;

  const GameInputDetector({
    required this.child,
    this.onTap,
    this.onSwipe,
    super.key,
  });

  @override
  State<GameInputDetector> createState() => _GameInputDetectorState();
}

class _GameInputDetectorState extends State<GameInputDetector> {
  Offset _dragDistance = Offset.zero;

  void _onPanUpdate(DragUpdateDetails details) {
    final onSwipe = widget.onSwipe;
    if (onSwipe == null) return;
    _dragDistance += details.delta;
    final dx = _dragDistance.dx;
    final dy = _dragDistance.dy;
    if (dx.abs() < GameInputDetector.swipeThreshold && dy.abs() < GameInputDetector.swipeThreshold) return;
    if (dx.abs() > dy.abs()) {
      onSwipe(dx > 0 ? GameDirection.right : GameDirection.left);
    } else {
      onSwipe(dy > 0 ? GameDirection.down : GameDirection.up);
    }
    _dragDistance = Offset.zero;
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    final direction = switch (key) {
      LogicalKeyboardKey.arrowUp || LogicalKeyboardKey.keyW => GameDirection.up,
      LogicalKeyboardKey.arrowDown || LogicalKeyboardKey.keyS => GameDirection.down,
      LogicalKeyboardKey.arrowLeft || LogicalKeyboardKey.keyA => GameDirection.left,
      LogicalKeyboardKey.arrowRight || LogicalKeyboardKey.keyD => GameDirection.right,
      _ => null,
    };
    final onSwipe = widget.onSwipe;
    if (direction != null && onSwipe != null) {
      onSwipe(direction);
      return KeyEventResult.handled;
    }
    final isTapKey = key == LogicalKeyboardKey.space || key == LogicalKeyboardKey.enter || direction == GameDirection.up;
    final onTap = widget.onTap;
    if (isTapKey && onTap != null) {
      onTap();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: _onKeyEvent,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: widget.onTap == null ? null : (_) => widget.onTap!(),
        onPanStart: widget.onSwipe == null ? null : (_) => _dragDistance = Offset.zero,
        onPanUpdate: widget.onSwipe == null ? null : _onPanUpdate,
        dragStartBehavior: DragStartBehavior.down,
        child: widget.child,
      ),
    );
  }
}
