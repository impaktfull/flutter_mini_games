import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/model/data/flutter_mini_game_builder.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/game/trail/game/logic/trail_game_controller.dart';
import 'package:flutter_mini_games/src/game/trail/game/model/trail_difficulty.dart';
import 'package:flutter_mini_games/src/game/trail/game/model/trail_puzzle.dart';
import 'package:flutter_mini_games/src/game/trail/screen/trail_screen.dart';
import 'package:flutter_mini_games/src/game/trail/style/trail_theme.dart';

class TrailGameBuilder extends FlutterMiniGameBuilder {
  @override
  String get id => TrailGameController.id;

  @override
  bool get isMultiPlayer => false;

  /// Overrides the core theme of `FlutterMiniGames` for this game
  final CoreGameTheme? coreTheme;

  /// Tweaks the default theme, e.g. `(theme) => theme.copyWith(...)`
  final GameThemeOverride<TrailTheme>? theme;

  /// Optional list of puzzles to play through.
  /// If not provided or empty, random puzzles will be generated based on [difficulty].
  final List<TrailPuzzle>? puzzles;

  /// Difficulty level for random puzzle generation.
  /// Used when [puzzles] is not provided or when generating new puzzles after completing all.
  final TrailDifficulty difficulty;

  const TrailGameBuilder({
    super.name = 'Trail',
    super.description = 'Draw one trail through every cell, passing the numbered checkpoints in order',
    this.coreTheme,
    this.theme,
    this.puzzles,
    this.difficulty = TrailDifficulty.hard,
  });

  @override
  Widget build(BuildContext context) => TrailScreen(
    coreTheme: coreTheme,
    theme: theme,
    puzzles: puzzles,
    difficulty: difficulty,
  );
}
