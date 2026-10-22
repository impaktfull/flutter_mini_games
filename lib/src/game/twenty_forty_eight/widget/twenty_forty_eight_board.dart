import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_board.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_overlay.dart';
import 'package:flutter_mini_games/src/core/widget/input/game_input_detector.dart';
import 'package:flutter_mini_games/src/game/twenty_forty_eight/game/logic/twenty_forty_eight_game_controller.dart';
import 'package:flutter_mini_games/src/game/twenty_forty_eight/style/twenty_forty_eight_theme.dart';
import 'package:flutter_mini_games/src/game/twenty_forty_eight/widget/twenty_forty_eight_tile_view.dart';

class TwentyFortyEightBoard extends StatelessWidget {
  static const slideDuration = Duration(milliseconds: 120);

  final TwentyFortyEightGameController controller;

  const TwentyFortyEightBoard({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = TwentyFortyEightTheme.of(context);
    const size = TwentyFortyEightGameController.size;
    return GameBoard(
      padding: EdgeInsets.all(theme.dimens.boardPadding),
      child: GameInputDetector(
        // One drag is one move, also when the finger keeps moving
        repeatSwipes: false,
        onSwipe: controller.move,
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
                    duration: slideDuration,
                    curve: Curves.easeOut,
                    left: offset(tile.col),
                    top: offset(tile.row),
                    width: cellSize,
                    height: cellSize,
                    child: TwentyFortyEightTileView(tile: tile, size: cellSize),
                  ),
                if (controller.isWon)
                  Positioned.fill(
                    child: GameOverlay(title: 'You reached ${TwentyFortyEightGameController.winValue}!', subtitle: 'Score: ${controller.score}'),
                  )
                else if (controller.isGameOver)
                  Positioned.fill(
                    child: GameOverlay(title: 'No moves left', subtitle: 'Score: ${controller.score}'),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
