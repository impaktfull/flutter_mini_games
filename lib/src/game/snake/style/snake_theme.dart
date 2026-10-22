import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';

class SnakeTheme extends GameTheme {
  final SnakeColors colors;
  final SnakeTextStyles textStyles;
  final SnakeDimens dimens;

  static SnakeTheme of(BuildContext context) => GameTheme.of<SnakeTheme>(context);

  const SnakeTheme({
    required this.colors,
    required this.textStyles,
    required this.dimens,
  });

  factory SnakeTheme.fromCore(CoreGameTheme core) {
    return SnakeTheme(
      colors: SnakeColors(
        cell: core.colors.background,
        cellAlternate: core.colors.surface,
        snakeBody: core.colors.primary,
        snakeHead: core.colors.primary,
        snakeEye: core.colors.onPrimary,
        food: core.colors.secondary,
        score: core.colors.primary,
      ),
      textStyles: SnakeTextStyles(
        score: core.textStyles.title,
        length: core.textStyles.body,
      ),
      dimens: const SnakeDimens(
        snakeThickness: 0.72,
        headSize: 0.86,
        foodSize: 0.5,
      ),
    );
  }

  SnakeTheme copyWith({
    SnakeColors? colors,
    SnakeTextStyles? textStyles,
    SnakeDimens? dimens,
  }) => SnakeTheme(
    colors: colors ?? this.colors,
    textStyles: textStyles ?? this.textStyles,
    dimens: dimens ?? this.dimens,
  );
}

class SnakeColors {
  /// Board cells, alternated with [cellAlternate] as a checkerboard
  final Color cell;
  final Color cellAlternate;

  /// Solid color of the body, no alpha (avoids overlap artifacts)
  final Color snakeBody;
  final Color snakeHead;
  final Color snakeEye;
  final Color food;

  /// Icons in the header
  final Color score;

  const SnakeColors({
    required this.cell,
    required this.cellAlternate,
    required this.snakeBody,
    required this.snakeHead,
    required this.snakeEye,
    required this.food,
    required this.score,
  });

  SnakeColors copyWith({
    Color? cell,
    Color? cellAlternate,
    Color? snakeBody,
    Color? snakeHead,
    Color? snakeEye,
    Color? food,
    Color? score,
  }) => SnakeColors(
    cell: cell ?? this.cell,
    cellAlternate: cellAlternate ?? this.cellAlternate,
    snakeBody: snakeBody ?? this.snakeBody,
    snakeHead: snakeHead ?? this.snakeHead,
    snakeEye: snakeEye ?? this.snakeEye,
    food: food ?? this.food,
    score: score ?? this.score,
  );
}

class SnakeTextStyles {
  final TextStyle score;
  final TextStyle length;

  const SnakeTextStyles({
    required this.score,
    required this.length,
  });

  SnakeTextStyles copyWith({
    TextStyle? score,
    TextStyle? length,
  }) => SnakeTextStyles(
    score: score ?? this.score,
    length: length ?? this.length,
  );
}

/// Sizes relative to the size of one cell (1 = a full cell)
class SnakeDimens {
  final double snakeThickness;
  final double headSize;
  final double foodSize;

  const SnakeDimens({
    required this.snakeThickness,
    required this.headSize,
    required this.foodSize,
  });

  SnakeDimens copyWith({
    double? snakeThickness,
    double? headSize,
    double? foodSize,
  }) => SnakeDimens(
    snakeThickness: snakeThickness ?? this.snakeThickness,
    headSize: headSize ?? this.headSize,
    foodSize: foodSize ?? this.foodSize,
  );
}
