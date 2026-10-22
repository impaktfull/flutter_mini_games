import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';

class TilesTheme extends GameTheme {
  final TilesColors colors;
  final TilesTextStyles textStyles;
  final TilesDimens dimens;

  static TilesTheme of(BuildContext context) => GameTheme.of<TilesTheme>(context);

  const TilesTheme({
    required this.colors,
    required this.textStyles,
    required this.dimens,
  });

  factory TilesTheme.fromCore(CoreGameTheme core) {
    final c = core.colors;
    return TilesTheme(
      colors: TilesColors(
        lightTile: c.background,
        gridLine: c.surface,
        darkTile: c.secondary,
        darkTileLabel: c.onSecondary,
        tappedTile: Color.lerp(c.background, c.secondary, 0.15)!,
        flash: c.primary,
        mistake: c.error,
        mistakeMark: c.onError,
      ),
      textStyles: TilesTextStyles(
        score: core.textStyles.title,
        speed: core.textStyles.label,
        startLabel: core.textStyles.label.copyWith(color: c.onSecondary),
      ),
      dimens: TilesDimens(
        gridLineWidth: 1.5,
        tileInset: 2,
        tileRadius: core.dimens.radiusSmall / 2,
        markStrokeWidth: 5,
      ),
    );
  }

  TilesTheme copyWith({
    TilesColors? colors,
    TilesTextStyles? textStyles,
    TilesDimens? dimens,
  }) => TilesTheme(
    colors: colors ?? this.colors,
    textStyles: textStyles ?? this.textStyles,
    dimens: dimens ?? this.dimens,
  );
}

class TilesColors {
  /// Tiles you should not tap
  final Color lightTile;

  /// Lines between the tiles
  final Color gridLine;

  /// The tile to tap in every row
  final Color darkTile;

  /// "Start" on the first dark tile
  final Color darkTileLabel;

  /// A dark tile after it was tapped
  final Color tappedTile;

  /// Short flash on a tile that was tapped correctly, fades to [tappedTile]
  final Color flash;

  /// The tile that ended the game (wrong tap or missed tile)
  final Color mistake;

  /// Cross or ring on the [mistake] tile
  final Color mistakeMark;

  const TilesColors({
    required this.lightTile,
    required this.gridLine,
    required this.darkTile,
    required this.darkTileLabel,
    required this.tappedTile,
    required this.flash,
    required this.mistake,
    required this.mistakeMark,
  });

  TilesColors copyWith({
    Color? lightTile,
    Color? gridLine,
    Color? darkTile,
    Color? darkTileLabel,
    Color? tappedTile,
    Color? flash,
    Color? mistake,
    Color? mistakeMark,
  }) => TilesColors(
    lightTile: lightTile ?? this.lightTile,
    gridLine: gridLine ?? this.gridLine,
    darkTile: darkTile ?? this.darkTile,
    darkTileLabel: darkTileLabel ?? this.darkTileLabel,
    tappedTile: tappedTile ?? this.tappedTile,
    flash: flash ?? this.flash,
    mistake: mistake ?? this.mistake,
    mistakeMark: mistakeMark ?? this.mistakeMark,
  );
}

class TilesTextStyles {
  /// Score in the header
  final TextStyle score;

  /// Speed in the header
  final TextStyle speed;

  /// "Start" on the first dark tile
  final TextStyle startLabel;

  const TilesTextStyles({
    required this.score,
    required this.speed,
    required this.startLabel,
  });

  TilesTextStyles copyWith({
    TextStyle? score,
    TextStyle? speed,
    TextStyle? startLabel,
  }) => TilesTextStyles(
    score: score ?? this.score,
    speed: speed ?? this.speed,
    startLabel: startLabel ?? this.startLabel,
  );
}

class TilesDimens {
  /// Width of the lines between the tiles
  final double gridLineWidth;

  /// Space between a dark tile and its cell edge
  final double tileInset;
  final double tileRadius;

  /// Line width of the cross and ring on the mistake tile
  final double markStrokeWidth;

  const TilesDimens({
    required this.gridLineWidth,
    required this.tileInset,
    required this.tileRadius,
    required this.markStrokeWidth,
  });

  TilesDimens copyWith({
    double? gridLineWidth,
    double? tileInset,
    double? tileRadius,
    double? markStrokeWidth,
  }) => TilesDimens(
    gridLineWidth: gridLineWidth ?? this.gridLineWidth,
    tileInset: tileInset ?? this.tileInset,
    tileRadius: tileRadius ?? this.tileRadius,
    markStrokeWidth: markStrokeWidth ?? this.markStrokeWidth,
  );
}
