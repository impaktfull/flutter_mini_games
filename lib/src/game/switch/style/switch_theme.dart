import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';

class SwitchGameTheme extends GameTheme {
  final SwitchGameColors colors;
  final SwitchGameTextStyles textStyles;
  final SwitchGameDimens dimens;

  static SwitchGameTheme of(BuildContext context) => GameTheme.of<SwitchGameTheme>(context);

  const SwitchGameTheme({
    required this.colors,
    required this.textStyles,
    required this.dimens,
  });

  factory SwitchGameTheme.fromCore(CoreGameTheme core) {
    final c = core.colors;
    return SwitchGameTheme(
      colors: SwitchGameColors(
        lightOff: c.surface,
        lightOn: c.primary,
        iconOff: c.textMuted,
        iconOn: c.onPrimary,
        glow: c.primary,
        hint: c.secondary,
        counter: c.primary,
        difficultySelected: c.primary,
        onDifficultySelected: c.onPrimary,
        difficulty: c.surface,
        onDifficulty: c.text,
      ),
      textStyles: SwitchGameTextStyles(
        header: core.textStyles.title,
        status: core.textStyles.body,
        counter: core.textStyles.label,
        difficulty: core.textStyles.caption,
      ),
      dimens: SwitchGameDimens(
        boardPadding: 10,
        cellSpacing: 8,
        cellRadius: core.dimens.radiusSmall,
        glowRadius: 8,
        hintBorderWidth: 3,
        iconScale: 0.45,
        difficultyRadius: core.dimens.radiusSmall,
      ),
    );
  }

  SwitchGameTheme copyWith({
    SwitchGameColors? colors,
    SwitchGameTextStyles? textStyles,
    SwitchGameDimens? dimens,
  }) => SwitchGameTheme(
    colors: colors ?? this.colors,
    textStyles: textStyles ?? this.textStyles,
    dimens: dimens ?? this.dimens,
  );
}

class SwitchGameColors {
  /// Background of a light that is off
  final Color lightOff;

  /// Background of a light that is on
  final Color lightOn;

  /// Bulb icon of a light that is off (outlined)
  final Color iconOff;

  /// Bulb icon of a light that is on (filled)
  final Color iconOn;

  /// Glow around a light that is on, painted solid and blurred
  final Color glow;

  /// Border around the cell of a hint
  final Color hint;

  /// Icons in the header
  final Color counter;
  final Color difficultySelected;
  final Color onDifficultySelected;
  final Color difficulty;
  final Color onDifficulty;

  const SwitchGameColors({
    required this.lightOff,
    required this.lightOn,
    required this.iconOff,
    required this.iconOn,
    required this.glow,
    required this.hint,
    required this.counter,
    required this.difficultySelected,
    required this.onDifficultySelected,
    required this.difficulty,
    required this.onDifficulty,
  });

  SwitchGameColors copyWith({
    Color? lightOff,
    Color? lightOn,
    Color? iconOff,
    Color? iconOn,
    Color? glow,
    Color? hint,
    Color? counter,
    Color? difficultySelected,
    Color? onDifficultySelected,
    Color? difficulty,
    Color? onDifficulty,
  }) => SwitchGameColors(
    lightOff: lightOff ?? this.lightOff,
    lightOn: lightOn ?? this.lightOn,
    iconOff: iconOff ?? this.iconOff,
    iconOn: iconOn ?? this.iconOn,
    glow: glow ?? this.glow,
    hint: hint ?? this.hint,
    counter: counter ?? this.counter,
    difficultySelected: difficultySelected ?? this.difficultySelected,
    onDifficultySelected: onDifficultySelected ?? this.onDifficultySelected,
    difficulty: difficulty ?? this.difficulty,
    onDifficulty: onDifficulty ?? this.onDifficulty,
  );
}

class SwitchGameTextStyles {
  final TextStyle header;

  /// Line below the header (score, hint)
  final TextStyle status;

  /// Lights on and par counters
  final TextStyle counter;

  /// Labels of the difficulty selector
  final TextStyle difficulty;

  const SwitchGameTextStyles({
    required this.header,
    required this.status,
    required this.counter,
    required this.difficulty,
  });

  SwitchGameTextStyles copyWith({
    TextStyle? header,
    TextStyle? status,
    TextStyle? counter,
    TextStyle? difficulty,
  }) => SwitchGameTextStyles(
    header: header ?? this.header,
    status: status ?? this.status,
    counter: counter ?? this.counter,
    difficulty: difficulty ?? this.difficulty,
  );
}

class SwitchGameDimens {
  /// Space between the edge of the board and the lights
  final double boardPadding;
  final double cellSpacing;
  final double cellRadius;

  /// Blur radius of the glow around a light that is on
  final double glowRadius;
  final double hintBorderWidth;

  /// Size of the bulb icon relative to the cell
  final double iconScale;
  final double difficultyRadius;

  const SwitchGameDimens({
    required this.boardPadding,
    required this.cellSpacing,
    required this.cellRadius,
    required this.glowRadius,
    required this.hintBorderWidth,
    required this.iconScale,
    required this.difficultyRadius,
  });

  SwitchGameDimens copyWith({
    double? boardPadding,
    double? cellSpacing,
    double? cellRadius,
    double? glowRadius,
    double? hintBorderWidth,
    double? iconScale,
    double? difficultyRadius,
  }) => SwitchGameDimens(
    boardPadding: boardPadding ?? this.boardPadding,
    cellSpacing: cellSpacing ?? this.cellSpacing,
    cellRadius: cellRadius ?? this.cellRadius,
    glowRadius: glowRadius ?? this.glowRadius,
    hintBorderWidth: hintBorderWidth ?? this.hintBorderWidth,
    iconScale: iconScale ?? this.iconScale,
    difficultyRadius: difficultyRadius ?? this.difficultyRadius,
  );
}
