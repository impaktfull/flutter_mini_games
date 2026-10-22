import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/model/data/flutter_mini_game_builder.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/game/sudoku/game/logic/sudoku_game_controller.dart';
import 'package:flutter_mini_games/src/game/sudoku/game/model/sudoku_difficulty.dart';
import 'package:flutter_mini_games/src/game/sudoku/game/model/sudoku_puzzle.dart';
import 'package:flutter_mini_games/src/game/sudoku/screen/sudoku_screen.dart';
import 'package:flutter_mini_games/src/game/sudoku/style/sudoku_theme.dart';

class SudokuGameBuilder extends FlutterMiniGameBuilder {
  @override
  String get id => SudokuGameController.id;

  @override
  bool get isMultiPlayer => false;

  /// Overrides the core theme of `FlutterMiniGames` for this game
  final CoreGameTheme? coreTheme;

  /// Tweaks the default theme, e.g. `(theme) => theme.copyWith(...)`
  final GameThemeOverride<SudokuTheme>? theme;

  /// Optional list of puzzles to play through, e.g. created with `SudokuPuzzle.fromString`.
  /// If not provided or empty, random puzzles will be generated based on [difficulty].
  final List<SudokuPuzzle>? puzzles;

  /// Difficulty level for random puzzle generation.
  /// Used when [puzzles] is not provided or when generating new puzzles after completing all.
  final SudokuDifficulty difficulty;

  const SudokuGameBuilder({
    super.name = 'Sudoku',
    super.description = 'Fill the grid so every row, column and box contains the digits 1 to 9',
    this.coreTheme,
    this.theme,
    this.puzzles,
    this.difficulty = SudokuDifficulty.medium,
  });

  @override
  Widget build(BuildContext context) => SudokuScreen(
    coreTheme: coreTheme,
    theme: theme,
    puzzles: puzzles,
    difficulty: difficulty,
  );
}
