import 'dart:math';

import 'package:flutter_mini_games/src/game/trail/game/model/trail_difficulty.dart';
import 'package:flutter_mini_games/src/game/trail/game/model/trail_puzzle.dart';

/// Generates random solvable Trail puzzles
class TrailPuzzleGenerator {
  final Random _random;

  TrailPuzzleGenerator({Random? random}) : _random = random ?? Random();

  /// Generates a random solvable puzzle with the given dimensions
  ///
  /// [rows] - Number of rows (minimum 3)
  /// [cols] - Number of columns (minimum 3)
  /// [checkpointCount] - Number of checkpoints to place (minimum 2, maximum rows*cols)
  /// [maxAttempts] - Maximum attempts to generate a valid puzzle
  ///
  /// Returns null if unable to generate a valid puzzle within maxAttempts
  TrailPuzzle? generate({
    int rows = 5,
    int cols = 5,
    int? checkpointCount,
    int maxAttempts = 100,
    String? name,
    TrailDifficulty? difficulty,
  }) {
    assert(rows >= 3, 'Rows must be at least 3');
    assert(cols >= 3, 'Columns must be at least 3');

    final totalCells = rows * cols;
    final actualCheckpointCount = checkpointCount ?? _calculateDefaultCheckpointCount(rows, cols);

    assert(actualCheckpointCount >= 2, 'Checkpoint count must be at least 2');
    assert(
      actualCheckpointCount <= totalCells,
      'Checkpoint count cannot exceed total cells',
    );

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      final path = _generateHamiltonianPath(rows, cols);
      if (path != null && path.length == totalCells) {
        final checkpoints = _placeCheckpoints(path, actualCheckpointCount);
        return TrailPuzzle(
          rows: rows,
          cols: cols,
          checkpoints: checkpoints,
          name: name ?? 'Random ${rows}x$cols',
          difficulty: difficulty ?? _estimateDifficulty(rows, cols),
        );
      }
    }

    return null;
  }

  /// Generates a puzzle with a specific difficulty level
  TrailPuzzle? generateWithDifficulty(TrailDifficulty difficulty) {
    final size = difficulty.gridSize;
    final baseCheckpoints = difficulty.baseCheckpoints;

    // Add some randomness to checkpoint count
    final checkpointVariation = switch (difficulty) {
      TrailDifficulty.easy => 0,
      TrailDifficulty.medium => _random.nextInt(2),
      TrailDifficulty.hard => _random.nextInt(3),
      TrailDifficulty.expert => _random.nextInt(4),
      TrailDifficulty.master => _random.nextInt(3),
    };

    return generate(
      rows: size,
      cols: size,
      checkpointCount: baseCheckpoints + checkpointVariation,
      difficulty: difficulty,
    );
  }

  /// Generates a Hamiltonian path (path that visits every cell exactly once)
  /// using randomized backtracking
  List<(int, int)>? _generateHamiltonianPath(int rows, int cols) {
    final totalCells = rows * cols;
    final visited = List.generate(rows, (_) => List.filled(cols, false));
    final path = <(int, int)>[];

    // Start from a random position
    final startRow = _random.nextInt(rows);
    final startCol = _random.nextInt(cols);

    if (_backtrack(startRow, startCol, rows, cols, visited, path, totalCells)) {
      return path;
    }

    // Try different starting positions if the first one fails
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        // Reset
        for (int i = 0; i < rows; i++) {
          for (int j = 0; j < cols; j++) {
            visited[i][j] = false;
          }
        }
        path.clear();

        if (_backtrack(r, c, rows, cols, visited, path, totalCells)) {
          return path;
        }
      }
    }

    return null;
  }

  bool _backtrack(
    int row,
    int col,
    int rows,
    int cols,
    List<List<bool>> visited,
    List<(int, int)> path,
    int totalCells,
  ) {
    // Mark current cell as visited
    visited[row][col] = true;
    path.add((row, col));

    // If we've visited all cells, we're done
    if (path.length == totalCells) {
      return true;
    }

    // Get all valid neighbors and shuffle them for randomness
    final neighbors = _getUnvisitedNeighbors(row, col, rows, cols, visited);
    neighbors.shuffle(_random);

    // Use Warnsdorff's rule heuristic: prefer cells with fewer unvisited neighbors
    // This significantly improves success rate for Hamiltonian path generation
    neighbors.sort((a, b) {
      final aNeighbors = _getUnvisitedNeighbors(a.$1, a.$2, rows, cols, visited);
      final bNeighbors = _getUnvisitedNeighbors(b.$1, b.$2, rows, cols, visited);
      return aNeighbors.length.compareTo(bNeighbors.length);
    });

    for (final neighbor in neighbors) {
      if (_backtrack(
        neighbor.$1,
        neighbor.$2,
        rows,
        cols,
        visited,
        path,
        totalCells,
      )) {
        return true;
      }
    }

    // Backtrack
    visited[row][col] = false;
    path.removeLast();
    return false;
  }

  List<(int, int)> _getUnvisitedNeighbors(
    int row,
    int col,
    int rows,
    int cols,
    List<List<bool>> visited,
  ) {
    final neighbors = <(int, int)>[];
    final directions = [(-1, 0), (1, 0), (0, -1), (0, 1)];

    for (final dir in directions) {
      final newRow = row + dir.$1;
      final newCol = col + dir.$2;
      if (newRow >= 0 && newRow < rows && newCol >= 0 && newCol < cols && !visited[newRow][newCol]) {
        neighbors.add((newRow, newCol));
      }
    }

    return neighbors;
  }

  /// Places checkpoints along the path at evenly distributed positions
  Map<int, (int, int)> _placeCheckpoints(List<(int, int)> path, int checkpointCount) {
    final checkpoints = <int, (int, int)>{};
    final pathLength = path.length;

    // Always place first checkpoint at the start
    checkpoints[1] = path[0];

    // Always place last checkpoint at the end
    checkpoints[checkpointCount] = path[pathLength - 1];

    if (checkpointCount > 2) {
      // Distribute remaining checkpoints evenly along the path
      final remainingCheckpoints = checkpointCount - 2;
      final segment = (pathLength - 1) / (remainingCheckpoints + 1);

      for (int i = 1; i <= remainingCheckpoints; i++) {
        final index = (segment * i).round();
        checkpoints[i + 1] = path[index];
      }
    }

    return checkpoints;
  }

  int _calculateDefaultCheckpointCount(int rows, int cols) {
    final totalCells = rows * cols;
    // Roughly 1 checkpoint per 4-5 cells, minimum 2, maximum 10
    return (totalCells / 4.5).round().clamp(2, 10);
  }

  TrailDifficulty _estimateDifficulty(int rows, int cols) {
    final totalCells = rows * cols;
    if (totalCells <= 9) return TrailDifficulty.easy;
    if (totalCells <= 16) return TrailDifficulty.medium;
    if (totalCells <= 25) return TrailDifficulty.hard;
    if (totalCells <= 36) return TrailDifficulty.expert;
    return TrailDifficulty.master;
  }

  /// Verifies that a puzzle is solvable by attempting to solve it
  /// Returns the solution path if solvable, null otherwise
  static List<(int, int)>? verifySolvable(TrailPuzzle puzzle) {
    final solver = _TrailPuzzleSolver(puzzle);
    return solver.solve();
  }
}

