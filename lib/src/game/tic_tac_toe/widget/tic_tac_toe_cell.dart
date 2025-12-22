import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/widget/theme/theme_builder.dart';
import 'package:flutter_mini_games/src/game/tic_tac_toe/style/tic_tac_toe_theme.dart';

class TicTacToeCell extends StatelessWidget {
  final String? value;
  final bool isWinningCell;
  final VoidCallback onTap;

  const TicTacToeCell({
    required this.isWinningCell,
    required this.onTap,
    this.value,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final valueX = value == "X";
    return GameThemeBuilder<TicTacToeTheme>(
      builder: (context, theme) => GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: _getCellBackground(theme),
            borderRadius: BorderRadius.circular(8),
            border: isWinningCell
                ? Border.all(
                    color: (valueX
                        ? theme.colors.cellXWinningBorder
                        : theme.colors.cellOWinningBorder),
                    width: 2,
                  )
                : null,
          ),
          margin: const EdgeInsets.all(2),
          child: Center(
            child: value != null
                ? Text(
                    value!,
                    style: _getTextStyle(theme),
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Color? _getCellBackground(TicTacToeTheme theme) {
    final valueX = value == "X";
    if (isWinningCell) {
      if (valueX) {
        return theme.colors.cellXWinningBackground;
      }
      return theme.colors.cellOWinningBackground;
    }
    return theme.colors.cellBackground;
  }

  TextStyle? _getTextStyle(TicTacToeTheme theme) {
    final valueX = value == "X";
    if (isWinningCell) {
      if (valueX) {
        return theme.textStyles.cellXWinning;
      }
      return theme.textStyles.cellOWinning;
    }
    return valueX ? theme.textStyles.cellX : theme.textStyles.cellO;
  }
}
