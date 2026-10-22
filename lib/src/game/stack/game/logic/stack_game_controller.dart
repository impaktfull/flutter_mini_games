import 'dart:math';

import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/controller/realtime_game_controller.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';
import 'package:flutter_mini_games/src/game/stack/game/model/stack_block.dart';

/// Stack: drop sliding blocks on top of each other to build a tower as high as possible.
///
/// The world is 1 wide and [viewHeight] high; levels are [blockHeight] high and counted from the ground.
class StackGameController extends GameController with RealtimeGameController {
  static const id = 'stack';

  /// Width / height of the playing field
  static const aspectRatio = 3 / 4;

  /// Visible height of the world (the world is 1 wide)
  static const viewHeight = 1 / aspectRatio;

  /// Height of one block in world units
  static const blockHeight = 0.08;

  /// Width of the base block and of the first moving block
  static const baseWidth = 0.6;

  /// Speed of the first moving block in world widths per second
  static const startSpeed = 0.45;

  /// Speed added for every placed block
  static const speedIncrement = 0.025;

  static const maxSpeed = 1.4;

  /// A drop closer than this to the block below snaps to it: a perfect drop
  static const perfectTolerance = 0.015;

  /// Highest bonus for a streak of perfect drops
  static const maxPerfectBonus = 5;

  /// Where the moving block is kept in view, as a fraction of [viewHeight] from the bottom
  static const cameraAnchor = 0.7;

  /// How fast the view follows the tower, higher is faster
  static const cameraFollowRate = 6.0;

  /// Visible ground below the base block at the start
  static const groundHeight = 0.12;

  /// Acceleration of cut off pieces in world units per second squared
  static const gravity = 3.0;

  final Random _random;

  final List<StackBlock> _tower = [];
  final List<StackFallingPiece> _fallingPieces = [];
  late StackBlock _current;
  double _direction = 1;
  double _speed = startSpeed;
  double _cameraY = -groundHeight;
  int _score = 0;
  int _streak = 0;
  int _perfects = 0;
  bool _isGameOver = false;
  bool _lastDropWasPerfect = false;

  StackGameController({Random? random}) : _random = random ?? Random(), super(gameId: id) {
    _setup();
  }

  /// Placed blocks, the base first
  List<StackBlock> get tower => List.unmodifiable(_tower);

  /// The block that slides above the tower
  StackBlock get current => _current;

  /// Pieces that were cut off and are falling down
  List<StackFallingPiece> get fallingPieces => List.unmodifiable(_fallingPieces);

  /// 1 when the block moves right, -1 when it moves left
  double get direction => _direction;

  /// Current speed of the moving block in world widths per second
  double get speed => _speed;

  /// Bottom of the visible part of the world
  double get cameraY => _cameraY;

  /// Blocks placed on the base
  int get placedBlocks => _tower.length - 1;
  int get score => _score;

  /// Consecutive perfect drops
  int get streak => _streak;

  /// Perfect drops in this game
  int get perfects => _perfects;
  bool get isGameOver => _isGameOver;
  bool get lastDropWasPerfect => _lastDropWasPerfect;

  bool get isReady => status == GameStatus.ready;

  @override
  bool get isRunning => status == GameStatus.playing && !_isGameOver;

  void _setup() {
    _tower
      ..clear()
      ..add(const StackBlock(level: 0, left: (1 - baseWidth) / 2, width: baseWidth));
    _fallingPieces.clear();
    _speed = startSpeed;
    _cameraY = -groundHeight;
    _score = 0;
    _streak = 0;
    _perfects = 0;
    _isGameOver = false;
    _lastDropWasPerfect = false;
    _spawn(fromLeft: _random.nextBool());
  }

  /// Puts a new block with the width of the top of the tower on one side of the world
  void _spawn({required bool fromLeft}) {
    final top = _tower.last;
    _current = StackBlock(level: top.level + 1, left: fromLeft ? 0 : 1 - top.width, width: top.width);
    _direction = fromLeft ? 1 : -1;
  }

  /// Tap on the playing field: starts the game or drops the block
  void onTap() {
    if (_isGameOver) return;
    if (isReady) {
      start();
    } else {
      drop();
    }
  }

  /// Starts the game, the block starts sliding
  void start() {
    if (!isReady) return;
    startSession();
    notifyListeners();
  }

  /// Drops the moving block on the tower
  void drop() {
    if (!isRunning) return;
    registerMove();
    final below = _tower.last;
    final current = _current;
    final overlapLeft = max(current.left, below.left);
    final overlapRight = min(current.right, below.right);
    final overlap = overlapRight - overlapLeft;

    if (overlap <= 0) {
      _isGameOver = true;
      _streak = 0;
      _lastDropWasPerfect = false;
      _fallingPieces.add(StackFallingPiece(block: current));
      finish(
        GameOutcome.lost,
        score: _score,
        data: {'blocks': placedBlocks, 'perfects': _perfects},
      );
      notifyListeners();
      return;
    }

    if ((current.left - below.left).abs() <= perfectTolerance) {
      _streak++;
      _perfects++;
      _lastDropWasPerfect = true;
      _tower.add(current.copyWith(left: below.left, width: below.width));
      _score += 1 + min(_streak, maxPerfectBonus);
    } else {
      _streak = 0;
      _lastDropWasPerfect = false;
      _tower.add(current.copyWith(left: overlapLeft, width: overlap));
      final cutLeft = current.left < overlapLeft ? current.left : overlapRight;
      _fallingPieces.add(
        StackFallingPiece(
          block: current.copyWith(left: cutLeft, width: current.width - overlap),
        ),
      );
      _score += 1;
    }

    _speed = min(maxSpeed, _speed + speedIncrement);
    _spawn(fromLeft: _direction < 0);
    notifyListeners();
  }

  /// Bottom of the view that keeps the moving block at [cameraAnchor]
  double get targetCameraY => max(-groundHeight, (_current.level + 1) * blockHeight - viewHeight * cameraAnchor);

  @override
  void tick(Duration delta) {
    if (!isRunning) return;
    final seconds = delta.inMicroseconds / Duration.microsecondsPerSecond;
    _moveCurrent(seconds);
    _moveFallingPieces(seconds);
    _cameraY += (targetCameraY - _cameraY) * (1 - exp(-cameraFollowRate * seconds));
    notifyListeners();
  }

  /// Slides the block and bounces it off the edges of the world
  void _moveCurrent(double seconds) {
    final maxLeft = 1 - _current.width;
    var left = _current.left + _direction * _speed * seconds;
    if (left > maxLeft) {
      left = max(0, 2 * maxLeft - left);
      _direction = -1;
    } else if (left < 0) {
      left = min(maxLeft, -left);
      _direction = 1;
    }
    _current = _current.copyWith(left: left);
  }

  void _moveFallingPieces(double seconds) {
    for (var i = _fallingPieces.length - 1; i >= 0; i--) {
      final piece = _fallingPieces[i];
      final velocity = piece.velocity + gravity * seconds;
      final drop = piece.drop + velocity * seconds;
      final bottom = piece.block.level * blockHeight - drop;
      if (bottom + blockHeight < _cameraY - viewHeight) {
        _fallingPieces.removeAt(i);
      } else {
        _fallingPieces[i] = StackFallingPiece(block: piece.block, drop: drop, velocity: velocity);
      }
    }
  }

  /// Starts a new game
  void resetGame() {
    restartSession();
    _setup();
    notifyListeners();
  }
}
