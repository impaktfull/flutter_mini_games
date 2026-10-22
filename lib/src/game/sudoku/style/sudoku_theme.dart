import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';

class SudokuTheme extends GameTheme {
  final SudokuColors colors;
  final SudokuTextStyles textStyles;
  final SudokuDimens dimens;

  static SudokuTheme of(BuildContext context) => GameTheme.of<SudokuTheme>(context);

  const SudokuTheme({
    required this.colors,
    required this.textStyles,
    required this.dimens,
  });

  factory SudokuTheme.fromCore(CoreGameTheme core) {
    // Solid mixes of core colors: no alpha, so nothing shows through overlapping paint
    final sameValue = Color.lerp(core.colors.background, core.colors.primary, 0.3)!;
    final gridLine = Color.lerp(core.colors.background, core.colors.textMuted, 0.45)!;
    return SudokuTheme(
      colors: SudokuColors(
        cell: core.colors.background,
        cellPeer: core.colors.surface,
        cellSameValue: sameValue,
        cellSelected: core.colors.primary,
        cellWrong: core.colors.secondary,
        gridLine: gridLine,
        boxLine: core.colors.secondary,
        key: core.colors.surface,
        keyActive: core.colors.primary,
        keyIcon: core.colors.text,
        keyIconActive: core.colors.onPrimary,
      ),
      textStyles: SudokuTextStyles(
        header: core.textStyles.title,
        headerWin: core.textStyles.title,
        info: core.textStyles.body,
        given: core.textStyles.label,
        entry: core.textStyles.body.copyWith(color: core.colors.primary),
        selected: core.textStyles.label.copyWith(color: core.colors.onPrimary),
        wrong: core.textStyles.label.copyWith(color: core.colors.onSecondary),
        note: core.textStyles.caption,
        key: core.textStyles.title.copyWith(color: core.colors.primary),
        keyLabel: core.textStyles.caption.copyWith(color: core.colors.text),
        keyLabelActive: core.textStyles.caption.copyWith(color: core.colors.onPrimary),
      ),
      dimens: SudokuDimens(
        boardPadding: core.dimens.padding / 2,
        gridLineWidth: 1,
        boxLineWidth: 2.5,
        keyHeight: 48,
        keySpacing: 4,
        keyRadius: core.dimens.radiusSmall,
      ),
    );
  }

  SudokuTheme copyWith({
    SudokuColors? colors,
    SudokuTextStyles? textStyles,
    SudokuDimens? dimens,
  }) => SudokuTheme(
    colors: colors ?? this.colors,
    textStyles: textStyles ?? this.textStyles,
    dimens: dimens ?? this.dimens,
  );
}

class SudokuColors {
  final Color cell;

  /// Cells in the same row, column or box as the selected cell
  final Color cellPeer;

  /// Cells with the same digit as the selected cell
  final Color cellSameValue;
  final Color cellSelected;

  /// Cells with a digit that does not match the solution
  final Color cellWrong;

  /// Thin lines between cells
  final Color gridLine;

  /// Thick lines around the 3x3 boxes and the board
  final Color boxLine;

  /// Number pad keys
  final Color key;

  /// Number pad key that is switched on (notes mode)
  final Color keyActive;
  final Color keyIcon;
  final Color keyIconActive;

  const SudokuColors({
    required this.cell,
    required this.cellPeer,
    required this.cellSameValue,
    required this.cellSelected,
    required this.cellWrong,
    required this.gridLine,
    required this.boxLine,
    required this.key,
    required this.keyActive,
    required this.keyIcon,
    required this.keyIconActive,
  });

  SudokuColors copyWith({
    Color? cell,
    Color? cellPeer,
    Color? cellSameValue,
    Color? cellSelected,
    Color? cellWrong,
    Color? gridLine,
    Color? boxLine,
    Color? key,
    Color? keyActive,
    Color? keyIcon,
    Color? keyIconActive,
  }) => SudokuColors(
    cell: cell ?? this.cell,
    cellPeer: cellPeer ?? this.cellPeer,
    cellSameValue: cellSameValue ?? this.cellSameValue,
    cellSelected: cellSelected ?? this.cellSelected,
    cellWrong: cellWrong ?? this.cellWrong,
    gridLine: gridLine ?? this.gridLine,
    boxLine: boxLine ?? this.boxLine,
    key: key ?? this.key,
    keyActive: keyActive ?? this.keyActive,
    keyIcon: keyIcon ?? this.keyIcon,
    keyIconActive: keyIconActive ?? this.keyIconActive,
  );
}

class SudokuTextStyles {
  final TextStyle header;
  final TextStyle headerWin;

  /// Difficulty, mistakes and score below the header
  final TextStyle info;

  /// Digits of the puzzle
  final TextStyle given;

  /// Digits entered by the player
  final TextStyle entry;

  /// Digit in the selected cell
  final TextStyle selected;

  /// Digit that does not match the solution
  final TextStyle wrong;

  /// Pencil marks
  final TextStyle note;

  /// Digits on the number pad
  final TextStyle key;

  /// Labels of the erase and notes keys
  final TextStyle keyLabel;
  final TextStyle keyLabelActive;

  const SudokuTextStyles({
    required this.header,
    required this.headerWin,
    required this.info,
    required this.given,
    required this.entry,
    required this.selected,
    required this.wrong,
    required this.note,
    required this.key,
    required this.keyLabel,
    required this.keyLabelActive,
  });

  SudokuTextStyles copyWith({
    TextStyle? header,
    TextStyle? headerWin,
    TextStyle? info,
    TextStyle? given,
    TextStyle? entry,
    TextStyle? selected,
    TextStyle? wrong,
    TextStyle? note,
    TextStyle? key,
    TextStyle? keyLabel,
    TextStyle? keyLabelActive,
  }) => SudokuTextStyles(
    header: header ?? this.header,
    headerWin: headerWin ?? this.headerWin,
    info: info ?? this.info,
    given: given ?? this.given,
    entry: entry ?? this.entry,
    selected: selected ?? this.selected,
    wrong: wrong ?? this.wrong,
    note: note ?? this.note,
    key: key ?? this.key,
    keyLabel: keyLabel ?? this.keyLabel,
    keyLabelActive: keyLabelActive ?? this.keyLabelActive,
  );
}

class SudokuDimens {
  /// Space between the board frame and the cells
  final double boardPadding;
  final double gridLineWidth;
  final double boxLineWidth;
  final double keyHeight;
  final double keySpacing;
  final double keyRadius;

  const SudokuDimens({
    required this.boardPadding,
    required this.gridLineWidth,
    required this.boxLineWidth,
    required this.keyHeight,
    required this.keySpacing,
    required this.keyRadius,
  });

  SudokuDimens copyWith({
    double? boardPadding,
    double? gridLineWidth,
    double? boxLineWidth,
    double? keyHeight,
    double? keySpacing,
    double? keyRadius,
  }) => SudokuDimens(
    boardPadding: boardPadding ?? this.boardPadding,
    gridLineWidth: gridLineWidth ?? this.gridLineWidth,
    boxLineWidth: boxLineWidth ?? this.boxLineWidth,
    keyHeight: keyHeight ?? this.keyHeight,
    keySpacing: keySpacing ?? this.keySpacing,
    keyRadius: keyRadius ?? this.keyRadius,
  );
}
