import 'dart:math';

import 'package:flutter_mini_games/flutter_mini_games.dart';
import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/widget/game_loop.dart';
import 'package:flutter_mini_games/src/game/breaker/game/logic/breaker_game_controller.dart';
import 'package:flutter_mini_games/src/game/breaker/game/model/breaker_brick.dart';
import 'package:flutter_mini_games/src/game/breaker/game/model/breaker_phase.dart';
import 'package:flutter_mini_games/src/game/breaker/game/model/breaker_steer.dart';
import 'package:flutter_test/flutter_test.dart';

typedef _C = BreakerGameController;

const _frame = Duration(milliseconds: 16);

const _brick = BreakerBrick(row: 0, column: 0, left: 0.4, top: 0.3, width: 0.2, height: 0.05);

/// A second brick that is out of the way, so breaking [_brick] does not clear the level
const _otherBrick = BreakerBrick(row: 1, column: 0, left: 0.1, top: 0.6, width: 0.1, height: 0.05);

BreakerGameController _launched({int seed = 1}) => BreakerGameController(random: Random(seed))..launch();

/// Breaks the only brick left on the board with a ball coming from below
void _breakLastBrick(BreakerGameController controller) {
  controller
    ..debugSetBricks([_brick])
    ..debugPlaceBall(x: 0.5, y: _brick.bottom + _C.ballRadius + 0.005, directionX: 0, directionY: -1, speed: 1)
    ..tick(_frame);
}

/// Lets the ball fall past the paddle
void _loseBall(BreakerGameController controller) {
  controller
    ..debugPlacePaddle(0.9)
    ..debugPlaceBall(x: 0.1, y: _C.paddleTop + 0.05, directionX: 0, directionY: 1, speed: 1);
  for (var i = 0; i < 20 && controller.phase == BreakerPhase.playing; i++) {
    controller.tick(_frame);
  }
}

