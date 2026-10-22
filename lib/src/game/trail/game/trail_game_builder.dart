import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/model/data/flutter_mini_game_builder.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/game/trail/game/model/trail_difficulty.dart';
import 'package:flutter_mini_games/src/game/trail/game/model/trail_puzzle.dart';
import 'package:flutter_mini_games/src/game/trail/screen/trail_screen.dart';
import 'package:flutter_mini_games/src/game/trail/style/trail_theme.dart';

class TrailGameBuilder extends FlutterMiniGameBuilder {
  @override
  bool get isMultiPlayer => false;

  final CoreGameTheme? coreTheme;
  final TrailTheme? theme;

  /// Optional list of puzzles to play through.
  /// If not provided or empty, random puzzles will be generated based on [difficulty].
  final List<TrailPuzzle>? puzzles;

  /// Difficulty level for random puzzle generation.
  /// Used when [puzzles] is not provided or when generating new puzzles after completing all.
  final TrailDifficulty difficulty;

  TrailGameBuilder({
    super.name = 'Trail',
    super.description = 'Draw one trail through every cell, passing the numbered checkpoints in order',
    this.theme,
    this.coreTheme,
    this.puzzles,
    this.difficulty = TrailDifficulty.master,
  });

  @override
  Future<Widget> build(BuildContext context) async {
    return TrailScreen(
      coreTheme: coreTheme ?? CoreGameTheme.getDefault(),
      themeBuilder: (coreTheme) => theme ?? TrailTheme.getDefault(coreTheme: coreTheme),
      puzzles: puzzles,
      difficulty: difficulty,
    );
  }
}
