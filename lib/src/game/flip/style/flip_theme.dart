import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';

class FlipTheme extends GameTheme {
  final FlipColors colors;
  final FlipTextStyles textStyles;
  final FlipDimens dimens;

  static FlipTheme of(BuildContext context) => GameTheme.of<FlipTheme>(context);

  const FlipTheme({
    required this.colors,
    required this.textStyles,
    required this.dimens,
  });

  factory FlipTheme.fromCore(CoreGameTheme core) => FlipTheme(
    colors: FlipColors(
      cell: core.colors.surface,
      lastMoveCell: Color.lerp(core.colors.surface, core.colors.textMuted, 0.3)!,
      bottomPlayer: core.playerColor(DuelPlayer.bottom),
      topPlayer: core.playerColor(DuelPlayer.top),
    ),
    textStyles: const FlipTextStyles(),
    dimens: FlipDimens(
      cellRadius: core.dimens.radiusSmall / 2,
      cellSpacing: 3,
      boardPadding: 6,
      discInset: 0.12,
      ringWidth: 0.3,
      hintSize: 0.34,
    ),
  );

  FlipTheme copyWith({
    FlipColors? colors,
    FlipTextStyles? textStyles,
    FlipDimens? dimens,
  }) => FlipTheme(
    colors: colors ?? this.colors,
    textStyles: textStyles ?? this.textStyles,
    dimens: dimens ?? this.dimens,
  );
}

class FlipColors {
  /// Empty cell
  final Color cell;

  /// Cell of the last placed disc
  final Color lastMoveCell;

  /// Discs of Player 1 (bottom, filled discs)
  final Color bottomPlayer;

  /// Discs of Player 2 (top, ring discs)
  final Color topPlayer;

  const FlipColors({
    required this.cell,
    required this.lastMoveCell,
    required this.bottomPlayer,
    required this.topPlayer,
  });

  Color player(DuelPlayer player) => player == DuelPlayer.bottom ? bottomPlayer : topPlayer;

  FlipColors copyWith({
    Color? cell,
    Color? lastMoveCell,
    Color? bottomPlayer,
    Color? topPlayer,
  }) => FlipColors(
    cell: cell ?? this.cell,
    lastMoveCell: lastMoveCell ?? this.lastMoveCell,
    bottomPlayer: bottomPlayer ?? this.bottomPlayer,
    topPlayer: topPlayer ?? this.topPlayer,
  );
}

/// Flip has no text of its own: the turn banners are the shared `DuelTurnBanner` that uses
/// the core theme. Kept so the theme has the same shape as every other game theme.
class FlipTextStyles {
  const FlipTextStyles();

  FlipTextStyles copyWith() => const FlipTextStyles();
}

class FlipDimens {
  final double cellRadius;
  final double cellSpacing;
  final double boardPadding;

  /// Space between a disc and its cell edge, as a fraction of the cell size
  final double discInset;

  /// Ring width of Player 2's discs, as a fraction of the disc radius
  final double ringWidth;

  /// Size of a legal move hint, as a fraction of the cell size
  final double hintSize;

  const FlipDimens({
    required this.cellRadius,
    required this.cellSpacing,
    required this.boardPadding,
    required this.discInset,
    required this.ringWidth,
    required this.hintSize,
  });

  FlipDimens copyWith({
    double? cellRadius,
    double? cellSpacing,
    double? boardPadding,
    double? discInset,
    double? ringWidth,
    double? hintSize,
  }) => FlipDimens(
    cellRadius: cellRadius ?? this.cellRadius,
    cellSpacing: cellSpacing ?? this.cellSpacing,
    boardPadding: boardPadding ?? this.boardPadding,
    discInset: discInset ?? this.discInset,
    ringWidth: ringWidth ?? this.ringWidth,
    hintSize: hintSize ?? this.hintSize,
  );
}
