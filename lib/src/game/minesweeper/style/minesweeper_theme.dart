import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';

class MinesweeperTheme extends GameTheme {
  final MinesweeperColors colors;
  final MinesweeperTextStyles textStyles;
  final MinesweeperDimens dimens;

  static MinesweeperTheme of(BuildContext context) => GameTheme.of<MinesweeperTheme>(context);

  const MinesweeperTheme({
    required this.colors,
    required this.textStyles,
    required this.dimens,
  });

  factory MinesweeperTheme.fromCore(CoreGameTheme core) {
    final c = core.colors;
    return MinesweeperTheme(
      colors: MinesweeperColors(
        cellHidden: c.primary.withValues(alpha: 0.2),
        cellRevealed: c.surface,
        cellExploded: c.primary,
        mine: c.secondary,
        mineExploded: c.onPrimary,
        flag: c.primary,
        wrongFlag: c.textMuted,
        counter: c.primary,
        difficultySelected: c.primary,
        onDifficultySelected: c.onPrimary,
        difficulty: c.surface,
        onDifficulty: c.text,
        numbers: [c.primary, c.secondary, c.textMuted, c.primary, c.secondary, c.textMuted, c.primary, c.secondary],
      ),
      textStyles: MinesweeperTextStyles(
        header: core.textStyles.title,
        status: core.textStyles.body,
        counter: core.textStyles.label,
        difficulty: core.textStyles.caption,
        number: core.textStyles.label,
      ),
      dimens: MinesweeperDimens(
        boardPadding: 6,
        cellRadius: core.dimens.radiusSmall / 2,
        cellSpacing: 2,
        difficultyRadius: core.dimens.radiusSmall,
      ),
    );
  }

  MinesweeperTheme copyWith({
    MinesweeperColors? colors,
    MinesweeperTextStyles? textStyles,
    MinesweeperDimens? dimens,
  }) => MinesweeperTheme(
    colors: colors ?? this.colors,
    textStyles: textStyles ?? this.textStyles,
    dimens: dimens ?? this.dimens,
  );
}

class MinesweeperColors {
  /// Background of a cell that is not revealed yet
  final Color cellHidden;

  /// Background of a revealed cell
  final Color cellRevealed;

  /// Background of the mine that lost the game
  final Color cellExploded;

  /// Mines shown when the game is lost
  final Color mine;

  /// The mine that lost the game
  final Color mineExploded;
  final Color flag;

  /// Flag on a cell without mine, shown when the game is lost
  final Color wrongFlag;

  /// Icon of the remaining mines counter
  final Color counter;
  final Color difficultySelected;
  final Color onDifficultySelected;
  final Color difficulty;
  final Color onDifficulty;

  /// Colors of the numbers 1 to 8, the list is repeated when it is shorter
  final List<Color> numbers;

  const MinesweeperColors({
    required this.cellHidden,
    required this.cellRevealed,
    required this.cellExploded,
    required this.mine,
    required this.mineExploded,
    required this.flag,
    required this.wrongFlag,
    required this.counter,
    required this.difficultySelected,
    required this.onDifficultySelected,
    required this.difficulty,
    required this.onDifficulty,
    required this.numbers,
  });

  /// Color of a number from 1 to 8
  Color number(int value) => numbers[(value - 1) % numbers.length];

  MinesweeperColors copyWith({
    Color? cellHidden,
    Color? cellRevealed,
    Color? cellExploded,
    Color? mine,
    Color? mineExploded,
    Color? flag,
    Color? wrongFlag,
    Color? counter,
    Color? difficultySelected,
    Color? onDifficultySelected,
    Color? difficulty,
    Color? onDifficulty,
    List<Color>? numbers,
  }) => MinesweeperColors(
    cellHidden: cellHidden ?? this.cellHidden,
    cellRevealed: cellRevealed ?? this.cellRevealed,
    cellExploded: cellExploded ?? this.cellExploded,
    mine: mine ?? this.mine,
    mineExploded: mineExploded ?? this.mineExploded,
    flag: flag ?? this.flag,
    wrongFlag: wrongFlag ?? this.wrongFlag,
    counter: counter ?? this.counter,
    difficultySelected: difficultySelected ?? this.difficultySelected,
    onDifficultySelected: onDifficultySelected ?? this.onDifficultySelected,
    difficulty: difficulty ?? this.difficulty,
    onDifficulty: onDifficulty ?? this.onDifficulty,
    numbers: numbers ?? this.numbers,
  );
}

class MinesweeperTextStyles {
  final TextStyle header;

  /// Line below the header (score, hint)
  final TextStyle status;

  /// Remaining mines counter
  final TextStyle counter;

  /// Labels of the difficulty selector
  final TextStyle difficulty;

  /// Numbers in the cells, scaled to the cell size
  final TextStyle number;

  const MinesweeperTextStyles({
    required this.header,
    required this.status,
    required this.counter,
    required this.difficulty,
    required this.number,
  });

  MinesweeperTextStyles copyWith({
    TextStyle? header,
    TextStyle? status,
    TextStyle? counter,
    TextStyle? difficulty,
    TextStyle? number,
  }) => MinesweeperTextStyles(
    header: header ?? this.header,
    status: status ?? this.status,
    counter: counter ?? this.counter,
    difficulty: difficulty ?? this.difficulty,
    number: number ?? this.number,
  );
}

class MinesweeperDimens {
  /// Space between the edge of the board and the cells
  final double boardPadding;
  final double cellRadius;
  final double cellSpacing;
  final double difficultyRadius;

  const MinesweeperDimens({
    required this.boardPadding,
    required this.cellRadius,
    required this.cellSpacing,
    required this.difficultyRadius,
  });

  MinesweeperDimens copyWith({
    double? boardPadding,
    double? cellRadius,
    double? cellSpacing,
    double? difficultyRadius,
  }) => MinesweeperDimens(
    boardPadding: boardPadding ?? this.boardPadding,
    cellRadius: cellRadius ?? this.cellRadius,
    cellSpacing: cellSpacing ?? this.cellSpacing,
    difficultyRadius: difficultyRadius ?? this.difficultyRadius,
  );
}
