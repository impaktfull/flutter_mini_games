import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/model/data/flutter_mini_game_builder.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/game/tic_tac_toe/screen/tic_tac_toe_screen.dart';
import 'package:flutter_mini_games/src/game/tic_tac_toe/style/tic_tac_toe_theme.dart';

class TicTacToeGameBuilder extends FlutterMiniGameBuilder {
  @override
  bool get isMultiPlayer => true;
  final CoreGameTheme? coreTheme;
  final TicTacToeTheme? theme;

  TicTacToeGameBuilder({
    super.name = 'Tic Tac Toe',
    super.description = 'Classic tic-tac-toe game for two players',
    this.theme,
    this.coreTheme,
  });

  @override
  Future<Widget> build(BuildContext context) async {
    return TicTacToeScreen(
      theme:
          theme ??
          TicTacToeTheme.getDefault(
            coreTheme: coreTheme,
          ),
      coreTheme: coreTheme ?? CoreGameTheme.getDefault(),
    );
  }
}
