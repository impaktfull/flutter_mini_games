import 'dart:collection';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/controller/realtime_game_controller.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';
import 'package:flutter_mini_games/src/core/widget/input/game_input_detector.dart';
import 'package:flutter_mini_games/src/game/dash/game/model/dash_obstacle.dart';

/// Endless runner: the runner stays at a fixed x while obstacles scroll in from the right.
///
/// Everything is in world units: x to the right, y up from the ground. The world is
/// [worldWidth] x [worldHeight] units, the painter scales it to the canvas.
class DashGameController extends GameController with RealtimeGameController {
  static const id = 'dash';

  // World
  static const worldWidth = 12.0;
  static const worldHeight = 8.0;

  /// Part of the world below the ground line
  static const groundHeight = 1.5;

  // Runner
  static const runnerX = 1.5;
  static const runnerWidth = 1.0;
  static const runnerHeight = 1.2;
  static const duckWidth = 1.3;
  static const duckHeight = 0.7;

  /// Hitboxes are this much smaller than the drawn shapes on every side (forgiving collisions)
  static const runnerHitboxInset = 0.15;
  static const obstacleHitboxInset = 0.1;

  // Physics (units per second)
  static const gravity = 54.0;
  static const jumpVelocity = 18.0;

  /// Gravity multiplier while falling fast (swipe down in the air)
  static const fastFallMultiplier = 3.0;

  /// How long one swipe down keeps the runner ducked, in seconds
  static const duckDuration = 0.6;

  // Speed
  static const initialSpeed = 7.0;
  static const maxSpeed = 14.0;

  /// Speed gained per second
  static const acceleration = 0.1;

  // Obstacles
  /// Distance the world scrolls before the first obstacle enters the screen
  static const firstObstacleDistance = 6.0;

  /// Distance after which flyers can appear
  static const flyersFromDistance = 150.0;

  /// Time the player gets between landing and the next obstacle
  static const reactionTime = 0.35;

  /// Random extra time between obstacles
  static const maxExtraGapTime = 0.8;

  static const pointsPerUnit = 10;

  /// Ground obstacles as (width, height)
  static const blockSizes = [(0.6, 0.9), (0.6, 1.4), (1.0, 1.1), (1.5, 0.9), (1.8, 1.2)];
  static const flyerWidth = 1.0;
  static const flyerHeight = 0.5;
  static const lowFlyerBottom = 0.8;
  static const highFlyerBottom = 1.5;

  /// Time in the air of a full jump
  static const airTime = 2 * jumpVelocity / gravity;

  final Random _random;
  final List<DashObstacle> _obstacles = [];
  double _distance = 0;
  double _speed = initialSpeed;
  double _runnerY = 0;
  double _velocityY = 0;
  double _duckTime = 0;
  double _nextObstacleIn = firstObstacleDistance;

  DashGameController({Random? random}) : _random = random ?? Random(), super(gameId: id);

  @override
  bool get isRunning => status == GameStatus.playing;

  bool get isReady => status == GameStatus.ready;
  bool get isGameOver => result?.outcome == GameOutcome.lost;

  /// Scrolled distance in world units
  double get distance => _distance;
  double get speed => _speed;
  int get score => (_distance * pointsPerUnit).floor();

  /// Height of the runner's feet above the ground
  double get runnerY => _runnerY;
  bool get isOnGround => _runnerY <= 0 && _velocityY <= 0;
  bool get isDucking => isOnGround && _duckTime > 0;
  bool get isFastFalling => !isOnGround && _duckTime > 0;
  double get runnerWidthNow => isDucking ? duckWidth : runnerWidth;
  double get runnerHeightNow => isDucking ? duckHeight : runnerHeight;
  List<DashObstacle> get obstacles => UnmodifiableListView(_obstacles);

  /// Runner hitbox in world units (`top` is the lowest y, `bottom` the highest)
  Rect get runnerHitbox => Rect.fromLTRB(
    runnerX + runnerHitboxInset,
    _runnerY + runnerHitboxInset / 3,
    runnerX + runnerWidthNow - runnerHitboxInset,
    _runnerY + runnerHeightNow - runnerHitboxInset,
  );

