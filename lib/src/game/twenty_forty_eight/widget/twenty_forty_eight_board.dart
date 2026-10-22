import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_board.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_overlay.dart';
import 'package:flutter_mini_games/src/core/widget/input/game_input_detector.dart';
import 'package:flutter_mini_games/src/game/twenty_forty_eight/game/logic/twenty_forty_eight_game_controller.dart';
import 'package:flutter_mini_games/src/game/twenty_forty_eight/style/twenty_forty_eight_theme.dart';
import 'package:flutter_mini_games/src/game/twenty_forty_eight/widget/twenty_forty_eight_tile_view.dart';

class TwentyFortyEightBoard extends StatefulWidget {
  static const slideDuration = Duration(milliseconds: 120);

  /// One drag can produce several swipes, a repeated swipe in the same direction within
  /// this time is ignored so one long swipe is one move
  static const repeatSwipeDelay = Duration(milliseconds: 250);

  final TwentyFortyEightGameController controller;

  const TwentyFortyEightBoard({
    required this.controller,
    super.key,
  });

  @override
  State<TwentyFortyEightBoard> createState() => _TwentyFortyEightBoardState();
}

class _TwentyFortyEightBoardState extends State<TwentyFortyEightBoard> {
  GameDirection? _lastDirection;
  final Stopwatch _sinceLastSwipe = Stopwatch();

  void _onSwipe(GameDirection direction) {
    final isRepeat = direction == _lastDirection && _sinceLastSwipe.isRunning && _sinceLastSwipe.elapsed < TwentyFortyEightBoard.repeatSwipeDelay;
    _lastDirection = direction;
    _sinceLastSwipe
      ..reset()
      ..start();
    if (isRepeat) return;
    widget.controller.move(direction);
  }

  @override
  Widget build(BuildContext context) {
    final theme = TwentyFortyEightTheme.of(context);
    final controller = widget.controller;
    const size = TwentyFortyEightGameController.size;
    return GameBoard(
      padding: EdgeInsets.all(theme.dimens.boardPadding),
      child: GameInputDetector(
        onSwipe: _onSwipe,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final spacing = theme.dimens.cellSpacing;
            final cellSize = (constraints.biggest.shortestSide - spacing * (size - 1)) / size;
            double offset(int index) => index * (cellSize + spacing);
            return Stack(
              children: [
                for (var row = 0; row < size; row++)
                  for (var col = 0; col < size; col++)
                    Positioned(
                      left: offset(col),
                      top: offset(row),
                      width: cellSize,
                      height: cellSize,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: theme.colors.emptyCell,
                          borderRadius: BorderRadius.circular(theme.dimens.tileRadius),
                        ),
                      ),
                    ),
                for (final tile in controller.tiles)
                  AnimatedPositioned(
                    key: ValueKey(tile.id),
                    duration: TwentyFortyEightBoard.slideDuration,
                    curve: Curves.easeOut,
                    left: offset(tile.col),
                    top: offset(tile.row),
                    width: cellSize,
                    height: cellSize,
                    child: TwentyFortyEightTileView(tile: tile, size: cellSize),
                  ),
                if (controller.isWon)
                  _buildOverlay(title: 'You reached ${TwentyFortyEightGameController.winValue}!', subtitle: 'Score: ${controller.score}')
                else if (controller.isGameOver)
                  _buildOverlay(title: 'No moves left', subtitle: 'Score: ${controller.score}'),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Scaled down so it also fits on a small board
  Widget _buildOverlay({required String title, required String subtitle}) => Positioned.fill(
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: GameOverlay(title: title, subtitle: subtitle),
    ),
  );
}
