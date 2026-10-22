import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';

class StackTheme extends GameTheme {
  final StackColors colors;
  final StackTextStyles textStyles;
  final StackDimens dimens;

  static StackTheme of(BuildContext context) => GameTheme.of<StackTheme>(context);

  const StackTheme({
    required this.colors,
    required this.textStyles,
    required this.dimens,
  });

  factory StackTheme.fromCore(CoreGameTheme core) {
    return StackTheme(
      colors: StackColors(
        background: core.colors.background,
        ground: core.colors.surface,
        blockStart: core.colors.primary,
        blockEnd: core.colors.secondary,
      ),
      textStyles: StackTextStyles(
        score: core.textStyles.title,
        status: core.textStyles.body.copyWith(color: core.colors.textMuted),
        perfect: core.textStyles.label.copyWith(color: core.colors.primary),
      ),
      dimens: const StackDimens(
        blockRadius: 2,
        blockGap: 1,
        colorCycleLength: 12,
        colorMaxBlend: 0.7,
      ),
    );
  }

  StackTheme copyWith({
    StackColors? colors,
    StackTextStyles? textStyles,
    StackDimens? dimens,
  }) => StackTheme(
    colors: colors ?? this.colors,
    textStyles: textStyles ?? this.textStyles,
    dimens: dimens ?? this.dimens,
  );

  /// Color of the block at [level]: goes from [StackColors.blockStart] towards [StackColors.blockEnd] and back
  Color blockColor(int level) {
    final cycle = dimens.colorCycleLength;
    if (cycle <= 0) return colors.blockStart;
    final position = level % (2 * cycle);
    final t = position <= cycle ? position / cycle : 2 - position / cycle;
    return Color.lerp(colors.blockStart, colors.blockEnd, t * dimens.colorMaxBlend)!;
  }
}

class StackColors {
  /// Sky behind the tower
  final Color background;

  /// Ground below the base block
  final Color ground;

  /// Color of the base block, blocks blend towards [blockEnd] and back as the tower grows
  final Color blockStart;
  final Color blockEnd;

  const StackColors({
    required this.background,
    required this.ground,
    required this.blockStart,
    required this.blockEnd,
  });

  StackColors copyWith({
    Color? background,
    Color? ground,
    Color? blockStart,
    Color? blockEnd,
  }) => StackColors(
    background: background ?? this.background,
    ground: ground ?? this.ground,
    blockStart: blockStart ?? this.blockStart,
    blockEnd: blockEnd ?? this.blockEnd,
  );
}

class StackTextStyles {
  final TextStyle score;
  final TextStyle status;

  /// "Perfect!" after a perfect drop
  final TextStyle perfect;

  const StackTextStyles({
    required this.score,
    required this.status,
    required this.perfect,
  });

  StackTextStyles copyWith({
    TextStyle? score,
    TextStyle? status,
    TextStyle? perfect,
  }) => StackTextStyles(
    score: score ?? this.score,
    status: status ?? this.status,
    perfect: perfect ?? this.perfect,
  );
}

class StackDimens {
  final double blockRadius;

  /// Vertical gap between two blocks in logical pixels
  final double blockGap;

  /// Number of levels to go from the start color to the end color
  final int colorCycleLength;

  /// How far the blocks blend towards the end color, 0..1
  final double colorMaxBlend;

  const StackDimens({
    required this.blockRadius,
    required this.blockGap,
    required this.colorCycleLength,
    required this.colorMaxBlend,
  });

  StackDimens copyWith({
    double? blockRadius,
    double? blockGap,
    int? colorCycleLength,
    double? colorMaxBlend,
  }) => StackDimens(
    blockRadius: blockRadius ?? this.blockRadius,
    blockGap: blockGap ?? this.blockGap,
    colorCycleLength: colorCycleLength ?? this.colorCycleLength,
    colorMaxBlend: colorMaxBlend ?? this.colorMaxBlend,
  );
}
