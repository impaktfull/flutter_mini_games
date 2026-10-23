import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';

class SnatchTheme extends GameTheme {
  final SnatchColors colors;
  final SnatchTextStyles textStyles;
  final SnatchDimens dimens;

  static SnatchTheme of(BuildContext context) => GameTheme.of<SnatchTheme>(context);

  const SnatchTheme({
    required this.colors,
    required this.textStyles,
    required this.dimens,
  });

  factory SnatchTheme.fromCore(CoreGameTheme core) {
    final c = core.colors;
    return SnatchTheme(
      colors: SnatchColors(
        tile: c.surface,
        bottomPlayer: core.playerColor(DuelPlayer.bottom),
        onBottomPlayer: core.onPlayerColor(DuelPlayer.bottom),
        topPlayer: core.playerColor(DuelPlayer.top),
        onTopPlayer: core.onPlayerColor(DuelPlayer.top),
        symbol: c.text,
        lockedSymbol: c.textMuted,
        missedBorder: c.textMuted,
        wrongTile: c.error,
        onWrongTile: c.onError,
        center: c.surface,
        target: c.text,
        hiddenTarget: c.textMuted,
      ),
      textStyles: SnatchTextStyles(
        points: core.textStyles.label,
        hiddenTarget: core.textStyles.title.copyWith(color: c.textMuted),
      ),
      dimens: SnatchDimens(
        tileRadius: core.dimens.radiusSmall,
        tileGap: 10,
        halfPadding: core.dimens.padding,
        scoreSpace: 28,
        symbolScale: 0.6,
        missedBorderWidth: 3,
        centerHeight: 72,
        targetSize: 44,
      ),
    );
  }

  SnatchTheme copyWith({
    SnatchColors? colors,
    SnatchTextStyles? textStyles,
    SnatchDimens? dimens,
  }) => SnatchTheme(
    colors: colors ?? this.colors,
    textStyles: textStyles ?? this.textStyles,
    dimens: dimens ?? this.dimens,
  );
}

/// Player colors (the tile that scored, the center after a point) are the [bottomPlayer] /
/// [topPlayer] tokens, derived from `CoreGameTheme.playerColor`
class SnatchColors {
  final Color tile;

  /// Player 1 (bottom) and Player 2 (top), [onBottomPlayer] / [onTopPlayer] for text and icons on them
  final Color bottomPlayer;
  final Color onBottomPlayer;
  final Color topPlayer;
  final Color onTopPlayer;
  final Color symbol;

  /// Symbols of a half that is locked after a wrong tap
  final Color lockedSymbol;

  /// Ring around the matching tile in the half of the player that was too slow
  final Color missedBorder;

  /// A wrongly tapped tile
  final Color wrongTile;
  final Color onWrongTile;

  /// Bar in the middle that shows the target
  final Color center;
  final Color target;

  /// Placeholder before the round starts
  final Color hiddenTarget;

  const SnatchColors({
    required this.tile,
    required this.bottomPlayer,
    required this.onBottomPlayer,
    required this.topPlayer,
    required this.onTopPlayer,
    required this.symbol,
    required this.lockedSymbol,
    required this.missedBorder,
    required this.wrongTile,
    required this.onWrongTile,
    required this.center,
    required this.target,
    required this.hiddenTarget,
  });

  /// Color of [player]
  Color playerColor(DuelPlayer player) => player == DuelPlayer.bottom ? bottomPlayer : topPlayer;

  /// Text and icons on [playerColor]
  Color onPlayerColor(DuelPlayer player) => player == DuelPlayer.bottom ? onBottomPlayer : onTopPlayer;

  SnatchColors copyWith({
    Color? tile,
    Color? bottomPlayer,
    Color? onBottomPlayer,
    Color? topPlayer,
    Color? onTopPlayer,
    Color? symbol,
    Color? lockedSymbol,
    Color? missedBorder,
    Color? wrongTile,
    Color? onWrongTile,
    Color? center,
    Color? target,
    Color? hiddenTarget,
  }) => SnatchColors(
    tile: tile ?? this.tile,
    bottomPlayer: bottomPlayer ?? this.bottomPlayer,
    onBottomPlayer: onBottomPlayer ?? this.onBottomPlayer,
    topPlayer: topPlayer ?? this.topPlayer,
    onTopPlayer: onTopPlayer ?? this.onTopPlayer,
    symbol: symbol ?? this.symbol,
    lockedSymbol: lockedSymbol ?? this.lockedSymbol,
    missedBorder: missedBorder ?? this.missedBorder,
    wrongTile: wrongTile ?? this.wrongTile,
    onWrongTile: onWrongTile ?? this.onWrongTile,
    center: center ?? this.center,
    target: target ?? this.target,
    hiddenTarget: hiddenTarget ?? this.hiddenTarget,
  );
}

class SnatchTextStyles {
  /// "+1" / "-1" on a tapped tile (the color is set per tile)
  final TextStyle points;

  /// "?" in the middle before the target is shown
  final TextStyle hiddenTarget;

  const SnatchTextStyles({
    required this.points,
    required this.hiddenTarget,
  });

  SnatchTextStyles copyWith({
    TextStyle? points,
    TextStyle? hiddenTarget,
  }) => SnatchTextStyles(
    points: points ?? this.points,
    hiddenTarget: hiddenTarget ?? this.hiddenTarget,
  );
}

class SnatchDimens {
  final double tileRadius;

  /// Space between two tiles
  final double tileGap;

  /// Space around the tiles of a half
  final double halfPadding;

  /// Space kept free below the tiles for the score of the shared duel overlay
  final double scoreSpace;

  /// Symbol size relative to the tile size
  final double symbolScale;
  final double missedBorderWidth;

  /// Height of the bar in the middle
  final double centerHeight;
  final double targetSize;

  const SnatchDimens({
    required this.tileRadius,
    required this.tileGap,
    required this.halfPadding,
    required this.scoreSpace,
    required this.symbolScale,
    required this.missedBorderWidth,
    required this.centerHeight,
    required this.targetSize,
  });

  SnatchDimens copyWith({
    double? tileRadius,
    double? tileGap,
    double? halfPadding,
    double? scoreSpace,
    double? symbolScale,
    double? missedBorderWidth,
    double? centerHeight,
    double? targetSize,
  }) => SnatchDimens(
    tileRadius: tileRadius ?? this.tileRadius,
    tileGap: tileGap ?? this.tileGap,
    halfPadding: halfPadding ?? this.halfPadding,
    scoreSpace: scoreSpace ?? this.scoreSpace,
    symbolScale: symbolScale ?? this.symbolScale,
    missedBorderWidth: missedBorderWidth ?? this.missedBorderWidth,
    centerHeight: centerHeight ?? this.centerHeight,
    targetSize: targetSize ?? this.targetSize,
  );
}
