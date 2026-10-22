import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/game/code/game/model/code_peg.dart';

class CodeTheme extends GameTheme {
  final CodeColors colors;
  final CodeTextStyles textStyles;
  final CodeDimens dimens;

  static CodeTheme of(BuildContext context) => GameTheme.of<CodeTheme>(context);

  const CodeTheme({
    required this.colors,
    required this.textStyles,
    required this.dimens,
  });

  factory CodeTheme.fromCore(CoreGameTheme core) {
    final c = core.colors;
    // Solid mixes of core colors: no alpha, so nothing shows through overlapping paint
    Color mix(Color a, Color b, double t) => Color.lerp(a, b, t)!;
    return CodeTheme(
      colors: CodeColors(
        row: c.surface,
        currentRow: mix(c.background, c.primary, 0.18),
        slot: c.background,
        slotBorder: mix(c.surface, c.textMuted, 0.35),
        slotBorderActive: c.primary,
        pegs: [
          c.primary,
          c.error,
          c.secondary,
          mix(c.primary, c.error, 0.5),
          mix(c.error, c.secondary, 0.45),
          mix(c.primary, c.secondary, 0.55),
        ],
        feedbackExact: c.text,
        feedbackMisplaced: c.text,
        feedbackEmpty: mix(c.surface, c.textMuted, 0.3),
        secret: c.secondary,
        secretMark: c.onSecondary,
        key: c.surface,
        submit: c.primary,
        onSubmit: c.onPrimary,
      ),
      textStyles: CodeTextStyles(
        header: core.textStyles.title,
        headerWin: core.textStyles.title.copyWith(color: c.primary),
        headerLost: core.textStyles.title.copyWith(color: c.error),
        info: core.textStyles.body,
        secretMark: core.textStyles.label.copyWith(color: c.onSecondary),
      ),
      dimens: CodeDimens(
        boardPadding: core.dimens.padding / 2,
        rowSpacing: 4,
        slotSpacing: 6,
        rowRadius: core.dimens.radiusSmall,
        slotBorderWidth: 1.5,
        pegScale: 0.7,
        feedbackMarkerStroke: 1.5,
        keyHeight: 48,
        keySpacing: 6,
        keyRadius: core.dimens.radiusSmall,
      ),
    );
  }

  CodeTheme copyWith({
    CodeColors? colors,
    CodeTextStyles? textStyles,
    CodeDimens? dimens,
  }) => CodeTheme(
    colors: colors ?? this.colors,
    textStyles: textStyles ?? this.textStyles,
    dimens: dimens ?? this.dimens,
  );
}

class CodeColors {
  /// Background of a submitted (or not yet played) row
  final Color row;

  /// Background of the row being guessed
  final Color currentRow;

  /// Background of a peg slot
  final Color slot;
  final Color slotBorder;

  /// Border of the next empty slot of the current guess
  final Color slotBorderActive;

  /// One color per [CodePeg], in the order of [CodePeg.values]. The shape tells the pegs apart, the color helps.
  final List<Color> pegs;

  /// Filled marker: right symbol in the right place
  final Color feedbackExact;

  /// Hollow marker: right symbol in the wrong place
  final Color feedbackMisplaced;

  /// Marker position without a hit
  final Color feedbackEmpty;

  /// Hidden slots of the secret code
  final Color secret;

  /// Question mark on a hidden slot
  final Color secretMark;

  /// Keys of the symbol picker
  final Color key;

  /// Submit button at the end of a complete guess row
  final Color submit;
  final Color onSubmit;

  const CodeColors({
    required this.row,
    required this.currentRow,
    required this.slot,
    required this.slotBorder,
    required this.slotBorderActive,
    required this.pegs,
    required this.feedbackExact,
    required this.feedbackMisplaced,
    required this.feedbackEmpty,
    required this.secret,
    required this.secretMark,
    required this.key,
    required this.submit,
    required this.onSubmit,
  }) : assert(pegs.length == 6, 'One color per CodePeg');

