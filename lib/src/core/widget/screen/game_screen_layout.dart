import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';

/// Shared layout of a game screen. Shared by all games.
///
/// The first screen height holds [header], [board] and [controls]; the board gets the
/// largest size that fits with its [boardAspectRatio]. The [footer] (e.g. how to play)
/// sits below it and is reached by scrolling, so it never makes the board smaller.
class GameScreenLayout extends StatelessWidget {
  /// Below this height the page scrolls instead of shrinking the board further
  static const minPageHeight = 440.0;

  /// Boards don't grow wider than this on tablets and desktop
  static const maxBoardWidth = 560.0;

  final Widget? header;
  final Widget board;

  /// Width / height of the board
  final double boardAspectRatio;
  final Widget? controls;
  final Widget? footer;

  const GameScreenLayout({
    required this.board,
    this.header,
    this.boardAspectRatio = 1,
    this.controls,
    this.footer,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CoreGameTheme.of(context);
    final spacing = theme.dimens.padding;
    final header = this.header;
    final controls = this.controls;
    final footer = this.footer;
    return LayoutBuilder(
      builder: (context, constraints) {
        final pageHeight = max(constraints.maxHeight, minPageHeight);
        return SingleChildScrollView(
          child: Column(
            spacing: spacing,
            children: [
              SizedBox(
                height: pageHeight,
                child: Column(
                  spacing: spacing,
                  children: [
                    ?header,
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, area) {
                          // Largest board with the aspect ratio that fits the remaining area
                          var width = min(area.maxWidth, maxBoardWidth);
                          var height = width / boardAspectRatio;
                          if (height > area.maxHeight) {
                            height = area.maxHeight;
                            width = height * boardAspectRatio;
                          }
                          return Center(
                            child: SizedBox(width: width, height: height, child: board),
                          );
                        },
                      ),
                    ),
                    ?controls,
                  ],
                ),
              ),
              ?footer,
            ],
          ),
        );
      },
    );
  }
}
