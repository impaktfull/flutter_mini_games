import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';

class TrailTheme extends GameTheme {
  final TrailColors colors;
  final TrailTextStyles textStyles;
  final TrailDimens dimens;

  static TrailTheme of(BuildContext context) => GameTheme.of<TrailTheme>(context);

  const TrailTheme({
    required this.colors,
    required this.textStyles,
    required this.dimens,
  });

  factory TrailTheme.fromCore(CoreGameTheme core) {
    return TrailTheme(
      colors: TrailColors(
        gridBackground: core.colors.background,
        gridShadow: core.colors.shadow,
        cellEmpty: core.colors.surface,
        pathLine: core.colors.primary,
        progress: core.colors.primary,
        checkpointBackground: core.colors.secondary,
        checkpointTargetBackground: core.colors.primary,
        checkpointCompletedBackground: core.colors.primary,
      ),
      textStyles: TrailTextStyles(
        header: core.textStyles.title,
        headerWin: core.textStyles.title,
        headerStuck: core.textStyles.title,
        checkpointNumber: core.textStyles.body.copyWith(color: core.colors.onSecondary),
        checkpointNumberHighlighted: core.textStyles.body.copyWith(color: core.colors.onPrimary),
        progress: core.textStyles.body,
      ),
      dimens: TrailDimens(
        gridRadius: core.dimens.radiusLarge,
        cellRadius: core.dimens.radiusSmall,
        lineThickness: 16,
        checkpointSize: 28,
      ),
    );
  }

  TrailTheme copyWith({
    TrailColors? colors,
    TrailTextStyles? textStyles,
    TrailDimens? dimens,
  }) => TrailTheme(
    colors: colors ?? this.colors,
    textStyles: textStyles ?? this.textStyles,
    dimens: dimens ?? this.dimens,
  );
}

class TrailColors {
  final Color gridBackground;

  /// Used with alpha for the shadow of the grid
  final Color gridShadow;
  final Color cellEmpty;

  /// Solid color of the trail, no alpha (avoids overlap artifacts)
  final Color pathLine;

  /// Icons and bars of the progress indicators
  final Color progress;
  final Color checkpointBackground;
  final Color checkpointTargetBackground;
  final Color checkpointCompletedBackground;

  const TrailColors({
    required this.gridBackground,
    required this.gridShadow,
    required this.cellEmpty,
    required this.pathLine,
    required this.progress,
    required this.checkpointBackground,
    required this.checkpointTargetBackground,
    required this.checkpointCompletedBackground,
  });

  TrailColors copyWith({
    Color? gridBackground,
    Color? gridShadow,
    Color? cellEmpty,
    Color? pathLine,
    Color? progress,
    Color? checkpointBackground,
    Color? checkpointTargetBackground,
    Color? checkpointCompletedBackground,
  }) => TrailColors(
    gridBackground: gridBackground ?? this.gridBackground,
    gridShadow: gridShadow ?? this.gridShadow,
    cellEmpty: cellEmpty ?? this.cellEmpty,
    pathLine: pathLine ?? this.pathLine,
    progress: progress ?? this.progress,
    checkpointBackground: checkpointBackground ?? this.checkpointBackground,
    checkpointTargetBackground: checkpointTargetBackground ?? this.checkpointTargetBackground,
    checkpointCompletedBackground: checkpointCompletedBackground ?? this.checkpointCompletedBackground,
  );
}

class TrailTextStyles {
  final TextStyle header;
  final TextStyle headerWin;
  final TextStyle headerStuck;

  /// Number on a checkpoint that is not visited yet
  final TextStyle checkpointNumber;

  /// Number on the current target and on visited checkpoints
  final TextStyle checkpointNumberHighlighted;
  final TextStyle progress;

  const TrailTextStyles({
    required this.header,
    required this.headerWin,
    required this.headerStuck,
    required this.checkpointNumber,
    required this.checkpointNumberHighlighted,
    required this.progress,
  });

  TrailTextStyles copyWith({
    TextStyle? header,
    TextStyle? headerWin,
    TextStyle? headerStuck,
    TextStyle? checkpointNumber,
    TextStyle? checkpointNumberHighlighted,
    TextStyle? progress,
  }) => TrailTextStyles(
    header: header ?? this.header,
    headerWin: headerWin ?? this.headerWin,
    headerStuck: headerStuck ?? this.headerStuck,
    checkpointNumber: checkpointNumber ?? this.checkpointNumber,
    checkpointNumberHighlighted: checkpointNumberHighlighted ?? this.checkpointNumberHighlighted,
    progress: progress ?? this.progress,
  );
}

class TrailDimens {
  final double gridRadius;
  final double cellRadius;
  final double lineThickness;
  final double checkpointSize;

  const TrailDimens({
    required this.gridRadius,
    required this.cellRadius,
    required this.lineThickness,
    required this.checkpointSize,
  });

  TrailDimens copyWith({
    double? gridRadius,
    double? cellRadius,
    double? lineThickness,
    double? checkpointSize,
  }) => TrailDimens(
    gridRadius: gridRadius ?? this.gridRadius,
    cellRadius: cellRadius ?? this.cellRadius,
    lineThickness: lineThickness ?? this.lineThickness,
    checkpointSize: checkpointSize ?? this.checkpointSize,
  );
}
