import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';

class PuckTheme extends GameTheme {
  final PuckColors colors;
  final PuckTextStyles textStyles;
  final PuckDimens dimens;

  static PuckTheme of(BuildContext context) => GameTheme.of<PuckTheme>(context);

  const PuckTheme({
    required this.colors,
    required this.textStyles,
    required this.dimens,
  });

  factory PuckTheme.fromCore(CoreGameTheme core) {
    final score = core.textStyles.title.copyWith(fontSize: 32);
    return PuckTheme(
      colors: PuckColors(
        table: core.colors.surface,
        line: core.colors.background,
        bottomPlayer: core.playerColor(DuelPlayer.bottom),
        onBottomPlayer: core.onPlayerColor(DuelPlayer.bottom),
        topPlayer: core.playerColor(DuelPlayer.top),
        onTopPlayer: core.onPlayerColor(DuelPlayer.top),
        puck: core.colors.text,
        puckRing: core.colors.textMuted,
      ),
      textStyles: PuckTextStyles(
        bottomScore: score.copyWith(color: core.playerColor(DuelPlayer.bottom)),
        topScore: score.copyWith(color: core.playerColor(DuelPlayer.top)),
      ),
      dimens: PuckDimens(
        lineWidth: 3,
        goalThickness: 6,
        malletRingWidth: 3,
        scoreMargin: core.dimens.padding,
      ),
    );
  }

  /// Color of the mallet and the goal of [player]
  Color playerColor(DuelPlayer player) => player == DuelPlayer.bottom ? colors.bottomPlayer : colors.topPlayer;

  /// Color on top of [playerColor], e.g. the ring of a mallet
  Color onPlayerColor(DuelPlayer player) => player == DuelPlayer.bottom ? colors.onBottomPlayer : colors.onTopPlayer;

  PuckTheme copyWith({
    PuckColors? colors,
    PuckTextStyles? textStyles,
    PuckDimens? dimens,
  }) => PuckTheme(
    colors: colors ?? this.colors,
    textStyles: textStyles ?? this.textStyles,
    dimens: dimens ?? this.dimens,
  );
}

class PuckColors {
  /// Surface of the table
  final Color table;

  /// Center line, center circle and goal areas
  final Color line;

  /// Mallet and goal of Player 1 (bottom)
  final Color bottomPlayer;
  final Color onBottomPlayer;

  /// Mallet and goal of Player 2 (top)
  final Color topPlayer;
  final Color onTopPlayer;
  final Color puck;

  /// Ring on top of the puck
  final Color puckRing;

  const PuckColors({
    required this.table,
    required this.line,
    required this.bottomPlayer,
    required this.onBottomPlayer,
    required this.topPlayer,
    required this.onTopPlayer,
    required this.puck,
    required this.puckRing,
  });

  PuckColors copyWith({
    Color? table,
    Color? line,
    Color? bottomPlayer,
    Color? onBottomPlayer,
    Color? topPlayer,
    Color? onTopPlayer,
    Color? puck,
    Color? puckRing,
  }) => PuckColors(
    table: table ?? this.table,
    line: line ?? this.line,
    bottomPlayer: bottomPlayer ?? this.bottomPlayer,
    onBottomPlayer: onBottomPlayer ?? this.onBottomPlayer,
    topPlayer: topPlayer ?? this.topPlayer,
    onTopPlayer: onTopPlayer ?? this.onTopPlayer,
    puck: puck ?? this.puck,
    puckRing: puckRing ?? this.puckRing,
  );
}

class PuckTextStyles {
  /// Goals of Player 1, painted on the table next to the center line
  final TextStyle bottomScore;

  /// Goals of Player 2, painted upside down for the opposite player
  final TextStyle topScore;

  const PuckTextStyles({
    required this.bottomScore,
    required this.topScore,
  });

  PuckTextStyles copyWith({
    TextStyle? bottomScore,
    TextStyle? topScore,
  }) => PuckTextStyles(
    bottomScore: bottomScore ?? this.bottomScore,
    topScore: topScore ?? this.topScore,
  );
}

class PuckDimens {
  /// Width of the center line and the center circle in pixels
  final double lineWidth;

  /// Thickness of the colored goal mouths in pixels
  final double goalThickness;

  /// Width of the ring on top of the mallets and the puck in pixels
  final double malletRingWidth;

  /// Distance between the scores and the right edge of the table
  final double scoreMargin;

  const PuckDimens({
    required this.lineWidth,
    required this.goalThickness,
    required this.malletRingWidth,
    required this.scoreMargin,
  });

  PuckDimens copyWith({
    double? lineWidth,
    double? goalThickness,
    double? malletRingWidth,
    double? scoreMargin,
  }) => PuckDimens(
    lineWidth: lineWidth ?? this.lineWidth,
    goalThickness: goalThickness ?? this.goalThickness,
    malletRingWidth: malletRingWidth ?? this.malletRingWidth,
    scoreMargin: scoreMargin ?? this.scoreMargin,
  );
}
