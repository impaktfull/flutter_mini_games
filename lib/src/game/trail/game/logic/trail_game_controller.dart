import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/game/trail/game/model/trail_difficulty.dart';
import 'package:flutter_mini_games/src/game/trail/game/model/trail_direction.dart';
import 'package:flutter_mini_games/src/game/trail/game/model/trail_puzzle.dart';
import 'package:flutter_mini_games/src/game/trail/game/model/trail_puzzle_generator.dart';

class TrailGameController extends GameController {
  final List<TrailPuzzle> _puzzles;
  final TrailDifficulty _difficulty;
  int _currentPuzzleIndex = 0;

  TrailPuzzle _puzzle;
  List<List<int?>> _grid = []; // null = empty, number = order in trail
  final List<(int row, int col)> _path = [];
  int _currentTargetCheckpoint = 1;
  bool _isGameOver = false;
  bool _isWon = false;

  TrailGameController({
    List<TrailPuzzle>? puzzles,
    TrailDifficulty difficulty = TrailDifficulty.hard,
  }) : _puzzles = puzzles ?? [],
       _difficulty = difficulty,
       _puzzle = (puzzles != null && puzzles.isNotEmpty) ? puzzles.first : _generatePuzzle(difficulty) {
    _startPuzzle();
  }

  static TrailPuzzle _generatePuzzle(TrailDifficulty difficulty) {
    final generator = TrailPuzzleGenerator();
    final puzzle = generator.generateWithDifficulty(difficulty);
    if (puzzle != null) return puzzle;

    // Fallback to predefined puzzles
    return switch (difficulty) {
      TrailDifficulty.easy => TrailPuzzles.tutorial,
      TrailDifficulty.medium => TrailPuzzles.easy1,
      TrailDifficulty.hard => TrailPuzzles.medium1,
      TrailDifficulty.expert => TrailPuzzles.hard1,
      TrailDifficulty.master => TrailPuzzles.hard1,
    };
  }

  TrailPuzzle get puzzle => _puzzle;
  List<List<int?>> get grid => _grid;
  List<(int row, int col)> get path => _path;
  int get currentTargetCheckpoint => _currentTargetCheckpoint;
  bool get isGameOver => _isGameOver;
  bool get isWon => _isWon;
  int get totalCells => _puzzle.rows * _puzzle.cols;
  int get filledCells => _path.length;
  bool get canUndo => _path.length > 1 && !_isWon;
  int get currentPuzzleIndex => _currentPuzzleIndex;
  int get totalPuzzles => _puzzles.length;
  bool get hasMorePuzzles => _puzzles.isNotEmpty && _currentPuzzleIndex < _puzzles.length - 1;
  bool get isGeneratedMode => _puzzles.isEmpty;
  TrailDifficulty get difficulty => _difficulty;

  /// Clears the grid and starts the trail on checkpoint 1
  void _startPuzzle() {
    _grid = List.generate(_puzzle.rows, (_) => List.filled(_puzzle.cols, null));
    _path.clear();
    _currentTargetCheckpoint = 1;
    _isGameOver = false;
    _isWon = false;

    final start = _puzzle.checkpoints[1];
    if (start != null) {
      _grid[start.$1][start.$2] = 1;
      _path.add(start);
      _currentTargetCheckpoint = 2;
    }
  }

  bool isCheckpointPosition(int row, int col) => getCheckpointNumber(row, col) != null;

  int? getCheckpointNumber(int row, int col) {
    for (final entry in _puzzle.checkpoints.entries) {
      if (entry.value == (row, col)) return entry.key;
    }
    return null;
  }

  bool isCurrentTarget(int row, int col) => _puzzle.checkpoints[_currentTargetCheckpoint] == (row, col);

  bool isInPath(int row, int col) => _grid[row][col] != null;

  int? getPathOrder(int row, int col) => _grid[row][col];

  bool isAdjacent(int row1, int col1, int row2, int col2) {
    final rowDiff = (row1 - row2).abs();
    final colDiff = (col1 - col2).abs();
    // Only allow horizontal and vertical moves (not diagonal)
    return (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1);
  }

  bool canMoveTo(int row, int col) {
    if (_isGameOver) return false;
    if (_grid[row][col] != null) return false;
    if (_path.isEmpty) return false;

    final lastPos = _path.last;
    return isAdjacent(lastPos.$1, lastPos.$2, row, col);
  }

  void moveTo(int row, int col) {
    if (!canMoveTo(row, col)) return;

    _path.add((row, col));
    _grid[row][col] = _path.length;

    if (_puzzle.checkpoints[_currentTargetCheckpoint] == (row, col)) {
      _currentTargetCheckpoint++;
    }

    _checkWinCondition();
    notifyListeners();
  }

  /// Removes the last step of the trail. Also possible when stuck, but not after winning.
  void undo() {
    if (!canUndo) return;

    final (row, col) = _path.removeLast();
    _grid[row][col] = null;
    if (_puzzle.checkpoints[_currentTargetCheckpoint - 1] == (row, col)) {
      _currentTargetCheckpoint--;
    }
    _isGameOver = false;
    notifyListeners();
  }

  void _checkWinCondition() {
    // Win conditions:
    // 1. All cells are filled
    // 2. All checkpoints were visited in order
    // 3. Trail ENDS at the last checkpoint
    final allCellsFilled = _path.length == totalCells;
    final allCheckpointsVisited = _currentTargetCheckpoint > _puzzle.checkpoints.length;
    final endsAtLastCheckpoint = _path.last == _puzzle.checkpoints[_puzzle.checkpoints.length];

    if (allCellsFilled && allCheckpointsVisited && endsAtLastCheckpoint) {
      _isWon = true;
      _isGameOver = true;
    } else if (allCellsFilled || !_hasValidMoves()) {
      // Filled every cell without meeting the other conditions, or stuck
      _isGameOver = true;
    }
  }

  bool _hasValidMoves() {
    final (row, col) = _path.last;
    const directions = [(-1, 0), (1, 0), (0, -1), (0, 1)];
    for (final (dRow, dCol) in directions) {
      final newRow = row + dRow;
      final newCol = col + dCol;
      if (newRow >= 0 && newRow < _puzzle.rows && newCol >= 0 && newCol < _puzzle.cols && _grid[newRow][newCol] == null) {
        return true;
      }
    }
    return false;
  }

  void resetGame() {
    _startPuzzle();
    notifyListeners();
  }

  /// Load the next puzzle in the list, or generate a new one if in generated mode
  void nextPuzzle() {
    if (hasMorePuzzles) {
      _currentPuzzleIndex++;
      _puzzle = _puzzles[_currentPuzzleIndex];
    } else {
      _puzzle = _generatePuzzle(_difficulty);
    }
    resetGame();
  }

  void loadPuzzle(TrailPuzzle newPuzzle) {
    _puzzle = newPuzzle;
    resetGame();
  }

  /// Directions in which the trail leaves the given cell, used for rendering
  Set<TrailDirection> getPathDirections(int row, int col) {
    final order = _grid[row][col];
    if (order == null) return const {};

    final index = order - 1;
    final cell = (row, col);
    return {
      if (index > 0) TrailDirection.between(cell, _path[index - 1]),
      if (index < _path.length - 1) TrailDirection.between(cell, _path[index + 1]),
    };
  }
}
