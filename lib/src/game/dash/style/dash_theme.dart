import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';

class DashTheme extends GameTheme {
  final DashColors colors;
  final DashTextStyles textStyles;
  final DashDimens dimens;

  static DashTheme of(BuildContext context) => GameTheme.of<DashTheme>(context);

  const DashTheme({
    required this.colors,
    required this.textStyles,
    required this.dimens,
  });

  factory DashTheme.fromCore(CoreGameTheme core) {
    return DashTheme(
      colors: DashColors(
        runner: core.colors.primary,
        runnerEye: core.colors.onPrimary,
        runnerPupil: core.colors.secondary,
        obstacle: core.colors.secondary,
        obstacleDetail: core.colors.onSecondary,
        ground: core.colors.textMuted,
        cloud: core.colors.surface,
      ),
      textStyles: DashTextStyles(
        score: core.textStyles.title,
        status: core.textStyles.body.copyWith(color: core.colors.textMuted),
      ),
      dimens: const DashDimens(
        groundThickness: 2,
        obstacleRadius: 4,
        runnerRadius: 8,
      ),
    );
  }

  DashTheme copyWith({
    DashColors? colors,
    DashTextStyles? textStyles,
    DashDimens? dimens,
  }) => DashTheme(
    colors: colors ?? this.colors,
    textStyles: textStyles ?? this.textStyles,
    dimens: dimens ?? this.dimens,
  );
}

class DashColors {
  /// Body and legs of the runner
  final Color runner;
  final Color runnerEye;
  final Color runnerPupil;

  /// Blocks and flyers
  final Color obstacle;

  /// Seams on blocks and eyes of flyers, drawn on [obstacle]
  final Color obstacleDetail;

  /// Ground line and pebbles
  final Color ground;

  /// Clouds in the background
  final Color cloud;

  const DashColors({
    required this.runner,
    required this.runnerEye,
    required this.runnerPupil,
    required this.obstacle,
    required this.obstacleDetail,
    required this.ground,
    required this.cloud,
  });

  DashColors copyWith({
    Color? runner,
    Color? runnerEye,
    Color? runnerPupil,
    Color? obstacle,
    Color? obstacleDetail,
    Color? ground,
    Color? cloud,
  }) => DashColors(
    runner: runner ?? this.runner,
    runnerEye: runnerEye ?? this.runnerEye,
    runnerPupil: runnerPupil ?? this.runnerPupil,
    obstacle: obstacle ?? this.obstacle,
    obstacleDetail: obstacleDetail ?? this.obstacleDetail,
    ground: ground ?? this.ground,
    cloud: cloud ?? this.cloud,
  );
}

class DashTextStyles {
  /// Live score in the header
  final TextStyle score;

  /// Status line below the score
  final TextStyle status;

  const DashTextStyles({
    required this.score,
    required this.status,
  });

  DashTextStyles copyWith({
    TextStyle? score,
    TextStyle? status,
  }) => DashTextStyles(
    score: score ?? this.score,
    status: status ?? this.status,
  );
}

class DashDimens {
  /// Ground line thickness in logical pixels
  final double groundThickness;

  /// Corner radius of blocks in logical pixels
  final double obstacleRadius;

  /// Corner radius of the runner's body in logical pixels
  final double runnerRadius;

  const DashDimens({
    required this.groundThickness,
    required this.obstacleRadius,
    required this.runnerRadius,
  });

  DashDimens copyWith({
    double? groundThickness,
    double? obstacleRadius,
    double? runnerRadius,
  }) => DashDimens(
    groundThickness: groundThickness ?? this.groundThickness,
    obstacleRadius: obstacleRadius ?? this.obstacleRadius,
    runnerRadius: runnerRadius ?? this.runnerRadius,
  );
}
