import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_board.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_overlay.dart';
import 'package:flutter_mini_games/src/core/widget/game_loop.dart';
import 'package:flutter_mini_games/src/game/hop/game/logic/hop_game_controller.dart';
import 'package:flutter_mini_games/src/game/hop/game/model/hop_steer.dart';
import 'package:flutter_mini_games/src/game/hop/style/hop_theme.dart';
import 'package:flutter_mini_games/src/game/hop/widget/hop_painter.dart';

/// The playing field with its own hold input: hold the left or right half of the board
/// (or the arrow keys / A and D) to steer. The last pressed hold wins.
class HopPlayfield extends StatefulWidget {
  /// Width / height of the board
  static const aspectRatio = HopGameController.worldWidth / HopGameController.viewHeight;

  final HopGameController controller;

  const HopPlayfield({
    required this.controller,
    super.key,
  });

  @override
  State<HopPlayfield> createState() => _HopPlayfieldState();
}

class _HopPlayfieldState extends State<HopPlayfield> {
  /// Active holds (pointer ids and keys) in the order they were pressed
  final Map<Object, HopSteer> _holds = {};

  void _press(Object source, HopSteer steer) {
    _holds
      ..remove(source)
      ..[source] = steer;
    _sync();
  }

  void _release(Object source) {
    if (_holds.remove(source) == null) return;
    _sync();
  }

  void _sync() => widget.controller.steerTo(_holds.isEmpty ? HopSteer.none : _holds.values.last);

  void _onPointerDown(PointerDownEvent event, double width) {
    if (widget.controller.isGameOver) return;
    _press(event.pointer, event.localPosition.dx < width / 2 ? HopSteer.left : HopSteer.right);
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    final key = event.logicalKey;
    final steer = switch (key) {
      LogicalKeyboardKey.arrowLeft || LogicalKeyboardKey.keyA => HopSteer.left,
      LogicalKeyboardKey.arrowRight || LogicalKeyboardKey.keyD => HopSteer.right,
      _ => null,
    };
    if (steer != null) {
      if (event is KeyUpEvent) {
        _release(key);
      } else if (event is KeyDownEvent && !widget.controller.isGameOver) {
        _press(key, steer);
      }
      return KeyEventResult.handled;
    }
    final isStartKey = key == LogicalKeyboardKey.space || key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.arrowUp || key == LogicalKeyboardKey.keyW;
    if (isStartKey && event is KeyDownEvent && widget.controller.isReady) {
      widget.controller.start();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final theme = HopTheme.of(context);
    final controller = widget.controller;
    return GameBoard(
      aspectRatio: HopPlayfield.aspectRatio,
      child: GameLoop(
        controller: controller,
        child: Focus(
          autofocus: true,
          onKeyEvent: _onKeyEvent,
          child: LayoutBuilder(
            builder: (context, constraints) => Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (event) => _onPointerDown(event, constraints.maxWidth),
              onPointerUp: (event) => _release(event.pointer),
              onPointerCancel: (event) => _release(event.pointer),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(
                    color: theme.colors.background,
                    child: CustomPaint(
                      painter: HopPainter(controller: controller, colors: theme.colors, dimens: theme.dimens),
                    ),
                  ),
                  if (controller.isReady) const GameOverlay(title: 'Tap to start', subtitle: 'Hold left or right to steer'),
                  if (controller.isGameOver) GameOverlay(title: 'Game over', subtitle: 'Score: ${controller.score}'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
