import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/model/data/flutter_mini_game_builder.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/game/minesweeper/game/logic/minesweeper_game_controller.dart';
import 'package:flutter_mini_games/src/game/minesweeper/game/model/minesweeper_difficulty.dart';
import 'package:flutter_mini_games/src/game/minesweeper/screen/minesweeper_screen.dart';
import 'package:flutter_mini_games/src/game/minesweeper/style/minesweeper_theme.dart';

class MinesweeperGameBuilder extends FlutterMiniGameBuilder {
  @override
  String get id => MinesweeperGameController.id;

  @override
  bool get isMultiPlayer => false;

  /// Overrides the core theme of `FlutterMiniGames` for this game
  final CoreGameTheme? coreTheme;

  /// Tweaks the default theme, e.g. `(theme) => theme.copyWith(...)`
  final GameThemeOverride<MinesweeperTheme>? theme;

  /// Difficulty of the first board, the player can switch in the game
  final MinesweeperDifficulty difficulty;

  const MinesweeperGameBuilder({
    super.name = 'Minesweeper',
    super.description = 'Reveal every safe cell without hitting a mine',
    this.coreTheme,
    this.theme,
    this.difficulty = MinesweeperDifficulty.easy,
  });

  @override
  Widget build(BuildContext context) => MinesweeperScreen(
    coreTheme: coreTheme,
    theme: theme,
    difficulty: difficulty,
  );
}
