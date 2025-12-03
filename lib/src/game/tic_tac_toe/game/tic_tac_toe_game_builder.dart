import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/model/data/flutter_mini_game_builder.dart';
import 'package:flutter_mini_games/src/game/tic_tac_toe/screen/tic_tac_toe_screen.dart';
import 'package:flutter_mini_games/src/game/tic_tac_toe/style/tic_tac_toe_theme.dart';

class TicTacToeGameBuilder extends FlutterMiniGameBuilder {
  @override
  bool get isMultiPlayer => true;

  TicTacToeGameBuilder({
    super.name = 'Tic Tac Toe',
    super.description = 'Classic tic-tac-toe game for two players',
  });

  @override
  Future<Widget> build(BuildContext context) async {
    return TicTacToeScreen(
      theme: TicTacToeTheme.getDefault()
    );
  }
}
