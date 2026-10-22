import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

enum GameDirection { up, down, left, right }

/// Shared input for all games: taps, swipes, holds and the keyboard (web and desktop).
///
/// - Tap or space/enter: [onTap] (fires on touch down for a fast response), [onRelease] when let go.
///   [onTapAt] also gets the local position of a touch (grids, pads), not called for keys.
/// - Swipe or arrow keys/WASD: [onSwipe]. Several swipes can be made in one drag unless
///   [repeatSwipes] is false.
/// - When [onSwipe] is null, arrow up and W also trigger [onTap] / [onRelease] (jump games)
/// - Holding the left or right half of the area, or arrow left/right and A/D: [onHorizontalHold]
///   with the held direction, or null when nothing is held. The last press wins.
///   When set, left/right keys are used for holding instead of [onSwipe].
class GameInputDetector extends StatefulWidget {
  /// Distance a finger has to move before it counts as a swipe
  static const swipeThreshold = 24.0;

  final VoidCallback? onTap;
  final ValueChanged<Offset>? onTapAt;
  final VoidCallback? onRelease;
  final ValueChanged<GameDirection>? onSwipe;
  final ValueChanged<GameDirection?>? onHorizontalHold;

  /// Whether one drag can report several swipes (Snake) or only the first (2048)
  final bool repeatSwipes;

  /// Whether this detector takes the keyboard focus; false when a screen has several
  final bool autofocus;
  final Widget child;

  const GameInputDetector({
    required this.child,
    this.onTap,
    this.onTapAt,
    this.onRelease,
    this.onSwipe,
    this.onHorizontalHold,
    this.repeatSwipes = true,
    this.autofocus = true,
    super.key,
  });

  @override
  State<GameInputDetector> createState() => _GameInputDetectorState();
}

class _GameInputDetectorState extends State<GameInputDetector> {
  Offset _dragDistance = Offset.zero;
  bool _swipedThisDrag = false;

  /// Active holds in press order: pointer ids or keys with their direction
  final List<(Object, GameDirection)> _holds = [];
  GameDirection? _heldDirection;

  void _onPanUpdate(DragUpdateDetails details) {
    final onSwipe = widget.onSwipe;
    if (onSwipe == null || (_swipedThisDrag && !widget.repeatSwipes)) return;
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
    _swipedThisDrag = true;
  }

  void _startHold(Object id, GameDirection direction) {
    _holds
      ..removeWhere((hold) => hold.$1 == id)
      ..add((id, direction));
    _notifyHold();
  }

  void _endHold(Object id) {
    _holds.removeWhere((hold) => hold.$1 == id);
    _notifyHold();
  }

  void _notifyHold() {
    final direction = _holds.isEmpty ? null : _holds.last.$2;
    if (direction == _heldDirection) return;
    _heldDirection = direction;
    widget.onHorizontalHold?.call(direction);
  }

  void _onPointerDown(PointerDownEvent event) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final isLeft = box.globalToLocal(event.position).dx < box.size.width / 2;
    _startHold(event.pointer, isLeft ? GameDirection.left : GameDirection.right);
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyRepeatEvent) return KeyEventResult.ignored;
    final isDown = event is KeyDownEvent;
    final key = event.logicalKey;
    final direction = switch (key) {
      LogicalKeyboardKey.arrowUp || LogicalKeyboardKey.keyW => GameDirection.up,
      LogicalKeyboardKey.arrowDown || LogicalKeyboardKey.keyS => GameDirection.down,
      LogicalKeyboardKey.arrowLeft || LogicalKeyboardKey.keyA => GameDirection.left,
      LogicalKeyboardKey.arrowRight || LogicalKeyboardKey.keyD => GameDirection.right,
      _ => null,
    };

    final isHorizontal = direction == GameDirection.left || direction == GameDirection.right;
    if (isHorizontal && widget.onHorizontalHold != null) {
      isDown ? _startHold(key, direction!) : _endHold(key);
      return KeyEventResult.handled;
    }

    final onSwipe = widget.onSwipe;
    if (direction != null && onSwipe != null) {
      if (isDown) onSwipe(direction);
      return KeyEventResult.handled;
    }

    final isTapKey = key == LogicalKeyboardKey.space || key == LogicalKeyboardKey.enter || direction == GameDirection.up;
    final onTap = widget.onTap;
    if (isTapKey && onTap != null) {
      isDown ? onTap() : widget.onRelease?.call();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final hasHold = widget.onHorizontalHold != null;
    return Focus(
      autofocus: widget.autofocus,
      onKeyEvent: _onKeyEvent,
      child: Listener(
        // Raw pointers: holds must not compete with taps and swipes in the gesture arena
        onPointerDown: hasHold ? _onPointerDown : null,
        onPointerUp: hasHold ? (event) => _endHold(event.pointer) : null,
        onPointerCancel: hasHold ? (event) => _endHold(event.pointer) : null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: widget.onTap == null && widget.onTapAt == null
              ? null
              : (details) {
                  widget.onTap?.call();
                  widget.onTapAt?.call(details.localPosition);
                },
          onTapUp: widget.onRelease == null ? null : (_) => widget.onRelease!(),
          onTapCancel: widget.onRelease,
          onPanStart: widget.onSwipe == null
              ? null
              : (_) {
                  _dragDistance = Offset.zero;
                  _swipedThisDrag = false;
                },
          onPanUpdate: widget.onSwipe == null ? null : _onPanUpdate,
          dragStartBehavior: DragStartBehavior.down,
          child: widget.child,
        ),
      ),
    );
  }
}
