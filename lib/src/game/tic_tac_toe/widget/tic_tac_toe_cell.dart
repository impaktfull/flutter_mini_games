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

  bool get _isX => value == 'X';

  @override
  Widget build(BuildContext context) {
    return GameThemeBuilder<TicTacToeTheme>(
      builder: (context, theme) {
        final playerColor = _isX ? theme.colors.playerX : theme.colors.playerO;
        return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: isWinningCell ? playerColor : theme.colors.cellBackground,
              borderRadius: BorderRadius.circular(theme.dimens.cellRadius),
              border: isWinningCell ? Border.all(color: playerColor, width: theme.dimens.winningBorderWidth) : null,
            ),
            margin: const EdgeInsets.all(2),
            child: Center(
              child: value != null ? Text(value!, style: _getTextStyle(theme)) : null,
            ),
          ),
        );
      },
    );
  }

  TextStyle _getTextStyle(TicTacToeTheme theme) {
    if (isWinningCell) {
      return _isX ? theme.textStyles.cellXWinning : theme.textStyles.cellOWinning;
    }
    return _isX ? theme.textStyles.cellX : theme.textStyles.cellO;
  }
}
