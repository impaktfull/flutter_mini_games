import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/model/data/flutter_mini_game_builder.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/game/tic_tac_toe/game/logic/tic_tac_toe_game_controller.dart';
import 'package:flutter_mini_games/src/game/tic_tac_toe/screen/tic_tac_toe_screen.dart';
import 'package:flutter_mini_games/src/game/tic_tac_toe/style/tic_tac_toe_theme.dart';

class TicTacToeGameBuilder extends FlutterMiniGameBuilder {
  @override
  String get id => TicTacToeGameController.id;

  @override
  bool get isMultiPlayer => true;

  /// Overrides the core theme of `FlutterMiniGames` for this game
  final CoreGameTheme? coreTheme;

  /// Tweaks the default theme, e.g. `(theme) => theme.copyWith(...)`
  final GameThemeOverride<TicTacToeTheme>? theme;

  const TicTacToeGameBuilder({
    super.name = 'Tic Tac Toe',
    super.description = 'Classic tic-tac-toe game for two players',
    this.coreTheme,
    this.theme,
  });

  @override
  Widget build(BuildContext context) => TicTacToeScreen(
    coreTheme: coreTheme,
    theme: theme,
  );
}
