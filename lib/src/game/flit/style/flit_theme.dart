import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';

class FlitTheme extends GameTheme {
  final FlitColors colors;
  final FlitTextStyles textStyles;
  final FlitDimens dimens;

  static FlitTheme of(BuildContext context) => GameTheme.of<FlitTheme>(context);

  const FlitTheme({
    required this.colors,
    required this.textStyles,
    required this.dimens,
  });

  factory FlitTheme.fromCore(CoreGameTheme core) {
    return FlitTheme(
      colors: FlitColors(
        sky: core.colors.background,
        ground: core.colors.surface,
        groundLine: core.colors.textMuted,
        column: core.colors.textMuted,
        columnCap: core.colors.secondary,
        flyer: core.colors.primary,
        flyerWing: core.colors.onPrimary,
        flyerEye: core.colors.onPrimary,
        flyerPupil: core.colors.secondary,
        scoreBackground: core.colors.background,
      ),
      textStyles: FlitTextStyles(
        header: core.textStyles.title,
        score: core.textStyles.title.copyWith(fontSize: 48),
      ),
      dimens: FlitDimens(
        columnRadius: core.dimens.radiusSmall,
        columnCapHeight: 14,
        columnCapOverhang: 4,
        groundLineThickness: 3,
        scoreRadius: core.dimens.radiusLarge,
      ),
    );
  }

  FlitTheme copyWith({
    FlitColors? colors,
    FlitTextStyles? textStyles,
    FlitDimens? dimens,
  }) => FlitTheme(
    colors: colors ?? this.colors,
    textStyles: textStyles ?? this.textStyles,
    dimens: dimens ?? this.dimens,
  );
}

class FlitColors {
  /// Background of the playing field
  final Color sky;
  final Color ground;

  /// Line on top of the ground
  final Color groundLine;
  final Color column;

  /// Wider rim at the open end of a column
  final Color columnCap;

  /// Body of the flyer
  final Color flyer;
  final Color flyerWing;
  final Color flyerEye;
  final Color flyerPupil;

  /// Badge behind the score, keeps it readable on top of the columns
  final Color scoreBackground;

  const FlitColors({
    required this.sky,
    required this.ground,
    required this.groundLine,
    required this.column,
    required this.columnCap,
    required this.flyer,
    required this.flyerWing,
    required this.flyerEye,
    required this.flyerPupil,
    required this.scoreBackground,
  });

  FlitColors copyWith({
    Color? sky,
    Color? ground,
    Color? groundLine,
    Color? column,
    Color? columnCap,
    Color? flyer,
    Color? flyerWing,
    Color? flyerEye,
    Color? flyerPupil,
    Color? scoreBackground,
  }) => FlitColors(
    sky: sky ?? this.sky,
    ground: ground ?? this.ground,
    groundLine: groundLine ?? this.groundLine,
    column: column ?? this.column,
    columnCap: columnCap ?? this.columnCap,
    flyer: flyer ?? this.flyer,
    flyerWing: flyerWing ?? this.flyerWing,
    flyerEye: flyerEye ?? this.flyerEye,
    flyerPupil: flyerPupil ?? this.flyerPupil,
    scoreBackground: scoreBackground ?? this.scoreBackground,
  );
}

class FlitTextStyles {
  final TextStyle header;

  /// Big score at the top of the board
  final TextStyle score;

  const FlitTextStyles({
    required this.header,
    required this.score,
  });

  FlitTextStyles copyWith({
    TextStyle? header,
    TextStyle? score,
  }) => FlitTextStyles(
    header: header ?? this.header,
    score: score ?? this.score,
  );
}

class FlitDimens {
  /// Corner radius of the columns
  final double columnRadius;

  /// Height of the rim at the open end of a column
  final double columnCapHeight;

  /// How far the rim sticks out on each side of a column
  final double columnCapOverhang;
  final double groundLineThickness;

  /// Corner radius of the badge behind the score
  final double scoreRadius;

  const FlitDimens({
    required this.columnRadius,
    required this.columnCapHeight,
    required this.columnCapOverhang,
    required this.groundLineThickness,
    required this.scoreRadius,
  });

  FlitDimens copyWith({
    double? columnRadius,
    double? columnCapHeight,
    double? columnCapOverhang,
    double? groundLineThickness,
    double? scoreRadius,
  }) => FlitDimens(
    columnRadius: columnRadius ?? this.columnRadius,
    columnCapHeight: columnCapHeight ?? this.columnCapHeight,
    columnCapOverhang: columnCapOverhang ?? this.columnCapOverhang,
    groundLineThickness: groundLineThickness ?? this.groundLineThickness,
    scoreRadius: scoreRadius ?? this.scoreRadius,
  );
}
