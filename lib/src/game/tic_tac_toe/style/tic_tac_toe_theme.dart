import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';

class TicTacToeTheme extends GameTheme {
  final TicTacToeColors colors;
  final TicTacToeTextStyles textStyles;
  final TicTacToeDimens dimens;

  static TicTacToeTheme of(BuildContext context) => GameTheme.of<TicTacToeTheme>(context);

  const TicTacToeTheme({
    required this.colors,
    required this.textStyles,
    required this.dimens,
  });

  factory TicTacToeTheme.fromCore(CoreGameTheme core) {
    final colors = TicTacToeColors(
      cellBackground: core.colors.surface,
      playerX: core.colors.secondary,
      onPlayerX: core.colors.onSecondary,
      playerO: core.colors.primary,
      onPlayerO: core.colors.onPrimary,
    );
    final symbol = core.textStyles.title.copyWith(fontSize: 48);
    return TicTacToeTheme(
      colors: colors,
      textStyles: TicTacToeTextStyles(
        header: core.textStyles.title,
        headerDraw: core.textStyles.title,
        headerWinnerX: core.textStyles.title.copyWith(color: colors.playerX),
        headerWinnerO: core.textStyles.title.copyWith(color: colors.playerO),
        cellX: symbol.copyWith(color: colors.playerX),
        cellO: symbol.copyWith(color: colors.playerO),
        cellXWinning: symbol.copyWith(color: colors.onPlayerX),
        cellOWinning: symbol.copyWith(color: colors.onPlayerO),
      ),
      dimens: TicTacToeDimens(
        cellRadius: core.dimens.radiusSmall,
        cellSpacing: 4,
        winningBorderWidth: 2,
      ),
    );
  }

  TicTacToeTheme copyWith({
    TicTacToeColors? colors,
    TicTacToeTextStyles? textStyles,
    TicTacToeDimens? dimens,
  }) => TicTacToeTheme(
    colors: colors ?? this.colors,
    textStyles: textStyles ?? this.textStyles,
    dimens: dimens ?? this.dimens,
  );
}

class TicTacToeColors {
  final Color cellBackground;

  /// Color of X, also the background of X's winning cells
  final Color playerX;

  /// Color of X on a winning cell
  final Color onPlayerX;

  /// Color of O, also the background of O's winning cells
  final Color playerO;

  /// Color of O on a winning cell
  final Color onPlayerO;

  const TicTacToeColors({
    required this.cellBackground,
    required this.playerX,
    required this.onPlayerX,
    required this.playerO,
    required this.onPlayerO,
  });

  TicTacToeColors copyWith({
    Color? cellBackground,
    Color? playerX,
    Color? onPlayerX,
    Color? playerO,
    Color? onPlayerO,
  }) => TicTacToeColors(
    cellBackground: cellBackground ?? this.cellBackground,
    playerX: playerX ?? this.playerX,
    onPlayerX: onPlayerX ?? this.onPlayerX,
    playerO: playerO ?? this.playerO,
    onPlayerO: onPlayerO ?? this.onPlayerO,
  );
}

class TicTacToeTextStyles {
  final TextStyle header;
  final TextStyle headerDraw;
  final TextStyle headerWinnerX;
  final TextStyle headerWinnerO;
  final TextStyle cellX;
  final TextStyle cellO;
  final TextStyle cellXWinning;
  final TextStyle cellOWinning;

  const TicTacToeTextStyles({
    required this.header,
    required this.headerDraw,
    required this.headerWinnerX,
    required this.headerWinnerO,
    required this.cellX,
    required this.cellO,
    required this.cellXWinning,
    required this.cellOWinning,
  });

  TicTacToeTextStyles copyWith({
    TextStyle? header,
    TextStyle? headerDraw,
    TextStyle? headerWinnerX,
    TextStyle? headerWinnerO,
    TextStyle? cellX,
    TextStyle? cellO,
    TextStyle? cellXWinning,
    TextStyle? cellOWinning,
  }) => TicTacToeTextStyles(
    header: header ?? this.header,
    headerDraw: headerDraw ?? this.headerDraw,
    headerWinnerX: headerWinnerX ?? this.headerWinnerX,
    headerWinnerO: headerWinnerO ?? this.headerWinnerO,
    cellX: cellX ?? this.cellX,
    cellO: cellO ?? this.cellO,
    cellXWinning: cellXWinning ?? this.cellXWinning,
    cellOWinning: cellOWinning ?? this.cellOWinning,
  );
}

class TicTacToeDimens {
  final double cellRadius;
  final double cellSpacing;
  final double winningBorderWidth;

  const TicTacToeDimens({
    required this.cellRadius,
    required this.cellSpacing,
    required this.winningBorderWidth,
  });

  TicTacToeDimens copyWith({
    double? cellRadius,
    double? cellSpacing,
    double? winningBorderWidth,
  }) => TicTacToeDimens(
    cellRadius: cellRadius ?? this.cellRadius,
    cellSpacing: cellSpacing ?? this.cellSpacing,
    winningBorderWidth: winningBorderWidth ?? this.winningBorderWidth,
  );
}
