import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';

class TicTacToeTheme extends GameTheme {
  final TicTacToeColors colors;
  final TicTacToeTextStyles textStyles;

  static TicTacToeTheme of(BuildContext context) => GameTheme.of<TicTacToeTheme>(context);

  TicTacToeTheme({
    required this.colors,
    required this.textStyles,
  });

  static TicTacToeTheme getDefault({
    CoreGameTheme? coreTheme,
  }) {
    final colorO = coreTheme?.colors.primary ?? const Color(0xFF7d64f2);
    final colorX = coreTheme?.colors.secondary ?? const Color(0xFF1a1a1a);
    return TicTacToeTheme(
      colors: TicTacToeColors(
        cellBackground: const Color.fromARGB(255, 245, 245, 245),
        cellXWinningBackground: colorX,
        cellOWinningBackground: colorO,
        headerBackground: Colors.white,
        cellXWinningBorder: colorX,
        cellOWinningBorder: colorO,
      ),
      textStyles: TicTacToeTextStyles(
        header: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headerDraw: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headerWinnerO: TextStyle(
          fontSize: 24,
          color: colorO,
          fontWeight: FontWeight.bold,
        ),
        headerWinnerX: TextStyle(
          fontSize: 24,
          color: colorX,
          fontWeight: FontWeight.bold,
        ),
        cellO: TextStyle(
          fontSize: 48,
          color: colorO,
          fontWeight: FontWeight.bold,
        ),
        cellX: TextStyle(
          fontSize: 48,
          color: colorX,
          fontWeight: FontWeight.bold,
        ),
        cellOWinning: TextStyle(
          fontSize: 48,
          color: coreTheme?.colors.textInverted ?? Colors.white,
          fontWeight: FontWeight.bold,
        ),
        cellXWinning: TextStyle(
          fontSize: 48,
          color: coreTheme?.colors.textInverted ?? Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class TicTacToeColors {
  final Color cellBackground;
  final Color cellXWinningBackground;
  final Color cellOWinningBackground;
  final Color headerBackground;
  final Color cellXWinningBorder;
  final Color cellOWinningBorder;

  TicTacToeColors({
    required this.cellBackground,
    required this.cellXWinningBackground,
    required this.cellOWinningBackground,
    required this.headerBackground,
    required this.cellXWinningBorder,
    required this.cellOWinningBorder,
  });
}

class TicTacToeTextStyles {
  final TextStyle header;
  final TextStyle headerDraw;
  final TextStyle headerWinnerX;
  final TextStyle headerWinnerO;
  final TextStyle cellO;
  final TextStyle cellX;
  final TextStyle cellOWinning;
  final TextStyle cellXWinning;

  TicTacToeTextStyles({
    required this.header,
    required this.headerDraw,
    required this.headerWinnerX,
    required this.headerWinnerO,
    required this.cellO,
    required this.cellX,
    required this.cellOWinning,
    required this.cellXWinning,
  });
}
