import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';

class WhackTheme extends GameTheme {
  final WhackColors colors;
  final WhackTextStyles textStyles;
  final WhackDimens dimens;

  static WhackTheme of(BuildContext context) => GameTheme.of<WhackTheme>(context);

  const WhackTheme({
    required this.colors,
    required this.textStyles,
    required this.dimens,
  });

  factory WhackTheme.fromCore(CoreGameTheme core) {
    final c = core.colors;
    return WhackTheme(
      colors: WhackColors(
        cell: c.surface,
        hole: Color.lerp(c.surface, c.text, 0.3)!,
        critter: c.primary,
        critterFace: c.onPrimary,
        decoy: c.error,
        decoyFace: c.onError,
        timeBar: c.primary,
        timeBarLow: c.error,
        timeBarTrack: c.surface,
      ),
      textStyles: WhackTextStyles(
        score: core.textStyles.title,
        time: core.textStyles.label,
        hit: core.textStyles.label.copyWith(color: c.primary),
        decoyHit: core.textStyles.label.copyWith(color: c.error),
      ),
      dimens: WhackDimens(
        cellRadius: core.dimens.radiusSmall,
        cellGap: 8,
        boardPadding: 12,
        timeBarHeight: 6,
        lowTimeSeconds: 5,
      ),
    );
  }

  WhackTheme copyWith({
    WhackColors? colors,
    WhackTextStyles? textStyles,
    WhackDimens? dimens,
  }) => WhackTheme(
    colors: colors ?? this.colors,
    textStyles: textStyles ?? this.textStyles,
    dimens: dimens ?? this.dimens,
  );
}

class WhackColors {
  /// Background of one hole's cell
  final Color cell;

  /// The hole the targets pop out of
  final Color hole;

  /// Body of the critters you should tap
  final Color critter;

  /// Eyes and smile of the critters
  final Color critterFace;

  /// Body of the spiky decoys you should not tap
  final Color decoy;

  /// Eyes and mouth of the decoys
  final Color decoyFace;

  /// Remaining time bar, [timeBarLow] in the last seconds
  final Color timeBar;
  final Color timeBarLow;
  final Color timeBarTrack;

  const WhackColors({
    required this.cell,
    required this.hole,
    required this.critter,
    required this.critterFace,
    required this.decoy,
    required this.decoyFace,
    required this.timeBar,
    required this.timeBarLow,
    required this.timeBarTrack,
  });

  WhackColors copyWith({
    Color? cell,
    Color? hole,
    Color? critter,
    Color? critterFace,
    Color? decoy,
    Color? decoyFace,
    Color? timeBar,
    Color? timeBarLow,
    Color? timeBarTrack,
  }) => WhackColors(
    cell: cell ?? this.cell,
    hole: hole ?? this.hole,
    critter: critter ?? this.critter,
    critterFace: critterFace ?? this.critterFace,
    decoy: decoy ?? this.decoy,
    decoyFace: decoyFace ?? this.decoyFace,
    timeBar: timeBar ?? this.timeBar,
    timeBarLow: timeBarLow ?? this.timeBarLow,
    timeBarTrack: timeBarTrack ?? this.timeBarTrack,
  );
}

class WhackTextStyles {
  final TextStyle score;

  /// Remaining time
  final TextStyle time;

  /// "+1" after tapping a critter
  final TextStyle hit;

  /// "-1" after tapping a decoy
  final TextStyle decoyHit;

  const WhackTextStyles({
    required this.score,
    required this.time,
    required this.hit,
    required this.decoyHit,
  });

  WhackTextStyles copyWith({
    TextStyle? score,
    TextStyle? time,
    TextStyle? hit,
    TextStyle? decoyHit,
  }) => WhackTextStyles(
    score: score ?? this.score,
    time: time ?? this.time,
    hit: hit ?? this.hit,
    decoyHit: decoyHit ?? this.decoyHit,
  );
}

class WhackDimens {
  final double cellRadius;

  /// Space between two cells
  final double cellGap;

  /// Space between the board edge and the cells
  final double boardPadding;
  final double timeBarHeight;

  /// The time bar turns [WhackColors.timeBarLow] below this many seconds
  final double lowTimeSeconds;

  const WhackDimens({
    required this.cellRadius,
    required this.cellGap,
    required this.boardPadding,
    required this.timeBarHeight,
    required this.lowTimeSeconds,
  });

  WhackDimens copyWith({
    double? cellRadius,
    double? cellGap,
    double? boardPadding,
    double? timeBarHeight,
    double? lowTimeSeconds,
  }) => WhackDimens(
    cellRadius: cellRadius ?? this.cellRadius,
    cellGap: cellGap ?? this.cellGap,
    boardPadding: boardPadding ?? this.boardPadding,
    timeBarHeight: timeBarHeight ?? this.timeBarHeight,
    lowTimeSeconds: lowTimeSeconds ?? this.lowTimeSeconds,
  );
}
