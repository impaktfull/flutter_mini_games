import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/model/data/flutter_mini_game_builder.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/game/snake/game/logic/snake_game_controller.dart';
import 'package:flutter_mini_games/src/game/snake/screen/snake_screen.dart';
import 'package:flutter_mini_games/src/game/snake/style/snake_theme.dart';

class SnakeGameBuilder extends FlutterMiniGameBuilder {
  @override
  String get id => SnakeGameController.id;

  @override
  bool get isMultiPlayer => false;

  /// Overrides the core theme of `FlutterMiniGames` for this game
  final CoreGameTheme? coreTheme;

  /// Tweaks the default theme, e.g. `(theme) => theme.copyWith(...)`
  final GameThemeOverride<SnakeTheme>? theme;

  /// Number of columns and rows of the board
  final int gridSize;

  const SnakeGameBuilder({
    super.name = 'Snake',
    super.description = 'Eat the food to grow, without hitting the walls or yourself',
    this.coreTheme,
    this.theme,
    this.gridSize = 15,
  });

  @override
  Widget build(BuildContext context) => SnakeScreen(
    coreTheme: coreTheme,
    theme: theme,
    gridSize: gridSize,
  );
}
