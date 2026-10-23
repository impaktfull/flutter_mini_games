import 'dart:math';

import 'package:flutter/foundation.dart';

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
  ///
  /// Always succeeds and runs in a few milliseconds, also for large grids.
  TrailPuzzle generate({
    int rows = 5,
    int cols = 5,
    int? checkpointCount,
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

    final path = generatePath(rows, cols);
    return TrailPuzzle(
      rows: rows,
      cols: cols,
      checkpoints: _placeCheckpoints(path, actualCheckpointCount),
      name: name ?? 'Random ${rows}x$cols',
      difficulty: difficulty ?? _estimateDifficulty(rows, cols),
    );
  }

  /// Generates a puzzle with a specific difficulty level
  TrailPuzzle generateWithDifficulty(TrailDifficulty difficulty) {
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

  /// Generates a random Hamiltonian path (a path that visits every cell exactly once)
  /// with backbite moves: start from a zigzag path, then repeatedly connect one end to a
  /// random grid neighbour and reverse the part of the path after that neighbour.
  /// Every move keeps a valid path, so this always finishes after `cells²` moves (a few milliseconds)
  /// (random backtracking can take exponential time and froze the app on a 7x7 grid).
  @visibleForTesting
  List<(int, int)> generatePath(int rows, int cols) {
    final path = <(int, int)>[
      for (var row = 0; row < rows; row++)
        for (var i = 0; i < cols; i++) (row, row.isEven ? i : cols - 1 - i),
    ];
    // Position of every cell (row * cols + col) in the path
    final indexOf = List<int>.filled(path.length, 0);
    void reverse(int from) {
      for (var i = from, j = path.length - 1; i < j; i++, j--) {
        final cell = path[i];
        path[i] = path[j];
        path[j] = cell;
      }
      for (var i = from; i < path.length; i++) {
        indexOf[path[i].$1 * cols + path[i].$2] = i;
      }
    }

    reverse(0);
    final moves = path.length * path.length;
    for (var move = 0; move < moves; move++) {
      // Backbite from either end
      if (_random.nextBool()) reverse(0);
      final (row, col) = path.last;
      final neighbours = [
        if (row > 0) (row - 1, col),
        if (row < rows - 1) (row + 1, col),
        if (col > 0) (row, col - 1),
        if (col < cols - 1) (row, col + 1),
      ];
      final (nRow, nCol) = neighbours[_random.nextInt(neighbours.length)];
      final index = indexOf[nRow * cols + nCol];
      if (index < path.length - 2) reverse(index + 1);
    }
    return path;
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