/// Internal solver to verify puzzle solvability
class _TrailPuzzleSolver {
  final TrailPuzzle puzzle;
  final List<List<bool>> visited;
  final List<(int, int)> path;
  int currentTargetCheckpoint;

  _TrailPuzzleSolver(this.puzzle)
    : visited = List.generate(
        puzzle.rows,
        (_) => List.filled(puzzle.cols, false),
      ),
      path = [],
      currentTargetCheckpoint = 1;

  List<(int, int)>? solve() {
    // Start from checkpoint 1
    final startPos = puzzle.checkpoints[1];
    if (startPos == null) return null;

    visited[startPos.$1][startPos.$2] = true;
    path.add(startPos);
    currentTargetCheckpoint = 2;

    if (_solveRecursive()) {
      return List.from(path);
    }
    return null;
  }

  bool _solveRecursive() {
    // Check if we've filled all cells, visited all checkpoints, AND ended at last checkpoint
    if (path.length == puzzle.rows * puzzle.cols) {
      final lastCheckpointPos = puzzle.checkpoints[puzzle.checkpoints.length];
      final endsAtLastCheckpoint = lastCheckpointPos != null && path.last == lastCheckpointPos;
      return currentTargetCheckpoint > puzzle.checkpoints.length && endsAtLastCheckpoint;
    }

    final current = path.last;
    final directions = [(-1, 0), (1, 0), (0, -1), (0, 1)];

    for (final dir in directions) {
      final newRow = current.$1 + dir.$1;
      final newCol = current.$2 + dir.$2;

      if (newRow >= 0 && newRow < puzzle.rows && newCol >= 0 && newCol < puzzle.cols && !visited[newRow][newCol]) {
        // Make move
        visited[newRow][newCol] = true;
        path.add((newRow, newCol));

        // Check if we hit the next target checkpoint
        final targetPos = puzzle.checkpoints[currentTargetCheckpoint];
        bool hitTarget = false;
        if (targetPos != null && targetPos.$1 == newRow && targetPos.$2 == newCol) {
          currentTargetCheckpoint++;
          hitTarget = true;
        }

        if (_solveRecursive()) {
          return true;
        }

        // Backtrack
        path.removeLast();
        visited[newRow][newCol] = false;
        if (hitTarget) {
          currentTargetCheckpoint--;
        }
      }
    }

    return false;
  }
}
