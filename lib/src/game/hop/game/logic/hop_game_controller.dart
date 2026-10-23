import 'dart:collection';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/controller/realtime_game_controller.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';
import 'package:flutter_mini_games/src/game/hop/game/model/hop_platform.dart';
import 'package:flutter_mini_games/src/game/hop/game/model/hop_platform_generator.dart';
import 'package:flutter_mini_games/src/game/hop/game/model/hop_steer.dart';

/// Endless vertical jumper.
///
/// World units: the world is [worldWidth] wide, y grows upwards and the visible part is
/// [viewHeight] high, starting at [cameraY]. The character position is the center of its feet.
class HopGameController extends GameController with RealtimeGameController {
  static const id = 'hop';

  static const worldWidth = HopPlatformGenerator.worldWidth;

  /// Visible height of the world (3:4 board)
  static const viewHeight = 4 / 3;

  /// Downward acceleration in world units per second²
  static const gravity = 3.2;

  /// Upward speed after a bounce in world units per second
  static const jumpVelocity = 2.3;

  /// Highest a single bounce can reach
  static const maxJumpHeight = jumpVelocity * jumpVelocity / (2 * gravity);

  /// Highest gap between reachable platforms, safely below [maxJumpHeight]
  static const maxPlatformGap = maxJumpHeight * 0.75;

  /// Horizontal speed while steering in world units per second
  static const moveSpeed = 1.0;

  /// Half the width of the character, used for landing on platforms
  static const characterRadius = 0.05;

  /// Height of the character
  static const characterHeight = 0.1;

  /// Falling speed of a broken platform in world units per second
  static const brokenPlatformSpeed = 1.5;

  /// The camera keeps the character at or below this part of the view
  static const cameraAnchor = 0.45;

  /// Score per world unit of height
  static const scorePerUnit = 100;

  static const _startY = 0.1;

  final Random _random;
  late HopPlatformGenerator _generator;
  final List<HopPlatform> _platforms = [];
  double _x = worldWidth / 2;
  double _y = _startY;
  double _velocityY = 0;
  double _cameraY = 0;
  double _maxHeight = 0;
  HopSteer _steer = HopSteer.none;
  HopSteer _facing = HopSteer.right;
  bool _isGameOver = false;

  HopGameController({Random? random}) : _random = random ?? Random(), super(gameId: id) {
    _setUp();
  }

  @override
  bool get isRunning => status == GameStatus.playing && !_isGameOver;

  bool get isReady => status == GameStatus.ready;

  bool get isGameOver => _isGameOver;

  /// Horizontal center of the character
  double get characterX => _x;

  /// Bottom of the character
  double get characterY => _y;

  double get velocityY => _velocityY;

  /// Bottom of the visible part of the world, only moves up
  double get cameraY => _cameraY;

  List<HopPlatform> get platforms => UnmodifiableListView(_platforms);

  HopSteer get steer => _steer;

  /// Direction the character looks at, the last steering direction
  HopSteer get facing => _facing;

  /// Highest height reached in world units
  double get maxHeight => _maxHeight;

  int get score => (_maxHeight * scorePerUnit).floor();

  void _setUp() {
    _platforms
      ..clear()
      ..add(HopPlatform(x: worldWidth / 2, y: _startY, width: 0.3));
    _generator = HopPlatformGenerator(random: _random, maxGap: maxPlatformGap, startY: _startY);
    _x = worldWidth / 2;
    _y = _startY;
    _velocityY = 0;
    _cameraY = 0;
    _maxHeight = 0;
    _steer = HopSteer.none;
    _facing = HopSteer.right;
    _isGameOver = false;
    _generatePlatforms();
  }

  /// Starts the game without steering (e.g. a tap or the space bar), does not count a move
  void start() {
    if (!isReady) return;
    startSession();
    _velocityY = jumpVelocity;
    notifyListeners();
  }

  /// Steers left or right while held, [HopSteer.none] when released.
  /// Every new steering direction counts as a move, the first one also starts the game.
  void steerTo(HopSteer steer) {
    if (_isGameOver || isFinished || steer == _steer) return;
    _steer = steer;
    if (steer != HopSteer.none) {
      _facing = steer;
      if (isReady) start();
      registerMove();
    }
    notifyListeners();
  }

  @override
  void tick(Duration delta) {
    if (!isRunning) return;
    final seconds = delta.inMicroseconds / Duration.microsecondsPerSecond;

    _movePlatforms(seconds);

    // Horizontal movement with screen wrap
    _x = (_x + _steer.sign * moveSpeed * seconds) % worldWidth;

    // Vertical movement
    final previousY = _y;
    // Exact for constant gravity, so the jump height does not depend on the frame rate
    _y += _velocityY * seconds - gravity * seconds * seconds / 2;
    _velocityY -= gravity * seconds;
    if (_velocityY <= 0) _land(previousY);

    _maxHeight = max(_maxHeight, _y - _startY);
    _cameraY = max(_cameraY, _y - viewHeight * cameraAnchor);
    _generatePlatforms();
    _platforms.removeWhere((platform) => platform.y < _cameraY - 0.2);

    if (_y + characterHeight < _cameraY) {
      _isGameOver = true;
      _steer = HopSteer.none;
      finish(GameOutcome.lost, score: score);
      notifyListeners();
    } else {
      // Only the board and the live score change
      notifyFrame();
    }
  }

  void _movePlatforms(double seconds) {
    for (final platform in _platforms) {
      if (platform.isBroken) {
        platform.y -= brokenPlatformSpeed * seconds;
        continue;
      }
      if (platform.velocityX == 0) continue;
      platform.x += platform.velocityX * seconds;
      final minX = platform.width / 2;
      final maxX = worldWidth - platform.width / 2;
      if (platform.x < minX) {
        platform.x = minX + (minX - platform.x);
        platform.velocityX = platform.velocityX.abs();
      } else if (platform.x > maxX) {
        platform.x = maxX - (platform.x - maxX);
        platform.velocityX = -platform.velocityX.abs();
      }
    }
  }

  /// Lands on the highest platform that was crossed while falling
  void _land(double previousY) {
    HopPlatform? landed;
    for (final platform in _platforms) {
      if (!platform.isSolid) continue;
      if (previousY < platform.y || _y > platform.y) continue;
      if (!_overlaps(platform)) continue;
      if (landed == null || platform.y > landed.y) landed = platform;
    }
    if (landed == null) return;
    if (landed.type == HopPlatformType.breakable) {
      landed.isBroken = true;
      return;
    }
    _y = landed.y;
    _velocityY = jumpVelocity;
  }

  /// Horizontal overlap between the character and [platform], taking the screen wrap into account
  bool _overlaps(HopPlatform platform) {
    var dx = (_x - platform.x).abs() % worldWidth;
    dx = min(dx, worldWidth - dx);
    return dx <= platform.width / 2 + characterRadius;
  }

  void _generatePlatforms() {
    _platforms.addAll(_generator.generateUntil(_cameraY + viewHeight + maxPlatformGap));
  }

  void resetGame() {
    restartSession();
    _setUp();
    notifyListeners();
  }

  /// Places the character, for tests
  @visibleForTesting
  void debugPlaceCharacter({double? x, double? y, double? velocityY}) {
    _x = x ?? _x;
    _y = y ?? _y;
    _velocityY = velocityY ?? _velocityY;
  }

  /// Replaces the platforms, for tests
  @visibleForTesting
  void debugSetPlatforms(List<HopPlatform> platforms) {
    _platforms
      ..clear()
      ..addAll(platforms);
  }
}