  Color peg(CodePeg peg) => pegs[peg.index];

  CodeColors copyWith({
    Color? row,
    Color? currentRow,
    Color? slot,
    Color? slotBorder,
    Color? slotBorderActive,
    List<Color>? pegs,
    Color? feedbackExact,
    Color? feedbackMisplaced,
    Color? feedbackEmpty,
    Color? secret,
    Color? secretMark,
    Color? key,
    Color? submit,
    Color? onSubmit,
  }) => CodeColors(
    row: row ?? this.row,
    currentRow: currentRow ?? this.currentRow,
    slot: slot ?? this.slot,
    slotBorder: slotBorder ?? this.slotBorder,
    slotBorderActive: slotBorderActive ?? this.slotBorderActive,
    pegs: pegs ?? this.pegs,
    feedbackExact: feedbackExact ?? this.feedbackExact,
    feedbackMisplaced: feedbackMisplaced ?? this.feedbackMisplaced,
    feedbackEmpty: feedbackEmpty ?? this.feedbackEmpty,
    secret: secret ?? this.secret,
    secretMark: secretMark ?? this.secretMark,
    key: key ?? this.key,
    submit: submit ?? this.submit,
    onSubmit: onSubmit ?? this.onSubmit,
  );
}

class CodeTextStyles {
  final TextStyle header;
  final TextStyle headerWin;
  final TextStyle headerLost;

  /// Tries left and score below the header
  final TextStyle info;

  /// Question mark on the hidden code
  final TextStyle secretMark;

  const CodeTextStyles({
    required this.header,
    required this.headerWin,
    required this.headerLost,
    required this.info,
    required this.secretMark,
  });

  CodeTextStyles copyWith({
    TextStyle? header,
    TextStyle? headerWin,
    TextStyle? headerLost,
    TextStyle? info,
    TextStyle? secretMark,
  }) => CodeTextStyles(
    header: header ?? this.header,
    headerWin: headerWin ?? this.headerWin,
    headerLost: headerLost ?? this.headerLost,
    info: info ?? this.info,
    secretMark: secretMark ?? this.secretMark,
  );
}

class CodeDimens {
  /// Space between the board frame and the rows
  final double boardPadding;
  final double rowSpacing;

  /// Space between the slots of a row
  final double slotSpacing;
  final double rowRadius;
  final double slotBorderWidth;

  /// Size of a peg relative to its slot
  final double pegScale;

  /// Stroke of the hollow feedback marker
  final double feedbackMarkerStroke;
  final double keyHeight;
  final double keySpacing;
  final double keyRadius;

  const CodeDimens({
    required this.boardPadding,
    required this.rowSpacing,
    required this.slotSpacing,
    required this.rowRadius,
    required this.slotBorderWidth,
    required this.pegScale,
    required this.feedbackMarkerStroke,
    required this.keyHeight,
    required this.keySpacing,
    required this.keyRadius,
  });

  CodeDimens copyWith({
    double? boardPadding,
    double? rowSpacing,
    double? slotSpacing,
    double? rowRadius,
    double? slotBorderWidth,
    double? pegScale,
    double? feedbackMarkerStroke,
    double? keyHeight,
    double? keySpacing,
    double? keyRadius,
  }) => CodeDimens(
    boardPadding: boardPadding ?? this.boardPadding,
    rowSpacing: rowSpacing ?? this.rowSpacing,
    slotSpacing: slotSpacing ?? this.slotSpacing,
    rowRadius: rowRadius ?? this.rowRadius,
    slotBorderWidth: slotBorderWidth ?? this.slotBorderWidth,
    pegScale: pegScale ?? this.pegScale,
    feedbackMarkerStroke: feedbackMarkerStroke ?? this.feedbackMarkerStroke,
    keyHeight: keyHeight ?? this.keyHeight,
    keySpacing: keySpacing ?? this.keySpacing,
    keyRadius: keyRadius ?? this.keyRadius,
  );
}
