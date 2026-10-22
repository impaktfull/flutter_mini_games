import 'dart:math';

import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';
import 'package:flutter_mini_games/src/core/widget/input/game_input_detector.dart';
import 'package:flutter_mini_games/src/game/twenty_forty_eight/game/model/twenty_forty_eight_tile.dart';

class TwentyFortyEightGameController extends GameController {
  static const id = 'twenty_forty_eight';

  /// Number of rows and columns
  static const size = 4;

  /// Reaching this tile wins the game
  static const winValue = 2048;

  /// Chance that a spawned tile is a 4 instead of a 2
  static const fourChance = 0.1;

  final Random _random;
  final List<List<int>>? _initialBoard;
  late List<List<TwentyFortyEightTile?>> _grid;
  int _score = 0;
  int _nextTileId = 0;

  /// [initialBoard] (4x4, 0 = empty) replaces the two random start tiles, e.g. for tests
  TwentyFortyEightGameController({
    Random? random,
    List<List<int>>? initialBoard,
  }) : _random = random ?? Random(),
       _initialBoard = initialBoard,
       super(gameId: id) {
    _startGame();
  }

  /// Sum of all merged tile values
  int get score => _score;

  /// Tiles on the board, in a stable order (by id) so widgets keep their state
  List<TwentyFortyEightTile> get tiles => [
    for (final row in _grid)
      for (final tile in row)
        if (tile != null) tile,
  ]..sort((a, b) => a.id.compareTo(b.id));

  /// Values on the board, 0 = empty
  List<List<int>> get board => [
    for (final row in _grid) [for (final tile in row) tile?.value ?? 0],
  ];

  int get highestTile => tiles.fold(0, (highest, tile) => max(highest, tile.value));

  bool get isWon => result?.outcome == GameOutcome.won;

  /// No move left
  bool get isGameOver => result?.outcome == GameOutcome.lost;

  /// Whether any move would change the board
  bool get canMove {
    for (var row = 0; row < size; row++) {
      for (var col = 0; col < size; col++) {
        final value = _grid[row][col]?.value;
        if (value == null) return true;
        if (col + 1 < size && _grid[row][col + 1]?.value == value) return true;
        if (row + 1 < size && _grid[row + 1][col]?.value == value) return true;
      }
    }
    return false;
  }

  void _startGame() {
    _score = 0;
    _grid = List.generate(size, (_) => List<TwentyFortyEightTile?>.filled(size, null));
    final initialBoard = _initialBoard;
    if (initialBoard == null) {
      _spawnTile();
      _spawnTile();
      return;
    }
    assert(initialBoard.length == size && initialBoard.every((row) => row.length == size), 'initialBoard must be ${size}x$size');
    for (var row = 0; row < size; row++) {
      for (var col = 0; col < size; col++) {
        final value = initialBoard[row][col];
        if (value > 0) _grid[row][col] = TwentyFortyEightTile(id: _nextTileId++, value: value, row: row, col: col, isNew: true);
      }
    }
  }

  /// Slides all tiles in [direction]. Returns whether the board changed.
  bool move(GameDirection direction) {
    if (isFinished) return false;
    final next = List.generate(size, (_) => List<TwentyFortyEightTile?>.filled(size, null));
    var gained = 0;
    var reachedWinValue = false;

    for (var line = 0; line < size; line++) {
      final positions = _linePositions(direction, line);
      final lineTiles = [
        for (final (row, col) in positions)
          if (_grid[row][col] case final tile?) tile,
      ];
      var target = 0;
      var i = 0;
      while (i < lineTiles.length) {
        final (row, col) = positions[target++];
        final tile = lineTiles[i];
        if (i + 1 < lineTiles.length && lineTiles[i + 1].value == tile.value) {
          // Equal tiles merge once: the merged tile does not merge again in this move
          final value = tile.value * 2;
          gained += value;
          if (value >= winValue) reachedWinValue = true;
          next[row][col] = tile.copyWith(value: value, row: row, col: col, isNew: false, isMerged: true);
          i += 2;
        } else {
          next[row][col] = tile.copyWith(row: row, col: col, isNew: false, isMerged: false);
          i++;
        }
      }
    }

    if (!_hasChanged(next)) return false;

    _grid = next;
    _score += gained;
    registerMove();
    _spawnTile();
    if (reachedWinValue) {
      finish(GameOutcome.won, score: _score);
    } else if (!canMove) {
      finish(GameOutcome.lost, score: _score);
    }
    notifyListeners();
    return true;
  }

  void resetGame() {
    restartSession();
    _startGame();
    notifyListeners();
  }

  /// Cells of one row or column, starting at the wall the tiles slide towards
  static List<(int, int)> _linePositions(GameDirection direction, int line) => [
    for (var i = 0; i < size; i++)
      switch (direction) {
        GameDirection.left => (line, i),
        GameDirection.right => (line, size - 1 - i),
        GameDirection.up => (i, line),
        GameDirection.down => (size - 1 - i, line),
      },
  ];

  bool _hasChanged(List<List<TwentyFortyEightTile?>> next) {
    for (var row = 0; row < size; row++) {
      for (var col = 0; col < size; col++) {
        if (_grid[row][col]?.value != next[row][col]?.value) return true;
      }
    }
    return false;
  }

  void _spawnTile() {
    final empty = [
      for (var row = 0; row < size; row++)
        for (var col = 0; col < size; col++)
          if (_grid[row][col] == null) (row, col),
    ];
    if (empty.isEmpty) return;
    final (row, col) = empty[_random.nextInt(empty.length)];
    final value = _random.nextDouble() < fourChance ? 4 : 2;
    _grid[row][col] = TwentyFortyEightTile(id: _nextTileId++, value: value, row: row, col: col, isNew: true);
  }
}
