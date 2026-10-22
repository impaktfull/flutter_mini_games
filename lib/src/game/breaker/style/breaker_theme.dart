import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';

class BreakerTheme extends GameTheme {
  final BreakerColors colors;
  final BreakerTextStyles textStyles;
  final BreakerDimens dimens;

  static BreakerTheme of(BuildContext context) => GameTheme.of<BreakerTheme>(context);

  const BreakerTheme({
    required this.colors,
    required this.textStyles,
    required this.dimens,
  });

  factory BreakerTheme.fromCore(CoreGameTheme core) {
    return BreakerTheme(
      colors: BreakerColors(
        background: core.colors.background,
        bricks: [core.colors.error, core.colors.primary, core.colors.secondary],
        paddle: core.colors.primary,
        ball: core.colors.text,
        lives: core.colors.error,
        livesLost: core.colors.textMuted,
        score: core.colors.primary,
      ),
      textStyles: BreakerTextStyles(
        score: core.textStyles.title,
        label: core.textStyles.caption,
      ),
      dimens: BreakerDimens(
        brickRadius: core.dimens.radiusSmall / 2,
      ),
    );
  }

  BreakerTheme copyWith({
    BreakerColors? colors,
    BreakerTextStyles? textStyles,
    BreakerDimens? dimens,
  }) => BreakerTheme(
    colors: colors ?? this.colors,
    textStyles: textStyles ?? this.textStyles,
    dimens: dimens ?? this.dimens,
  );
}

class BreakerColors {
  /// Background of the playing field
  final Color background;

  /// Brick colors from the top row to the bottom row, the rows in between are blended
  final List<Color> bricks;

  final Color paddle;
  final Color ball;

  /// Hearts of the remaining lives in the header
  final Color lives;

  /// Hearts of the lost lives in the header
  final Color livesLost;

  /// Score icon in the header
  final Color score;

  const BreakerColors({
    required this.background,
    required this.bricks,
    required this.paddle,
    required this.ball,
    required this.lives,
    required this.livesLost,
    required this.score,
  });

  /// Color of brick [row] out of [rowCount] rows: blends along [bricks] from top to bottom
  Color brickColor(int row, int rowCount) {
    if (bricks.length == 1 || rowCount <= 1) return bricks.first;
    final position = row / (rowCount - 1) * (bricks.length - 1);
    final index = position.floor().clamp(0, bricks.length - 2);
    return Color.lerp(bricks[index], bricks[index + 1], position - index)!;
  }

  BreakerColors copyWith({
    Color? background,
    List<Color>? bricks,
    Color? paddle,
    Color? ball,
    Color? lives,
    Color? livesLost,
    Color? score,
  }) => BreakerColors(
    background: background ?? this.background,
    bricks: bricks ?? this.bricks,
    paddle: paddle ?? this.paddle,
    ball: ball ?? this.ball,
    lives: lives ?? this.lives,
    livesLost: livesLost ?? this.livesLost,
    score: score ?? this.score,
  );
}

class BreakerTextStyles {
  /// Score in the header
  final TextStyle score;

  /// Labels in the header (level)
  final TextStyle label;

  const BreakerTextStyles({
    required this.score,
    required this.label,
  });

  BreakerTextStyles copyWith({
    TextStyle? score,
    TextStyle? label,
  }) => BreakerTextStyles(
    score: score ?? this.score,
    label: label ?? this.label,
  );
}

class BreakerDimens {
  /// Corner radius of a brick in logical pixels
  final double brickRadius;

  const BreakerDimens({
    required this.brickRadius,
  });

  BreakerDimens copyWith({
    double? brickRadius,
  }) => BreakerDimens(
    brickRadius: brickRadius ?? this.brickRadius,
  );
}
