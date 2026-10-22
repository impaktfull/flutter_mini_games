import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/controller/realtime_game_controller.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';
import 'package:flutter_mini_games/src/game/breaker/game/model/breaker_brick.dart';
import 'package:flutter_mini_games/src/game/breaker/game/model/breaker_phase.dart';
import 'package:flutter_mini_games/src/game/breaker/game/model/breaker_steer.dart';

/// Brick breaker: bounce the ball off the paddle to break all the bricks.
///
/// World units: the world is [worldWidth] wide and [worldHeight] high, (0, 0) is the top left
/// corner and y grows downwards. The ball moves in a unit direction times [ballSpeed] and is
/// moved in sub-steps of at most [maxStep], so it never tunnels through a brick or the paddle.
class BreakerGameController extends GameController with RealtimeGameController {
  static const id = 'breaker';

  static const worldWidth = 1.0;
  static const worldHeight = 1.4;

  static const columns = 8;

  /// Rows of the first level, every next level adds one row
  static const firstLevelRows = 4;

  /// Clearing this level wins the game
  static const maxLevel = 5;

  static const maxRows = firstLevelRows + maxLevel - 1;

  static const bricksTop = 0.14;
  static const bricksSideMargin = 0.03;
  static const brickHeight = 0.05;
  static const brickGap = 0.012;
  static const brickWidth = (worldWidth - 2 * bricksSideMargin - (columns - 1) * brickGap) / columns;

  static const paddleWidth = 0.2;
  static const paddleHeight = 0.028;

  /// Top of the paddle
  static const paddleTop = 1.28;

  /// Paddle speed while steering with the keys or a held half, in world units per second
  static const paddleSpeed = 1.5;

  static const ballRadius = 0.018;

  /// Longest distance the ball moves before collisions are checked
  static const maxStep = ballRadius / 2;

  /// Ball speed at the launch of the first level in world units per second
  static const launchSpeed = 0.75;

  /// Extra launch speed per level
  static const levelSpeedIncrement = 0.07;

  /// The ball speeds up by this many world units per second, every second
  static const speedUp = 0.012;

  static const maxSpeed = 1.6;

  /// Largest angle from vertical after hitting the edge of the paddle
  static const maxBounceAngle = pi / 3;

  /// The ball never moves flatter than this angle from horizontal, so it can't bounce sideways forever
  static const minVerticalAngle = pi / 12;

  /// The launch goes up with an angle from vertical between these two (random side)
  static const minLaunchAngle = pi / 18;
  static const maxLaunchAngle = pi / 6;

  static const startLives = 3;
  static const pointsPerBrick = 10;

  final Random _random;
  final List<BreakerBrick> _bricks = [];
  BreakerPhase _phase = BreakerPhase.ready;
  int _level = 1;
  int _lives = startLives;
  int _bricksBroken = 0;
  double _paddleX = worldWidth / 2;
  double _ballX = worldWidth / 2;
  double _ballY = paddleTop - ballRadius;
  double _directionX = 0;
  double _directionY = -1;
  double _ballSpeed = launchSpeed;
  BreakerSteer _steer = BreakerSteer.none;
  bool _isDragging = false;

  BreakerGameController({Random? random}) : _random = random ?? Random(), super(gameId: id) {
    _setUp();
  }

  /// Ticks while the ball moves, and while the paddle is steered before a launch
  @override
  bool get isRunning {
    if (isFinished) return false;
    if (_phase == BreakerPhase.playing) return true;
    return _phase.isWaitingForLaunch && _steer != BreakerSteer.none && !_isDragging;
  }

  bool get isReady => status == GameStatus.ready;

  BreakerPhase get phase => _phase;

  bool get isGameOver => _phase == BreakerPhase.gameOver;

  bool get isWon => _phase == BreakerPhase.won;

  int get level => _level;

  int get lives => _lives;

  int get bricksBroken => _bricksBroken;

  int get score => _bricksBroken * pointsPerBrick;

  List<BreakerBrick> get bricks => List.unmodifiable(_bricks);

  /// Number of brick rows of the current level
  int get rows => rowsForLevel(_level);

  /// Horizontal center of the paddle
  double get paddleX => _paddleX;

  double get ballX => _ballX;

  double get ballY => _ballY;

  /// Unit vector of the ball direction
  double get directionX => _directionX;

  double get directionY => _directionY;

  double get ballSpeed => _ballSpeed;

  BreakerSteer get steer => _steer;

