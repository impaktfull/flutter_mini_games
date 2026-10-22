import 'dart:collection';
import 'dart:math';

import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/controller/realtime_game_controller.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';
import 'package:flutter_mini_games/src/core/widget/input/game_input_detector.dart';
import 'package:flutter_mini_games/src/game/snake/game/model/snake_cell.dart';

/// Classic Snake on a square grid.
///
/// The snake moves one cell per step. Steps are driven by [tick] with a time accumulator,
/// so the speed does not depend on the frame rate. The step interval starts at
/// [initialStepInterval] and gets shorter for every food eaten, down to [minStepInterval].
class SnakeGameController extends GameController with RealtimeGameController {
  static const id = 'snake';

  static const initialLength = 3;
  static const initialStepInterval = Duration(milliseconds: 180);
  static const minStepInterval = Duration(milliseconds: 80);

  /// The step interval gets this much shorter for every food eaten
  static const stepIntervalDecrease = Duration(milliseconds: 5);

  /// Points for every food eaten
  static const pointsPerFood = 10;

  /// Direction changes that can be queued, so quick swipes are not lost
  static const maxQueuedDirections = 2;

  /// Number of columns and rows of the board
  final int gridSize;
  final Random _random;

  /// Head first
  List<SnakeCell> _snake = const [];
  SnakeCell? _removedTail;
  SnakeCell? _food;
  GameDirection _direction = GameDirection.right;
  final Queue<GameDirection> _queuedDirections = Queue();
  Duration _accumulated = Duration.zero;
  int _score = 0;

  SnakeGameController({
    this.gridSize = 15,
    Random? random,
  }) : assert(gridSize >= initialLength + 2, 'The grid is too small'),
       _random = random ?? Random(),
       super(gameId: id) {
    _setUp();
  }

  /// The cells of the snake, head first
  List<SnakeCell> get snake => _snake;
  SnakeCell get head => _snake.first;

  /// The cell the tail left in the last step, null when the snake grew (used to animate the tail)
  SnakeCell? get removedTail => _removedTail;

  /// Null when the board is full
  SnakeCell? get food => _food;
  GameDirection get direction => _direction;
  List<GameDirection> get queuedDirections => List.unmodifiable(_queuedDirections);
  int get score => _score;
  bool get isWon => result?.outcome == GameOutcome.won;
  bool get isLost => result?.outcome == GameOutcome.lost;

  /// Time between two steps, shorter when the snake is longer
  Duration get stepInterval {
    final eaten = _snake.length - initialLength;
    final interval = initialStepInterval - stepIntervalDecrease * eaten;
    return interval < minStepInterval ? minStepInterval : interval;
  }

  /// How far the snake is between the previous step (0) and the current one (1), for smooth rendering
  double get stepProgress {
    if (status != GameStatus.playing) return 1;
    return (_accumulated.inMicroseconds / stepInterval.inMicroseconds).clamp(0.0, 1.0);
  }

  @override
  bool get isRunning => status == GameStatus.playing;

  void _setUp() {
    final y = gridSize ~/ 2;
    final headX = gridSize ~/ 2;
    _snake = [for (var i = 0; i < initialLength; i++) SnakeCell(headX - i, y)];
    _removedTail = null;
    _direction = GameDirection.right;
    _queuedDirections.clear();
    _accumulated = Duration.zero;
    _score = 0;
    _food = _spawnFood();
  }

  /// Turns the snake. The first direction starts the game. Reversing into the snake is ignored.
  void changeDirection(GameDirection direction) {
    if (isFinished) return;
    final last = _queuedDirections.isEmpty ? _direction : _queuedDirections.last;
    final isValid = direction != last && direction != _opposite(last) && _queuedDirections.length < maxQueuedDirections;
    if (status == GameStatus.ready) {
      registerMove();
      if (isValid) _queuedDirections.add(direction);
      // Take the first step right away, the snake is drawn one step behind
      _accumulated = stepInterval;
      notifyListeners();
      return;
    }
    if (!isValid) return;
    _queuedDirections.add(direction);
    registerMove();
    notifyListeners();
  }

  @override
  void tick(Duration delta) {
    if (!isRunning) return;
    _accumulated += delta;
    while (isRunning && _accumulated >= stepInterval) {
      _accumulated -= stepInterval;
      _step();
    }
    notifyListeners();
  }

  void _step() {
    if (_queuedDirections.isNotEmpty) _direction = _queuedDirections.removeFirst();
    final newHead = _snake.first.move(_direction);
    final eats = newHead == _food;
    // The tail moves away in this step, unless the snake grows
    final body = eats ? _snake : _snake.sublist(0, _snake.length - 1);
    if (!_isInside(newHead) || body.contains(newHead)) {
      _accumulated = Duration.zero;
      finish(GameOutcome.lost, score: _score);
      return;
    }
    _removedTail = eats ? null : _snake.last;
    _snake = [newHead, ...body];
    if (!eats) return;
    _score += pointsPerFood;
    _food = _spawnFood();
    if (_food == null) {
      _accumulated = Duration.zero;
      finish(GameOutcome.won, score: _score);
    }
  }

  bool _isInside(SnakeCell cell) => cell.x >= 0 && cell.y >= 0 && cell.x < gridSize && cell.y < gridSize;

  /// A random empty cell, null when the snake fills the board
  SnakeCell? _spawnFood() {
    final occupied = _snake.toSet();
    final empty = [
      for (var y = 0; y < gridSize; y++)
        for (var x = 0; x < gridSize; x++)
          if (!occupied.contains(SnakeCell(x, y))) SnakeCell(x, y),
    ];
    if (empty.isEmpty) return null;
    return empty[_random.nextInt(empty.length)];
  }

  static GameDirection _opposite(GameDirection direction) => switch (direction) {
    GameDirection.up => GameDirection.down,
    GameDirection.down => GameDirection.up,
    GameDirection.left => GameDirection.right,
    GameDirection.right => GameDirection.left,
  };

  void resetGame() {
    restartSession();
    _setUp();
    notifyListeners();
  }
}