  static Rect obstacleHitbox(DashObstacle obstacle) => Rect.fromLTRB(
    obstacle.x + obstacleHitboxInset,
    obstacle.bottom + (obstacle.isFlyer ? obstacleHitboxInset : 0),
    obstacle.right - obstacleHitboxInset,
    obstacle.top - obstacleHitboxInset,
  );

  /// Tap, space or up: starts the game and jumps. No double jump in the air.
  void jump() {
    if (isFinished || !isOnGround) return;
    registerMove();
    _velocityY = jumpVelocity;
    _duckTime = 0;
    notifyListeners();
  }

  /// Swipe down: ducks on the ground, falls fast in the air
  void duck() {
    if (!isRunning) return;
    _duckTime = duckDuration;
    notifyListeners();
  }

  void onSwipe(GameDirection direction) {
    switch (direction) {
      case GameDirection.up:
        jump();
      case GameDirection.down:
        duck();
      case GameDirection.left:
      case GameDirection.right:
        break;
    }
  }

  @override
  void tick(Duration delta) {
    if (!isRunning) return;
    final seconds = delta.inMicroseconds / Duration.microsecondsPerSecond;

    // Scroll, the speed increases linearly until maxSpeed
    final previousSpeed = _speed;
    _speed = min(maxSpeed, _speed + acceleration * seconds);
    final dx = (previousSpeed + _speed) / 2 * seconds;
    _distance += dx;

    _updateRunner(seconds);
    _updateObstacles(dx);

    if (_obstacles.any((obstacle) => runnerHitbox.overlaps(obstacleHitbox(obstacle)))) {
      finish(GameOutcome.lost, score: score, data: {'distance': _distance.round()});
    }
    notifyListeners();
  }

  void _updateRunner(double seconds) {
    if (!isOnGround) {
      final g = gravity * (_duckTime > 0 ? fastFallMultiplier : 1);
      // Exact for constant gravity, so the jump arc does not depend on the frame rate
      _runnerY += _velocityY * seconds - g * seconds * seconds / 2;
      _velocityY -= g * seconds;
      if (_runnerY <= 0) {
        _runnerY = 0;
        _velocityY = 0;
      }
    }
    _duckTime = max(0, _duckTime - seconds);
  }

  void _updateObstacles(double dx) {
    for (final obstacle in _obstacles) {
      obstacle.x -= dx;
    }
    _obstacles.removeWhere((obstacle) => obstacle.right < 0);
    _nextObstacleIn -= dx;
    if (_nextObstacleIn <= 0) {
      // Spawn exactly where it would have been, independent of the frame rate
      final obstacle = _createObstacle(worldWidth + _nextObstacleIn);
      _obstacles.add(obstacle);
      _nextObstacleIn += obstacle.width + minimumGap(_speed) + _speed * _random.nextDouble() * maxExtraGapTime;
    }
  }

  /// Smallest free distance between two obstacles at [speed]: a full jump plus time to react.
  /// Uses a slightly higher speed because the game speeds up before the obstacle arrives.
  static double minimumGap(double speed) => min(maxSpeed, speed + 1) * (airTime + reactionTime);

  DashObstacle _createObstacle(double x) {
    if (_distance >= flyersFromDistance && _random.nextDouble() < 0.3) {
      final isLow = _random.nextDouble() < 0.65;
      return DashObstacle(
        type: isLow ? DashObstacleType.lowFlyer : DashObstacleType.highFlyer,
        x: x,
        width: flyerWidth,
        height: flyerHeight,
        bottom: isLow ? lowFlyerBottom : highFlyerBottom,
      );
    }
    final (width, height) = blockSizes[_random.nextInt(blockSizes.length)];
    return DashObstacle(type: DashObstacleType.block, x: x, width: width, height: height);
  }

  @visibleForTesting
  void addObstacle(DashObstacle obstacle) => _obstacles.add(obstacle);

  void resetGame() {
    restartSession();
    _obstacles.clear();
    _distance = 0;
    _speed = initialSpeed;
    _runnerY = 0;
    _velocityY = 0;
    _duckTime = 0;
    _nextObstacleIn = firstObstacleDistance;
    notifyListeners();
  }
}
