import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';

class FourUpTheme extends GameTheme {
  final FourUpColors colors;
  final FourUpTextStyles textStyles;
  final FourUpDimens dimens;

  static FourUpTheme of(BuildContext context) => GameTheme.of<FourUpTheme>(context);

  const FourUpTheme({
    required this.colors,
    required this.textStyles,
    required this.dimens,
  });

  factory FourUpTheme.fromCore(CoreGameTheme core) => FourUpTheme(
    colors: FourUpColors(
      slot: core.colors.surface,
      bottomDisc: core.playerColor(DuelPlayer.bottom),
      onBottomDisc: core.onPlayerColor(DuelPlayer.bottom),
      topDisc: core.playerColor(DuelPlayer.top),
      onTopDisc: core.onPlayerColor(DuelPlayer.top),
      winHighlight: core.colors.text,
    ),
    textStyles: const FourUpTextStyles(),
    dimens: const FourUpDimens(
      boardPadding: 4,
      discSizeFactor: 0.8,
      patternStrokeWidth: 2.5,
      winRingWidth: 3,
    ),
  );

  FourUpTheme copyWith({
    FourUpColors? colors,
    FourUpTextStyles? textStyles,
    FourUpDimens? dimens,
  }) => FourUpTheme(
    colors: colors ?? this.colors,
    textStyles: textStyles ?? this.textStyles,
    dimens: dimens ?? this.dimens,
  );
}

class FourUpColors {
  /// Empty slots of the grid
  final Color slot;

  /// Discs of [DuelPlayer.bottom]
  final Color bottomDisc;

  /// Pattern on the discs of [DuelPlayer.bottom]
  final Color onBottomDisc;

  /// Discs of [DuelPlayer.top]
  final Color topDisc;

  /// Pattern on the discs of [DuelPlayer.top]
  final Color onTopDisc;

  /// Ring around the discs of the winning line
  final Color winHighlight;

  const FourUpColors({
    required this.slot,
    required this.bottomDisc,
    required this.onBottomDisc,
    required this.topDisc,
    required this.onTopDisc,
    required this.winHighlight,
  });

  Color disc(DuelPlayer player) => player == DuelPlayer.bottom ? bottomDisc : topDisc;

  Color onDisc(DuelPlayer player) => player == DuelPlayer.bottom ? onBottomDisc : onTopDisc;

  FourUpColors copyWith({
    Color? slot,
    Color? bottomDisc,
    Color? onBottomDisc,
    Color? topDisc,
    Color? onTopDisc,
    Color? winHighlight,
  }) => FourUpColors(
    slot: slot ?? this.slot,
    bottomDisc: bottomDisc ?? this.bottomDisc,
    onBottomDisc: onBottomDisc ?? this.onBottomDisc,
    topDisc: topDisc ?? this.topDisc,
    onTopDisc: onTopDisc ?? this.onTopDisc,
    winHighlight: winHighlight ?? this.winHighlight,
  );
}

/// Four Up has no text of its own: the turn banners are the shared `DuelTurnBanner` that uses
/// the core theme. Kept so the theme has the same shape as every other game theme.
class FourUpTextStyles {
  const FourUpTextStyles();

  FourUpTextStyles copyWith() => const FourUpTextStyles();
}

class FourUpDimens {
  /// Space between the board frame and the slots
  final double boardPadding;

  /// Disc diameter as a fraction of the cell size
  final double discSizeFactor;

  /// Stroke of the pattern that tells the discs apart without color
  final double patternStrokeWidth;

  /// Ring around the discs of the winning line
  final double winRingWidth;

  const FourUpDimens({
    required this.boardPadding,
    required this.discSizeFactor,
    required this.patternStrokeWidth,
    required this.winRingWidth,
  });

  FourUpDimens copyWith({
    double? boardPadding,
    double? discSizeFactor,
    double? patternStrokeWidth,
    double? winRingWidth,
  }) => FourUpDimens(
    boardPadding: boardPadding ?? this.boardPadding,
    discSizeFactor: discSizeFactor ?? this.discSizeFactor,
    patternStrokeWidth: patternStrokeWidth ?? this.patternStrokeWidth,
    winRingWidth: winRingWidth ?? this.winRingWidth,
  );
}