  bool get isDragging => _isDragging;

  static int rowsForLevel(int level) => firstLevelRows + level - 1;

  static double launchSpeedForLevel(int level) => launchSpeed + levelSpeedIncrement * (level - 1);

  void _setUp() {
    _phase = BreakerPhase.ready;
    _level = 1;
    _lives = startLives;
    _bricksBroken = 0;
    _paddleX = worldWidth / 2;
    _steer = BreakerSteer.none;
    _isDragging = false;
    _buildBricks();
    _placeBallOnPaddle();
  }

  void _buildBricks() {
    _bricks.clear();
    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        _bricks.add(
          BreakerBrick(
            row: row,
            column: column,
            left: bricksSideMargin + column * (brickWidth + brickGap),
            top: bricksTop + row * (brickHeight + brickGap),
            width: brickWidth,
            height: brickHeight,
          ),
        );
      }
    }
  }

  void _placeBallOnPaddle() {
    _ballX = _paddleX;
    _ballY = paddleTop - ballRadius;
    _directionX = 0;
    _directionY = -1;
    _ballSpeed = launchSpeedForLevel(_level);
  }

  /// Launches the ball from the paddle (tap, space or enter). Every launch is a move.
  void launch() {
    if (isFinished || !_phase.isWaitingForLaunch) return;
    registerMove();
    final angle = minLaunchAngle + _random.nextDouble() * (maxLaunchAngle - minLaunchAngle);
    final side = _random.nextBool() ? 1 : -1;
    _directionX = side * sin(angle);
    _directionY = -cos(angle);
    _ballSpeed = launchSpeedForLevel(_level);
    _phase = BreakerPhase.playing;
    notifyListeners();
  }

  /// Steers the paddle while held, [BreakerSteer.none] when released. Ignored while dragging.
  void steerTo(BreakerSteer steer) {
    if (steer == _steer) return;
    _steer = steer;
    notifyListeners();
  }

  /// A finger starts dragging the paddle: holds are ignored until [endDrag]
  void beginDrag() {
    if (_isDragging) return;
    _isDragging = true;
    notifyListeners();
  }

  /// Moves the paddle by [dx] world units, the ball follows while it rests on the paddle
  void dragPaddleBy(double dx) {
    if (isFinished) return;
    _movePaddleTo(_paddleX + dx);
    notifyListeners();
  }

  void endDrag() {
    if (!_isDragging) return;
    _isDragging = false;
    notifyListeners();
  }

  void _movePaddleTo(double x) {
    _paddleX = x.clamp(paddleWidth / 2, worldWidth - paddleWidth / 2);
    if (_phase.isWaitingForLaunch) _ballX = _paddleX;
  }

  @override
  void tick(Duration delta) {
    if (!isRunning) return;
    final seconds = delta.inMicroseconds / Duration.microsecondsPerSecond;

    if (!_isDragging && _steer != BreakerSteer.none) {
      _movePaddleTo(_paddleX + _steer.sign * paddleSpeed * seconds);
    }

    if (_phase == BreakerPhase.playing) _moveBall(seconds);
    notifyListeners();
  }

  void _moveBall(double seconds) {
    if (_ballSpeed < maxSpeed) _ballSpeed = min(maxSpeed, _ballSpeed + speedUp * seconds);
    final distance = _ballSpeed * seconds;
    final steps = max(1, (distance / maxStep).ceil());
    final step = distance / steps;
    for (var i = 0; i < steps; i++) {
      final previousY = _ballY;
      _ballX += _directionX * step;
      _ballY += _directionY * step;
      _collideWalls();
      _collidePaddle(previousY);
      _collideBricks();
      if (_bricks.isEmpty) {
        _clearLevel();
        return;
      }
      if (_ballY - ballRadius > worldHeight) {
        _loseLife();
        return;
      }
    }
  }

  void _collideWalls() {
    if (_ballX < ballRadius) {
      _ballX = ballRadius;
      _directionX = _directionX.abs();
      _keepVertical();
    } else if (_ballX > worldWidth - ballRadius) {
      _ballX = worldWidth - ballRadius;
      _directionX = -_directionX.abs();
      _keepVertical();
    }
    if (_ballY < ballRadius) {
      _ballY = ballRadius;
      _directionY = _directionY.abs();
    }
  }

  /// Bounces up when the ball crossed the top of the paddle while moving down.
  /// The further from the center it hits, the larger the angle (up to [maxBounceAngle]).
  void _collidePaddle(double previousY) {
    if (_directionY <= 0) return;
    if (previousY + ballRadius > paddleTop || _ballY + ballRadius < paddleTop) return;
    if ((_ballX - _paddleX).abs() > paddleWidth / 2 + ballRadius) return;
    final offset = ((_ballX - _paddleX) / (paddleWidth / 2)).clamp(-1.0, 1.0);
    final angle = offset * maxBounceAngle;
    _directionX = sin(angle);
    _directionY = -cos(angle);
    _ballY = paddleTop - ballRadius;
  }

  /// Breaks the brick closest to the ball that it touches and reflects the ball off it
  void _collideBricks() {
    BreakerBrick? hit;
    var hitDistance = double.infinity;
    var closestX = 0.0;
    var closestY = 0.0;
    for (final brick in _bricks) {
      final x = _ballX.clamp(brick.left, brick.right);
      final y = _ballY.clamp(brick.top, brick.bottom);
      final distance = (_ballX - x) * (_ballX - x) + (_ballY - y) * (_ballY - y);
      if (distance >= ballRadius * ballRadius || distance >= hitDistance) continue;
      hit = brick;
      hitDistance = distance;
      closestX = x;
      closestY = y;
    }
    if (hit == null) return;

    _bricks.remove(hit);
    _bricksBroken++;

    final dx = _ballX - closestX;
    final dy = _ballY - closestY;
    final length = sqrt(dx * dx + dy * dy);
    if (length == 0) {
      // The center ended exactly on the brick edge: reverse
      _directionY = -_directionY;
      _directionX = -_directionX;
      return;
    }
    final normalX = dx / length;
    final normalY = dy / length;
    final dot = _directionX * normalX + _directionY * normalY;
    if (dot < 0) {
      _directionX -= 2 * dot * normalX;
      _directionY -= 2 * dot * normalY;
    }
    // Push the ball out of the brick
    _ballX = closestX + normalX * ballRadius;
    _ballY = closestY + normalY * ballRadius;
    _keepVertical();
  }

  /// Keeps the direction a unit vector that is at least [minVerticalAngle] from horizontal
  void _keepVertical() {
    final minY = sin(minVerticalAngle);
    if (_directionY.abs() < minY) {
      final signY = _directionY < 0 ? -1.0 : 1.0;
      _directionY = signY * minY;
      _directionX = (_directionX < 0 ? -1.0 : 1.0) * cos(minVerticalAngle);
    }
    final length = sqrt(_directionX * _directionX + _directionY * _directionY);
    _directionX /= length;
    _directionY /= length;
  }

  void _loseLife() {
    _lives--;
    if (_lives <= 0) {
      _lives = 0;
      _phase = BreakerPhase.gameOver;
      _steer = BreakerSteer.none;
      finish(GameOutcome.lost, score: score, data: _resultData());
      return;
    }
    _phase = BreakerPhase.serving;
    _placeBallOnPaddle();
  }

  void _clearLevel() {
    if (_level >= maxLevel) {
      _phase = BreakerPhase.won;
      _steer = BreakerSteer.none;
      finish(GameOutcome.won, score: score, data: _resultData());
      return;
    }
    _level++;
    _phase = BreakerPhase.levelCleared;
    _buildBricks();
    _placeBallOnPaddle();
  }

  Map<String, Object?> _resultData() => {
    'level': _level,
    'bricks': _bricksBroken,
    'lives': _lives,
  };

  void resetGame() {
    restartSession();
    _setUp();
    notifyListeners();
  }

  /// Places the ball and sets its direction (normalized) and speed, for tests
  @visibleForTesting
  void debugPlaceBall({double? x, double? y, double? directionX, double? directionY, double? speed}) {
    _ballX = x ?? _ballX;
    _ballY = y ?? _ballY;
    final dx = directionX ?? _directionX;
    final dy = directionY ?? _directionY;
    final length = sqrt(dx * dx + dy * dy);
    _directionX = dx / length;
    _directionY = dy / length;
    _ballSpeed = speed ?? _ballSpeed;
  }

  /// Places the paddle, for tests
  @visibleForTesting
  void debugPlacePaddle(double x) => _movePaddleTo(x);

  /// Replaces the bricks, for tests
  @visibleForTesting
  void debugSetBricks(List<BreakerBrick> bricks) {
    _bricks
      ..clear()
      ..addAll(bricks);
  }
}