void main() {
  group('start', () {
    test('starts with 4 rows of bricks, 3 lives and the ball on the paddle', () {
      final controller = BreakerGameController(random: Random(1));
      expect(controller.phase, equals(BreakerPhase.ready));
      expect(controller.status, equals(GameStatus.ready));
      expect(controller.rows, equals(4));
      expect(controller.bricks, hasLength(4 * _C.columns));
      expect(controller.lives, equals(3));
      expect(controller.level, equals(1));
      expect(controller.score, equals(0));
      expect(controller.ballX, equals(controller.paddleX));
      expect(controller.ballY, equals(_C.paddleTop - _C.ballRadius));
      expect(controller.isRunning, isFalse);
    });

    test('bricks fit inside the world and do not overlap', () {
      final controller = BreakerGameController();
      for (final brick in controller.bricks) {
        expect(brick.left, greaterThanOrEqualTo(0));
        expect(brick.right, lessThanOrEqualTo(_C.worldWidth + 1e-9));
        expect(brick.bottom, lessThan(_C.paddleTop));
      }
      final sorted = controller.bricks.where((brick) => brick.row == 0).toList()..sort((a, b) => a.left.compareTo(b.left));
      for (var i = 1; i < sorted.length; i++) {
        expect(sorted[i].left, greaterThan(sorted[i - 1].right));
      }
    });

    test('launch starts the session, counts a move and sends the ball up at a random angle', () {
      final controller = _launched();
      expect(controller.phase, equals(BreakerPhase.playing));
      expect(controller.status, equals(GameStatus.playing));
      expect(controller.moves, equals(1));
      expect(controller.isRunning, isTrue);
      expect(controller.directionY, lessThan(0));
      final angle = atan2(controller.directionX.abs(), -controller.directionY);
      expect(angle, inInclusiveRange(_C.minLaunchAngle - 1e-9, _C.maxLaunchAngle + 1e-9));
      expect(controller.ballSpeed, equals(_C.launchSpeed));

      // Seeded: the same seed launches in the same direction
      final other = _launched();
      expect(other.directionX, equals(controller.directionX));
    });

    test('launch is ignored while the ball moves', () {
      final controller = _launched()..launch();
      expect(controller.moves, equals(1));
    });
  });

  group('paddle', () {
    test('holding a direction moves the paddle and the resting ball, frame-rate independent', () {
      final controller = BreakerGameController()..steerTo(BreakerSteer.left);
      expect(controller.isRunning, isTrue);
      controller.tick(const Duration(milliseconds: 100));
      expect(controller.paddleX, closeTo(0.5 - _C.paddleSpeed * 0.1, 1e-9));
      expect(controller.ballX, equals(controller.paddleX));

      final other = BreakerGameController()..steerTo(BreakerSteer.left);
      for (var i = 0; i < 10; i++) {
        other.tick(const Duration(milliseconds: 10));
      }
      expect(other.paddleX, closeTo(controller.paddleX, 1e-9));

      controller.steerTo(BreakerSteer.none);
      expect(controller.isRunning, isFalse);
      // Moving before the launch does not start the session
      expect(controller.status, equals(GameStatus.ready));
    });

    test('the paddle stays inside the world', () {
      final controller = BreakerGameController()..steerTo(BreakerSteer.right);
      for (var i = 0; i < 100; i++) {
        controller.tick(_frame);
      }
      expect(controller.paddleX, equals(_C.worldWidth - _C.paddleWidth / 2));
      controller.dragPaddleBy(-5);
      expect(controller.paddleX, equals(_C.paddleWidth / 2));
    });

    test('dragging moves the paddle and holds are ignored meanwhile', () {
      final controller = BreakerGameController()
        ..steerTo(BreakerSteer.left)
        ..beginDrag();
      expect(controller.isRunning, isFalse);
      controller.dragPaddleBy(0.2);
      expect(controller.paddleX, closeTo(0.7, 1e-9));
      expect(controller.ballX, closeTo(0.7, 1e-9));

      controller
        ..launch()
        ..tick(_frame);
      expect(controller.paddleX, closeTo(0.7, 1e-9));

      controller
        ..endDrag()
        ..tick(_frame);
      expect(controller.paddleX, lessThan(0.7));
    });
  });

  group('collisions', () {
    test('bounces off the left, right and top walls', () {
      final controller = _launched()..debugSetBricks([_otherBrick]);
      controller
        ..debugPlaceBall(x: 0.02, y: 0.8, directionX: -1, directionY: -1)
        ..tick(_frame);
      expect(controller.directionX, greaterThan(0));
      expect(controller.ballX, greaterThanOrEqualTo(_C.ballRadius));

      controller
        ..debugPlaceBall(x: 0.98, y: 0.8, directionX: 1, directionY: -1)
        ..tick(_frame);
      expect(controller.directionX, lessThan(0));
      expect(controller.ballX, lessThanOrEqualTo(_C.worldWidth - _C.ballRadius));

      controller
        ..debugPlaceBall(x: 0.5, y: 0.02, directionX: 0.3, directionY: -1)
        ..tick(_frame);
      expect(controller.directionY, greaterThan(0));
      expect(controller.ballY, greaterThanOrEqualTo(_C.ballRadius));
    });

    test('never moves flatter than the minimum angle after a wall', () {
      final controller = _launched()..debugSetBricks([_otherBrick]);
      controller
        ..debugPlaceBall(x: 0.02, y: 0.8, directionX: -1, directionY: -0.01)
        ..tick(_frame);
      expect(controller.directionY.abs(), greaterThanOrEqualTo(sin(_C.minVerticalAngle) - 1e-9));
      expect(controller.directionX * controller.directionX + controller.directionY * controller.directionY, closeTo(1, 1e-9));
    });

    test('the bounce angle depends on where the ball hits the paddle', () {
      double bounceAt(double offset) {
        final controller = _launched()
          ..debugSetBricks([_brick])
          ..debugPlacePaddle(0.5)
          ..debugPlaceBall(x: 0.5 + offset, y: _C.paddleTop - _C.ballRadius - 0.005, directionX: 0, directionY: 1)
          ..tick(_frame);
        expect(controller.directionY, lessThan(0), reason: 'bounces up at offset $offset');
        return atan2(controller.directionX, -controller.directionY);
      }

      expect(bounceAt(0), closeTo(0, 1e-9));
      expect(bounceAt(_C.paddleWidth / 4), closeTo(_C.maxBounceAngle / 2, 1e-9));
      expect(bounceAt(-_C.paddleWidth / 4), closeTo(-_C.maxBounceAngle / 2, 1e-9));
      expect(bounceAt(_C.paddleWidth / 2), closeTo(_C.maxBounceAngle, 1e-9));
      // The edge of the ball still touches the paddle, the angle is capped
      expect(bounceAt(_C.paddleWidth / 2 + _C.ballRadius * 0.9), closeTo(_C.maxBounceAngle, 1e-9));
    });

    test('a ball beside the paddle falls through', () {
      final controller = _launched()
        ..debugPlacePaddle(0.5)
        ..debugPlaceBall(x: 0.5 + _C.paddleWidth / 2 + _C.ballRadius * 1.5, y: _C.paddleTop - _C.ballRadius - 0.005, directionX: 0, directionY: 1)
        ..tick(_frame);
      expect(controller.directionY, greaterThan(0));
    });

    test('breaks a brick hit from below, scores 10 and bounces down', () {
      final controller = _launched()..debugSetBricks([_brick, _otherBrick]);
      controller
        ..debugPlaceBall(x: 0.5, y: _brick.bottom + _C.ballRadius + 0.005, directionX: 0, directionY: -1)
        ..tick(_frame);
      expect(controller.bricks, hasLength(1));
      expect(controller.bricksBroken, equals(1));
      expect(controller.score, equals(10));
      expect(controller.directionY, greaterThan(0));
      expect(controller.ballY, greaterThanOrEqualTo(_brick.bottom + _C.ballRadius - 1e-9));
    });

    test('a brick hit on its side reflects the ball horizontally', () {
      final controller = _launched()..debugSetBricks([_brick, _otherBrick]);
      controller
        ..debugPlaceBall(x: _brick.left - _C.ballRadius - 0.005, y: _brick.top + _brick.height / 2, directionX: 1, directionY: 0.3)
        ..tick(_frame);
      expect(controller.bricksBroken, equals(1));
      expect(controller.directionX, lessThan(0));
      expect(controller.directionY, greaterThan(0));
    });

    test('a fast ball does not tunnel through a brick', () {
      final controller = _launched()..debugSetBricks([_brick, _otherBrick]);
      // Moves 0.16 per frame: more than the brick and the ball together (0.086)
      controller
        ..debugPlaceBall(x: 0.5, y: _brick.bottom + 0.1, directionX: 0, directionY: -1, speed: 10)
        ..tick(_frame);
      expect(controller.bricksBroken, equals(1));
      expect(controller.directionY, greaterThan(0));
      expect(controller.ballY, greaterThan(_brick.bottom));
    });

    test('a very fast ball never ends inside a brick or a wall', () {
      final controller = _launched(seed: 7)..debugPlaceBall(speed: 6);
      var previousBricks = controller.bricks.length;
      for (var i = 0; i < 400 && controller.phase == BreakerPhase.playing; i++) {
        controller
          ..debugPlacePaddle(controller.ballX + 0.08 * sin(i))
          ..tick(GameLoop.maxDelta);
        if (controller.phase != BreakerPhase.playing) break;
        for (final brick in controller.bricks) {
          final inside = controller.ballX > brick.left && controller.ballX < brick.right && controller.ballY > brick.top && controller.ballY < brick.bottom;
          expect(inside, isFalse);
        }
        expect(controller.ballX, inInclusiveRange(_C.ballRadius, _C.worldWidth - _C.ballRadius));
        expect(controller.ballY, greaterThanOrEqualTo(_C.ballRadius));
        expect(controller.bricksBroken, equals(4 * _C.columns - controller.bricks.length));
        previousBricks = controller.bricks.length;
      }
      expect(previousBricks, lessThan(4 * _C.columns));
    });
  });

  group('speed', () {
    test('the ball speeds up slowly, up to the max speed', () {
      final controller = _launched()..debugSetBricks([_brick]);
      final start = controller.ballSpeed;
      controller
        ..debugPlaceBall(x: 0.5, y: 0.8, directionX: 1, directionY: 1)
        ..tick(const Duration(milliseconds: 50));
      expect(controller.ballSpeed, closeTo(start + _C.speedUp * 0.05, 1e-9));

      controller.debugPlaceBall(speed: _C.maxSpeed - 0.0001);
      controller.tick(const Duration(milliseconds: 50));
      expect(controller.ballSpeed, equals(_C.maxSpeed));
    });

    test('later levels launch faster', () {
      expect(_C.launchSpeedForLevel(2), greaterThan(_C.launchSpeedForLevel(1)));
    });
  });

  group('lives', () {
    test('losing the ball costs a life and puts the ball back on the paddle', () {
      final controller = _launched();
      _loseBall(controller);
      expect(controller.lives, equals(2));
      expect(controller.phase, equals(BreakerPhase.serving));
      expect(controller.status, equals(GameStatus.playing));
      expect(controller.ballX, equals(controller.paddleX));
      expect(controller.ballY, equals(_C.paddleTop - _C.ballRadius));
      expect(controller.isRunning, isFalse);

      controller.launch();
      expect(controller.phase, equals(BreakerPhase.playing));
      expect(controller.moves, equals(2));
    });

    test('losing the last life is game over with the score', () {
      final results = <GameResult>[];
      final controller = _launched()..resultListener = results.add;
      controller
        ..debugSetBricks([_brick, _otherBrick])
        ..debugPlaceBall(x: 0.5, y: _brick.bottom + _C.ballRadius + 0.005, directionX: 0, directionY: -1)
        ..tick(_frame);
      _loseBall(controller);
      expect(controller.lives, equals(2));
      for (var i = 0; i < 2; i++) {
        controller.launch();
        _loseBall(controller);
      }
      expect(controller.lives, equals(0));
      expect(controller.isGameOver, isTrue);
      expect(controller.isRunning, isFalse);
      expect(results, hasLength(1));
      expect(results.single.gameId, equals('breaker'));
      expect(results.single.outcome, equals(GameOutcome.lost));
      expect(results.single.score, equals(10));
      expect(results.single.data, equals({'level': 1, 'bricks': 1, 'lives': 0}));

      // Input is ignored after the game
      controller.launch();
      expect(controller.isGameOver, isTrue);
    });
  });

  group('levels', () {
    test('clearing all bricks goes to the next level with an extra row', () {
      final controller = _launched();
      _breakLastBrick(controller);
      expect(controller.level, equals(2));
      expect(controller.phase, equals(BreakerPhase.levelCleared));
      expect(controller.rows, equals(5));
      expect(controller.bricks, hasLength(5 * _C.columns));
      expect(controller.ballX, equals(controller.paddleX));
      expect(controller.lives, equals(3));
      expect(controller.isFinished, isFalse);

      controller.launch();
      expect(controller.phase, equals(BreakerPhase.playing));
      expect(controller.ballSpeed, equals(_C.launchSpeedForLevel(2)));
    });

    test('clearing the last level wins with the score', () {
      final results = <GameResult>[];
      final controller = _launched()..resultListener = results.add;
      for (var level = 1; level < _C.maxLevel; level++) {
        _breakLastBrick(controller);
        expect(controller.level, equals(level + 1));
        controller.launch();
      }
      expect(controller.rows, equals(_C.maxRows));
      _breakLastBrick(controller);
      expect(controller.isWon, isTrue);
      expect(controller.isFinished, isTrue);
      expect(results.single.outcome, equals(GameOutcome.won));
      expect(results.single.score, equals(_C.maxLevel * _C.pointsPerBrick));
      expect(results.single.data, equals({'level': _C.maxLevel, 'bricks': _C.maxLevel, 'lives': 3}));
    });
  });

  test('reset starts a new game', () {
    final controller = _launched();
    _breakLastBrick(controller);
    _loseBall(controller..launch());
    controller.resetGame();
    expect(controller.phase, equals(BreakerPhase.ready));
    expect(controller.status, equals(GameStatus.ready));
    expect(controller.level, equals(1));
    expect(controller.lives, equals(3));
    expect(controller.score, equals(0));
    expect(controller.moves, equals(0));
    expect(controller.bricks, hasLength(4 * _C.columns));
  });
}
