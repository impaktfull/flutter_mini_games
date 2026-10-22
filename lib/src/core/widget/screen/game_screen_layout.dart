import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/core/widget/provider/game_theme_provider.dart';

/// Shared layout of a game screen. Shared by all games.
///
/// The screen holds [header], [board] and [controls]; the board gets the largest size that
/// fits with its [boardAspectRatio]. The [footer] (e.g. how to play) opens in a bottom sheet
/// from a "How to play" button, so it never makes the board smaller. The footer may only
/// use the core theme. The page doesn't scroll (a scroll view would take drags from the
/// board), except on screens lower than [minPageHeight].
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
        final fits = constraints.maxHeight >= minPageHeight;
        return SingleChildScrollView(
          // A scrolling page would take vertical drags and swipes from the board,
          // so it only scrolls on screens that are too small for the page
          physics: fits ? const NeverScrollableScrollPhysics() : null,
          child: SizedBox(
            height: max(constraints.maxHeight, minPageHeight),
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
                if (footer != null) _FooterButton(footer: footer),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Opens the footer (how to play) in a bottom sheet
class _FooterButton extends StatelessWidget {
  final Widget footer;

  const _FooterButton({required this.footer});

  void _open(BuildContext context, CoreGameTheme theme) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.colors.background,
      showDragHandle: true,
      builder: (context) => GameThemeProvider<CoreGameTheme>(
        // The sheet is a new route: provide the core theme again
        theme: theme,
        builder: (context, theme) => SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(theme.dimens.padding, 0, theme.dimens.padding, theme.dimens.padding),
            child: footer,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = CoreGameTheme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _open(context, theme),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            Icon(Icons.info_outline, size: 16, color: theme.colors.textMuted),
            Text('How to play', style: theme.textStyles.caption),
          ],
        ),
      ),
    );
  }
}
