import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_board.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_overlay.dart';
import 'package:flutter_mini_games/src/core/widget/game_loop.dart';
import 'package:flutter_mini_games/src/core/widget/input/game_input_detector.dart';
import 'package:flutter_mini_games/src/game/breaker/game/logic/breaker_game_controller.dart';
import 'package:flutter_mini_games/src/game/breaker/game/model/breaker_phase.dart';
import 'package:flutter_mini_games/src/game/breaker/game/model/breaker_steer.dart';
import 'package:flutter_mini_games/src/game/breaker/style/breaker_theme.dart';
import 'package:flutter_mini_games/src/game/breaker/widget/breaker_painter.dart';

/// The playing field: drag anywhere to move the paddle, or hold the left or right half
/// (arrow keys / A and D). A tap, space or enter launches the ball.
class BreakerPlayfield extends StatelessWidget {
  /// Width / height of the board
  static const aspectRatio = BreakerGameController.worldWidth / BreakerGameController.worldHeight;

  final BreakerGameController controller;

  const BreakerPlayfield({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = BreakerTheme.of(context);
    return GameBoard(
      aspectRatio: aspectRatio,
      child: GameLoop(
        controller: controller,
        child: _BreakerInput(
          controller: controller,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(
                color: theme.colors.background,
                child: CustomPaint(
                  painter: BreakerPainter(controller: controller, colors: theme.colors, dimens: theme.dimens),
                ),
              ),
              ?_overlay(),
            ],
          ),
        ),
      ),
    );
  }

  GameOverlay? _overlay() {
    final livesLeft = controller.lives == 1 ? '1 life left' : '${controller.lives} lives left';
    return switch (controller.phase) {
      BreakerPhase.ready => const GameOverlay(title: 'Tap to start', subtitle: 'Drag or hold left / right to move'),
      BreakerPhase.serving => GameOverlay(title: 'Ball lost', subtitle: 'Tap to launch · $livesLeft'),
      BreakerPhase.levelCleared => GameOverlay(title: 'Level cleared!', subtitle: 'Tap to start level ${controller.level}'),
      BreakerPhase.gameOver => GameOverlay(title: 'Game over', subtitle: 'Score: ${controller.score}'),
      BreakerPhase.won => GameOverlay(title: 'You win!', subtitle: 'Score: ${controller.score}'),
      BreakerPhase.playing => null,
    };
  }
}

/// Input of the playing field:
/// - Keyboard and holds through `GameInputDetector`: arrow keys / A-D and holding a half of
///   the board steer, space / enter launch.
/// - A finger that moves [slop] pixels drags the paddle with its horizontal movement (raw
///   pointers, so the drag does not compete with the taps and holds of `GameInputDetector`).
/// - A short touch that did not drag launches the ball when it is released, so a finger can
///   move the paddle into position first. Longer touches only hold.
class _BreakerInput extends StatefulWidget {
  static const slop = 8.0;

  /// Longest touch that still counts as a tap to launch
  static const maxTapDuration = Duration(milliseconds: 300);

  final BreakerGameController controller;
  final Widget child;

  const _BreakerInput({
    required this.controller,
    required this.child,
  });

  @override
  State<_BreakerInput> createState() => _BreakerInputState();
}

class _BreakerInputState extends State<_BreakerInput> {
  /// Fingers on the board that do not drag (yet): when they touched and how far they moved
  final Map<int, (Duration, double)> _pending = {};
  int? _dragPointer;

  BreakerGameController get _controller => widget.controller;

  double get _worldPerPixel {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize || box.size.width == 0) return 0;
    return BreakerGameController.worldWidth / box.size.width;
  }

  /// Space, enter or a touch: touches launch on release instead (see [_onPointerUp])
  void _onTap() {
    if (_pending.isEmpty && _dragPointer == null) _controller.launch();
  }

  void _onHorizontalHold(GameDirection? direction) => _controller.steerTo(switch (direction) {
    GameDirection.left => BreakerSteer.left,
    GameDirection.right => BreakerSteer.right,
    _ => BreakerSteer.none,
  });

  // The pointer events of this Listener arrive before GameInputDetector reports the tap
  void _onPointerDown(PointerDownEvent event) => _pending[event.pointer] = (event.timeStamp, 0);

  void _onPointerMove(PointerMoveEvent event) {
    final dx = event.delta.dx;
    if (_dragPointer == event.pointer) {
      _controller.dragPaddleBy(dx * _worldPerPixel);
      return;
    }
    final pending = _pending[event.pointer];
    if (pending == null || _dragPointer != null) return;
    final moved = pending.$2 + dx;
    if (moved.abs() < _BreakerInput.slop) {
      _pending[event.pointer] = (pending.$1, moved);
      return;
    }
    _pending.remove(event.pointer);
    _dragPointer = event.pointer;
    _controller
      ..beginDrag()
      ..dragPaddleBy(moved * _worldPerPixel);
  }

  void _onPointerUp(PointerUpEvent event) {
    final pending = _pending.remove(event.pointer);
    if (pending != null && event.timeStamp - pending.$1 <= _BreakerInput.maxTapDuration) _controller.launch();
    _endDrag(event.pointer);
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _pending.remove(event.pointer);
    _endDrag(event.pointer);
  }

  void _endDrag(int pointer) {
    if (_dragPointer != pointer) return;
    _dragPointer = null;
    _controller.endDrag();
  }

  @override
  Widget build(BuildContext context) {
    return GameInputDetector(
      onTap: _onTap,
      onHorizontalHold: _onHorizontalHold,
      child: Listener(
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerCancel,
        child: widget.child,
      ),
    );
  }
}
