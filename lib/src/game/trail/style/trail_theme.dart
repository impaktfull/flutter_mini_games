import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';

class TrailTheme extends GameTheme {
  final TrailColors colors;
  final TrailTextStyles textStyles;
  final TrailDimens dimens;

  static TrailTheme of(BuildContext context) => GameTheme.of<TrailTheme>(context);

  TrailTheme({
    required this.colors,
    required this.textStyles,
    required this.dimens,
  });

  static TrailTheme getDefault({
    required CoreGameTheme coreTheme,
  }) {
    return TrailTheme(
      colors: TrailColors(
        cellEmpty: coreTheme.colors.background,
        cellFilled: coreTheme.colors.primary,
        pathLine: coreTheme.colors.primary,
        checkpointBackground: coreTheme.colors.secondary,
        checkpointText: coreTheme.colors.textInverted,
        checkpointTargetBackground: coreTheme.colors.primary,
        checkpointCompletedBackground: coreTheme.colors.primary,
        gridBackground: coreTheme.colors.card2,
        howToPlayBackground: coreTheme.colors.background,
        shadow: coreTheme.colors.secondary,
      ),
      textStyles: TrailTextStyles(
        header: coreTheme.textStyles.title,
        headerWin: coreTheme.textStyles.title,
        headerLose: coreTheme.textStyles.title,
        checkpointNumber: coreTheme.textStyles.body.copyWith(
          color: coreTheme.colors.textInverted,
        ),
        progress: coreTheme.textStyles.body,
      ),
      dimens: TrailDimens.getDefault(),
    );
  }
}

class TrailColors {
  final Color cellEmpty;
  final Color cellFilled;
  final Color pathLine;
  final Color checkpointBackground;
  final Color checkpointText;
  final Color checkpointTargetBackground;
  final Color checkpointCompletedBackground;
  final Color gridBackground;
  final Color howToPlayBackground;
  final Color shadow;

  TrailColors({
    required this.cellEmpty,
    required this.cellFilled,
    required this.pathLine,
    required this.checkpointBackground,
    required this.checkpointText,
    required this.checkpointTargetBackground,
    required this.checkpointCompletedBackground,
    required this.gridBackground,
    required this.howToPlayBackground,
    required this.shadow,
  });
}

class TrailTextStyles {
  final TextStyle header;
  final TextStyle headerWin;
  final TextStyle headerLose;
  final TextStyle checkpointNumber;
  final TextStyle progress;

  TrailTextStyles({
    required this.header,
    required this.headerWin,
    required this.headerLose,
    required this.checkpointNumber,
    required this.progress,
  });
}

class TrailDimens {
  final double lineThickness;
  final double checkpointSize;

  const TrailDimens({
    required this.lineThickness,
    required this.checkpointSize,
  });

  static TrailDimens getDefault() => const TrailDimens(
    lineThickness: 16,
    checkpointSize: 28,
  );
}
