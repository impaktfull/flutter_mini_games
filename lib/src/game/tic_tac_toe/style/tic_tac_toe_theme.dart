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

  static TicTacToeTheme getDefault() => TicTacToeTheme(
    colors: TicTacToeColors(
      cellBackgroundColor: Colors.white,
      cellTextColor: Colors.black,
      headerBackgroundColor: Colors.white,
      headerTextColor: Colors.black,
    ),
    textStyles: TicTacToeTextStyles(
      headerTextStyle: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      cellTextStyle: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

class TicTacToeColors {
  final Color cellBackgroundColor;
  final Color cellTextColor;
  final Color headerBackgroundColor;
  final Color headerTextColor;

  TicTacToeColors({
    required this.cellBackgroundColor,
    required this.cellTextColor,
    required this.headerBackgroundColor,
    required this.headerTextColor,
  });
}

class TicTacToeTextStyles {
  final TextStyle headerTextStyle;
  final TextStyle cellTextStyle;

  TicTacToeTextStyles({
    required this.headerTextStyle,
    required this.cellTextStyle,
  });
}
