import 'package:flutter_mini_games/src/game/trail/game/model/trail_difficulty.dart';

/// Represents a Trail puzzle configuration
class TrailPuzzle {
  /// Number of rows in the grid
  final int rows;

  /// Number of columns in the grid
  final int cols;

  /// Map of checkpoint number to (row, col) position
  /// Checkpoints must be connected in order: 1 -> 2 -> 3 -> ...
  final Map<int, (int row, int col)> checkpoints;

  /// Optional name for the puzzle
  final String? name;

  /// Difficulty level (optional)
  final TrailDifficulty? difficulty;

  const TrailPuzzle({
    required this.rows,
    required this.cols,
    required this.checkpoints,
    this.name,
    this.difficulty,
  });

  /// Validates that the puzzle is solvable (basic validation)
  bool isValid() {
    // Check that checkpoints are numbered sequentially starting from 1
    for (int i = 1; i <= checkpoints.length; i++) {
      if (!checkpoints.containsKey(i)) return false;
      final pos = checkpoints[i]!;
      if (pos.$1 < 0 || pos.$1 >= rows || pos.$2 < 0 || pos.$2 >= cols) {
        return false;
      }
    }
    return checkpoints.isNotEmpty;
  }

  /// Creates a copy of this puzzle
  TrailPuzzle copyWith({
    int? rows,
    int? cols,
    Map<int, (int, int)>? checkpoints,
    String? name,
    TrailDifficulty? difficulty,
  }) {
    return TrailPuzzle(
      rows: rows ?? this.rows,
      cols: cols ?? this.cols,
      checkpoints: checkpoints ?? this.checkpoints,
      name: name ?? this.name,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}

/// Collection of sample Trail puzzles
/// All puzzles are verified solvable using snake-pattern paths
class TrailPuzzles {
  /// Simple 3x3 puzzle - Tutorial level
  /// Path: (0,0)->(0,1)->(0,2)->(1,2)->(1,1)->(1,0)->(2,0)->(2,1)->(2,2)
  static const tutorial = TrailPuzzle(
    rows: 3,
    cols: 3,
    checkpoints: {
      1: (0, 0),
      2: (2, 2),
    },
    name: 'Tutorial',
    difficulty: TrailDifficulty.easy,
  );

  /// 4x4 Easy puzzle using snake pattern
  /// Path: (0,0)->(0,1)->(0,2)->(0,3)->(1,3)->(1,2)->(1,1)->(1,0)->
  ///       (2,0)->(2,1)->(2,2)->(2,3)->(3,3)->(3,2)->(3,1)->(3,0)
  static const easy1 = TrailPuzzle(
    rows: 4,
    cols: 4,
    checkpoints: {
      1: (0, 0),
      2: (1, 0),
      3: (3, 3),
      4: (3, 0),
    },
    name: 'Easy 1',
    difficulty: TrailDifficulty.medium,
  );

  /// 5x5 Medium puzzle using snake pattern
  /// Path follows snake through all 25 cells
  static const medium1 = TrailPuzzle(
    rows: 5,
    cols: 5,
    checkpoints: {
      1: (0, 0),
      2: (0, 4),
      3: (2, 0),
      4: (2, 4),
      5: (4, 0),
      6: (4, 4),
    },
    name: 'Medium 1',
    difficulty: TrailDifficulty.hard,
  );

  /// Another 5x5 medium puzzle
  static const medium2 = TrailPuzzle(
    rows: 5,
    cols: 5,
    checkpoints: {
      1: (0, 0),
      2: (1, 4),
      3: (3, 0),
      4: (4, 4),
    },
    name: 'Medium 2',
    difficulty: TrailDifficulty.hard,
  );

  /// 6x6 Hard puzzle using snake pattern
  static const hard1 = TrailPuzzle(
    rows: 6,
    cols: 6,
    checkpoints: {
      1: (0, 0),
      2: (1, 5),
      3: (3, 0),
      4: (4, 5),
      5: (5, 0),
    },
    name: 'Hard 1',
    difficulty: TrailDifficulty.expert,
  );

  /// List of all available puzzles
  static const List<TrailPuzzle> all = [
    tutorial,
    easy1,
    medium1,
    medium2,
    hard1,
  ];

  /// Get puzzles by difficulty
  static List<TrailPuzzle> byDifficulty(TrailDifficulty difficulty) {
    return all.where((p) => p.difficulty == difficulty).toList();
  }
}
