import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';

class PairsTheme extends GameTheme {
  final PairsColors colors;
  final PairsTextStyles textStyles;
  final PairsDimens dimens;

  static PairsTheme of(BuildContext context) => GameTheme.of<PairsTheme>(context);

  const PairsTheme({
    required this.colors,
    required this.textStyles,
    required this.dimens,
  });

  factory PairsTheme.fromCore(CoreGameTheme core) {
    final c = core.colors;
    return PairsTheme(
      colors: PairsColors(
        cardBack: c.primary,
        onCardBack: c.onPrimary,
        cardFace: c.surface,
        cardFlipped: c.primary,
        cardMismatch: c.error,
        faces: [c.primary, c.secondary],
        progress: c.primary,
        difficultySelected: c.primary,
        onDifficultySelected: c.onPrimary,
        difficulty: c.surface,
        onDifficulty: c.text,
      ),
      textStyles: PairsTextStyles(
        header: core.textStyles.title,
        status: core.textStyles.body,
        difficulty: core.textStyles.caption,
      ),
      dimens: PairsDimens(
        boardPadding: 8,
        cardSpacing: 6,
        cardRadius: core.dimens.radiusSmall,
        cardBorderWidth: 2.5,
        matchedOpacity: 0.55,
        difficultyRadius: core.dimens.radiusSmall,
      ),
    );
  }

  PairsTheme copyWith({
    PairsColors? colors,
    PairsTextStyles? textStyles,
    PairsDimens? dimens,
  }) => PairsTheme(
    colors: colors ?? this.colors,
    textStyles: textStyles ?? this.textStyles,
    dimens: dimens ?? this.dimens,
  );
}

class PairsColors {
  /// Background of a face-down card
  final Color cardBack;

  /// Pattern on the back of a card
  final Color onCardBack;

  /// Background of a face-up card
  final Color cardFace;

  /// Border of the cards flipped in the current attempt
  final Color cardFlipped;

  /// Border of two flipped cards that don't match
  final Color cardMismatch;

  /// Icon colors of the card faces, cycled per pair
  final List<Color> faces;

  /// Icon of the pairs found counter
  final Color progress;
  final Color difficultySelected;
  final Color onDifficultySelected;
  final Color difficulty;
  final Color onDifficulty;

  const PairsColors({
    required this.cardBack,
    required this.onCardBack,
    required this.cardFace,
    required this.cardFlipped,
    required this.cardMismatch,
    required this.faces,
    required this.progress,
    required this.difficultySelected,
    required this.onDifficultySelected,
    required this.difficulty,
    required this.onDifficulty,
  });

  /// Icon color of the pair with the given value
  Color face(int value) => faces[value % faces.length];

  PairsColors copyWith({
    Color? cardBack,
    Color? onCardBack,
    Color? cardFace,
    Color? cardFlipped,
    Color? cardMismatch,
    List<Color>? faces,
    Color? progress,
    Color? difficultySelected,
    Color? onDifficultySelected,
    Color? difficulty,
    Color? onDifficulty,
  }) => PairsColors(
    cardBack: cardBack ?? this.cardBack,
    onCardBack: onCardBack ?? this.onCardBack,
    cardFace: cardFace ?? this.cardFace,
    cardFlipped: cardFlipped ?? this.cardFlipped,
    cardMismatch: cardMismatch ?? this.cardMismatch,
    faces: faces ?? this.faces,
    progress: progress ?? this.progress,
    difficultySelected: difficultySelected ?? this.difficultySelected,
    onDifficultySelected: onDifficultySelected ?? this.onDifficultySelected,
    difficulty: difficulty ?? this.difficulty,
    onDifficulty: onDifficulty ?? this.onDifficulty,
  );
}

class PairsTextStyles {
  final TextStyle header;

  /// Pairs found counter and hints
  final TextStyle status;

  /// Labels of the difficulty selector
  final TextStyle difficulty;

  const PairsTextStyles({
    required this.header,
    required this.status,
    required this.difficulty,
  });

  PairsTextStyles copyWith({
    TextStyle? header,
    TextStyle? status,
    TextStyle? difficulty,
  }) => PairsTextStyles(
    header: header ?? this.header,
    status: status ?? this.status,
    difficulty: difficulty ?? this.difficulty,
  );
}

class PairsDimens {
  /// Space between the edge of the board and the cards
  final double boardPadding;
  final double cardSpacing;
  final double cardRadius;

  /// Border of flipped and mismatched cards
  final double cardBorderWidth;

  /// Found pairs fade to this opacity so the remaining cards stand out
  final double matchedOpacity;
  final double difficultyRadius;

  const PairsDimens({
    required this.boardPadding,
    required this.cardSpacing,
    required this.cardRadius,
    required this.cardBorderWidth,
    required this.matchedOpacity,
    required this.difficultyRadius,
  });

  PairsDimens copyWith({
    double? boardPadding,
    double? cardSpacing,
    double? cardRadius,
    double? cardBorderWidth,
    double? matchedOpacity,
    double? difficultyRadius,
  }) => PairsDimens(
    boardPadding: boardPadding ?? this.boardPadding,
    cardSpacing: cardSpacing ?? this.cardSpacing,
    cardRadius: cardRadius ?? this.cardRadius,
    cardBorderWidth: cardBorderWidth ?? this.cardBorderWidth,
    matchedOpacity: matchedOpacity ?? this.matchedOpacity,
    difficultyRadius: difficultyRadius ?? this.difficultyRadius,
  );
}
