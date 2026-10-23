import 'dart:collection';
import 'dart:math';

import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/controller/realtime_game_controller.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';
import 'package:flutter_mini_games/src/game/flit/game/model/flit_column.dart';

/// Endless side-scroller: tap to flap, fly through the gaps between the columns.
///
/// All positions are in world units: the world is [worldWidth] wide and 1.0 high,
/// y grows downwards and the ground starts at [groundY].
class FlitGameController extends GameController with RealtimeGameController {
  static const id = 'flit';

  /// Width of the world, the board has the same aspect ratio (3:4)
  static const worldWidth = 0.75;

  /// Top of the ground, the flyer crashes when it touches it
  static const groundY = 0.9;

  /// Fixed horizontal position of the flyer's center
  static const flyerX = 0.22;

  /// Drawn radius of the flyer
  static const flyerRadius = 0.034;

  /// Radius used for collisions, smaller than [flyerRadius] to be forgiving
  static const hitboxRadius = 0.026;

  /// Downward acceleration in world units per second²
  static const gravity = 2.6;

  /// Vertical velocity set by a flap (negative is up)
  static const flapVelocity = -0.75;

  /// Fastest fall speed
  static const maxFallSpeed = 1.4;

  /// Horizontal speed of the columns in world units per second
  static const scrollSpeed = 0.3;

  static const columnWidth = 0.13;

  /// Horizontal distance between the left edges of two consecutive columns
  static const columnSpacing = 0.42;

  /// Distance between the right edge of the world and the first column
  static const firstColumnOffset = 0.2;

  /// Gap of the first column, every next column shrinks it by [gapShrink] until [minGapSize]
  static const initialGapSize = 0.3;
  static const minGapSize = 0.23;
  static const gapShrink = 0.004;

  /// Smallest distance between a gap and the top or the ground
  static const gapMargin = 0.1;

  /// Largest vertical distance between the centers of two consecutive gaps
  static const maxGapShift = 0.22;

  /// Start height of the flyer
  static const startY = 0.42;

  final Random _random;
  final List<FlitColumn> _columns = [];
  double _flyerY = startY;
  double _velocity = 0;
  int _score = 0;
  int _spawned = 0;

  FlitGameController({Random? random}) : _random = random ?? Random(), super(gameId: id);

  double get flyerY => _flyerY;

  /// Vertical velocity of the flyer, negative is up
  double get velocity => _velocity;

  /// Tilt of the flyer in radians: nose up while rising, down while falling
  double get flyerRotation => (_velocity * 0.7).clamp(-0.45, 1.2);

  List<FlitColumn> get columns => UnmodifiableListView(_columns);

  /// Number of columns passed
  int get score => _score;

  bool get isReady => status == GameStatus.ready;

  bool get isGameOver => isFinished;

  @override
  bool get isRunning => status == GameStatus.playing && !isGameOver;

  /// Gives the flyer an upward impulse, the first flap starts the game
  void flap() {
    if (isGameOver) return;
    if (isReady) _spawnInitialColumns();
    registerMove();
    _velocity = flapVelocity;
    notifyListeners();
  }

  @override
  void tick(Duration delta) {
    if (!isRunning) return;
    final seconds = delta.inMicroseconds / Duration.microsecondsPerSecond;

    _velocity = min(_velocity + gravity * seconds, maxFallSpeed);
    _flyerY += _velocity * seconds;

    final score = _score;
    _moveColumns(scrollSpeed * seconds);

    if (_isColliding()) {
      _flyerY = _flyerY.clamp(hitboxRadius, groundY - hitboxRadius);
      finish(GameOutcome.lost, score: _score);
      notifyListeners();
    } else if (_score != score) {
      notifyListeners();
    } else {
      // Only the board moves
      notifyFrame();
    }
  }

  void resetGame() {
    restartSession();
    _columns.clear();
    _flyerY = startY;
    _velocity = 0;
    _score = 0;
    _spawned = 0;
    notifyListeners();
  }

  void _spawnInitialColumns() {
    _columns.clear();
    _spawned = 0;
    _addColumn(worldWidth + firstColumnOffset);
    _fillColumns();
  }

  void _moveColumns(double distance) {
    for (var i = 0; i < _columns.length; i++) {
      var column = _columns[i].copyWith(x: _columns[i].x - distance);
      if (!column.isPassed && column.x + columnWidth < flyerX) {
        column = column.copyWith(isPassed: true);
        _score++;
      }
      _columns[i] = column;
    }
    // Recycle columns that left the screen
    _columns.removeWhere((column) => column.x + columnWidth < 0);
    _fillColumns();
  }

  /// Keeps the next column queued past the right edge of the world
  void _fillColumns() {
    while (_columns.isEmpty || _columns.last.x <= worldWidth) {
      _addColumn(_columns.isEmpty ? worldWidth : _columns.last.x + columnSpacing);
    }
  }

  void _addColumn(double x) {
    final gapSize = max(minGapSize, initialGapSize - gapShrink * _spawned);
    var low = gapMargin + gapSize / 2;
    var high = groundY - gapMargin - gapSize / 2;
    if (_columns.isNotEmpty) {
      final previous = _columns.last.gapCenter;
      low = max(low, previous - maxGapShift);
      high = min(high, previous + maxGapShift);
    }
    final gapCenter = low + _random.nextDouble() * (high - low);
    _columns.add(FlitColumn(x: x, gapCenter: gapCenter, gapSize: gapSize));
    _spawned++;
  }

  bool _isColliding() {
    if (_flyerY - hitboxRadius <= 0) return true;
    if (_flyerY + hitboxRadius >= groundY) return true;
    for (final column in _columns) {
      if (_circleHitsRect(column.x, 0, column.x + columnWidth, column.gapTop)) return true;
      if (_circleHitsRect(column.x, column.gapBottom, column.x + columnWidth, groundY)) return true;
    }
    return false;
  }

  bool _circleHitsRect(double left, double top, double right, double bottom) {
    final dx = flyerX - flyerX.clamp(left, right);
    final dy = _flyerY - _flyerY.clamp(top, bottom);
    return dx * dx + dy * dy < hitboxRadius * hitboxRadius;
  }
}
