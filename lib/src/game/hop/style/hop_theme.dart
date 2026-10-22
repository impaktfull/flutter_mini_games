import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';

class HopTheme extends GameTheme {
  final HopColors colors;
  final HopTextStyles textStyles;
  final HopDimens dimens;

  static HopTheme of(BuildContext context) => GameTheme.of<HopTheme>(context);

  const HopTheme({
    required this.colors,
    required this.textStyles,
    required this.dimens,
  });

  factory HopTheme.fromCore(CoreGameTheme core) {
    return HopTheme(
      colors: HopColors(
        background: core.colors.background,
        character: core.colors.primary,
        characterFace: core.colors.onPrimary,
        platform: core.colors.secondary,
        movingPlatform: core.colors.textMuted,
        breakablePlatform: core.colors.surface,
        breakablePlatformCrack: core.colors.textMuted,
        steerIndicator: core.colors.surface,
      ),
      textStyles: HopTextStyles(
        score: core.textStyles.title,
        scoreLabel: core.textStyles.caption,
      ),
      dimens: HopDimens(
        platformThickness: 0.035,
        platformRadius: core.dimens.radiusSmall,
      ),
    );
  }

  HopTheme copyWith({
    HopColors? colors,
    HopTextStyles? textStyles,
    HopDimens? dimens,
  }) => HopTheme(
    colors: colors ?? this.colors,
    textStyles: textStyles ?? this.textStyles,
    dimens: dimens ?? this.dimens,
  );
}

class HopColors {
  /// Background of the playing field
  final Color background;

  /// Body of the character
  final Color character;

  /// Eyes and smile of the character
  final Color characterFace;

  /// Platforms that stay in place
  final Color platform;

  /// Platforms that slide left and right
  final Color movingPlatform;

  /// Platforms that break when landed on
  final Color breakablePlatform;

  /// Crack and outline of breakable platforms
  final Color breakablePlatformCrack;

  /// Highlight of the half of the board that is held
  final Color steerIndicator;

  const HopColors({
    required this.background,
    required this.character,
    required this.characterFace,
    required this.platform,
    required this.movingPlatform,
    required this.breakablePlatform,
    required this.breakablePlatformCrack,
    required this.steerIndicator,
  });

  HopColors copyWith({
    Color? background,
    Color? character,
    Color? characterFace,
    Color? platform,
    Color? movingPlatform,
    Color? breakablePlatform,
    Color? breakablePlatformCrack,
    Color? steerIndicator,
  }) => HopColors(
    background: background ?? this.background,
    character: character ?? this.character,
    characterFace: characterFace ?? this.characterFace,
    platform: platform ?? this.platform,
    movingPlatform: movingPlatform ?? this.movingPlatform,
    breakablePlatform: breakablePlatform ?? this.breakablePlatform,
    breakablePlatformCrack: breakablePlatformCrack ?? this.breakablePlatformCrack,
    steerIndicator: steerIndicator ?? this.steerIndicator,
  );
}

class HopTextStyles {
  /// Current score in the header
  final TextStyle score;

  /// Label below the score
  final TextStyle scoreLabel;

  const HopTextStyles({
    required this.score,
    required this.scoreLabel,
  });

  HopTextStyles copyWith({
    TextStyle? score,
    TextStyle? scoreLabel,
  }) => HopTextStyles(
    score: score ?? this.score,
    scoreLabel: scoreLabel ?? this.scoreLabel,
  );
}

class HopDimens {
  /// Thickness of a platform in world units (the world is 1.0 wide)
  final double platformThickness;

  /// Corner radius of a platform in logical pixels
  final double platformRadius;

  const HopDimens({
    required this.platformThickness,
    required this.platformRadius,
  });

  HopDimens copyWith({
    double? platformThickness,
    double? platformRadius,
  }) => HopDimens(
    platformThickness: platformThickness ?? this.platformThickness,
    platformRadius: platformRadius ?? this.platformRadius,
  );
}
