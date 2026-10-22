import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';

class TwentyFortyEightTheme extends GameTheme {
  final TwentyFortyEightColors colors;
  final TwentyFortyEightTextStyles textStyles;
  final TwentyFortyEightDimens dimens;

  static TwentyFortyEightTheme of(BuildContext context) => GameTheme.of<TwentyFortyEightTheme>(context);

  const TwentyFortyEightTheme({
    required this.colors,
    required this.textStyles,
    required this.dimens,
  });

  factory TwentyFortyEightTheme.fromCore(CoreGameTheme core) {
    return TwentyFortyEightTheme(
      colors: TwentyFortyEightColors(
        emptyCell: core.colors.surface,
        // The lowest tile is tinted a little so it stands out from the empty cells
        tileLow: Color.lerp(core.colors.surface, core.colors.primary, 0.2)!,
        tileHigh: core.colors.primary,
        tileTextLow: core.colors.text,
        tileTextHigh: core.colors.onPrimary,
      ),
      textStyles: TwentyFortyEightTextStyles(
        header: core.textStyles.title,
        score: core.textStyles.body,
        tile: core.textStyles.title,
      ),
      dimens: TwentyFortyEightDimens(
        boardPadding: 8,
        cellSpacing: 8,
        tileRadius: core.dimens.radiusSmall,
      ),
    );
  }

  TwentyFortyEightTheme copyWith({
    TwentyFortyEightColors? colors,
    TwentyFortyEightTextStyles? textStyles,
    TwentyFortyEightDimens? dimens,
  }) => TwentyFortyEightTheme(
    colors: colors ?? this.colors,
    textStyles: textStyles ?? this.textStyles,
    dimens: dimens ?? this.dimens,
  );
}

class TwentyFortyEightColors {
  final Color emptyCell;

  /// Color of the 2 tile, higher tiles blend towards [tileHigh]
  final Color tileLow;

  /// Color of the 2048 tile
  final Color tileHigh;

  /// Tile text candidates, the one with the best contrast on the tile is used
  final Color tileTextLow;
  final Color tileTextHigh;

  const TwentyFortyEightColors({
    required this.emptyCell,
    required this.tileLow,
    required this.tileHigh,
    required this.tileTextLow,
    required this.tileTextHigh,
  });

  /// Background of a tile: blends from [tileLow] (2) to [tileHigh] (2048) by log2 of [value]
  Color tile(int value) {
    final step = value <= 2 ? 0.0 : (log(value) / ln2 - 1) / 10;
    return Color.lerp(tileLow, tileHigh, step.clamp(0.0, 1.0))!;
  }

  /// Text on a tile: [tileTextLow] or [tileTextHigh], whichever contrasts most with the tile
  Color tileText(int value) {
    final background = tile(value);
    return _contrast(background, tileTextLow) >= _contrast(background, tileTextHigh) ? tileTextLow : tileTextHigh;
  }

  static double _contrast(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    return (max(la, lb) + 0.05) / (min(la, lb) + 0.05);
  }

  TwentyFortyEightColors copyWith({
    Color? emptyCell,
    Color? tileLow,
    Color? tileHigh,
    Color? tileTextLow,
    Color? tileTextHigh,
  }) => TwentyFortyEightColors(
    emptyCell: emptyCell ?? this.emptyCell,
    tileLow: tileLow ?? this.tileLow,
    tileHigh: tileHigh ?? this.tileHigh,
    tileTextLow: tileTextLow ?? this.tileTextLow,
    tileTextHigh: tileTextHigh ?? this.tileTextHigh,
  );
}

class TwentyFortyEightTextStyles {
  final TextStyle header;
  final TextStyle score;

  /// Number on a tile, scaled down to fit and colored with `TwentyFortyEightColors.tileText`
  final TextStyle tile;

  const TwentyFortyEightTextStyles({
    required this.header,
    required this.score,
    required this.tile,
  });

  TwentyFortyEightTextStyles copyWith({
    TextStyle? header,
    TextStyle? score,
    TextStyle? tile,
  }) => TwentyFortyEightTextStyles(
    header: header ?? this.header,
    score: score ?? this.score,
    tile: tile ?? this.tile,
  );
}

class TwentyFortyEightDimens {
  final double boardPadding;
  final double cellSpacing;
  final double tileRadius;

  const TwentyFortyEightDimens({
    required this.boardPadding,
    required this.cellSpacing,
    required this.tileRadius,
  });

  TwentyFortyEightDimens copyWith({
    double? boardPadding,
    double? cellSpacing,
    double? tileRadius,
  }) => TwentyFortyEightDimens(
    boardPadding: boardPadding ?? this.boardPadding,
    cellSpacing: cellSpacing ?? this.cellSpacing,
    tileRadius: tileRadius ?? this.tileRadius,
  );
}
