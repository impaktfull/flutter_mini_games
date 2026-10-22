import 'dart:math';

import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';
import 'package:flutter_mini_games/src/core/widget/input/game_input_detector.dart';
import 'package:flutter_mini_games/src/game/dash/game/logic/dash_game_controller.dart';
import 'package:flutter_mini_games/src/game/dash/game/model/dash_obstacle.dart';
import 'package:flutter_test/flutter_test.dart';

const _frame = Duration(microseconds: 16667);

/// Ticks [controller] for [seconds] at [fps], calling [beforeFrame] before every frame
void _run(DashGameController controller, double seconds, {int fps = 60, void Function()? beforeFrame}) {
  final frames = (seconds * fps).round();
  final delta = Duration(microseconds: (Duration.microsecondsPerSecond / fps).round());
  for (var i = 0; i < frames && !controller.isFinished; i++) {
    beforeFrame?.call();
    controller.tick(delta);
  }
}

/// Plays like a careful player: jumps so the apex is above the middle of the next block,
/// ducks under low flyers and stays on the ground for high flyers.
void _bot(DashGameController controller) {
  final runner = controller.runnerHitbox;
  final next = controller.obstacles.where((obstacle) => DashGameController.obstacleHitbox(obstacle).right > runner.left).toList();
  if (next.isEmpty) return;
  final obstacle = next.first;
  final hitbox = DashGameController.obstacleHitbox(obstacle);
  final speed = controller.speed;
  switch (obstacle.type) {
    case DashObstacleType.block:
      if (!controller.isOnGround) return;
      final enter = (hitbox.left - runner.right) / speed;
      final leave = (hitbox.right - runner.left) / speed;
      if ((enter + leave) / 2 <= DashGameController.jumpVelocity / DashGameController.gravity) controller.jump();
    case DashObstacleType.lowFlyer:
      final distance = hitbox.left - (DashGameController.runnerX + DashGameController.duckWidth);
      if (controller.isOnGround && !controller.isDucking && distance <= speed * 0.1) controller.duck();
    case DashObstacleType.highFlyer:
      break;
  }
}

/// Starts the game and waits until the runner landed
DashGameController _started({int seed = 42}) {
  final controller = DashGameController(random: Random(seed))..jump();
  _run(controller, DashGameController.airTime + 0.05);
  return controller;
}

void main() {
  group('DashGameController', () {
    test('starts ready and does not move before the first jump', () {
      final controller = DashGameController(random: Random(42));

      controller.tick(const Duration(seconds: 1));

      expect(controller.isReady, isTrue);
      expect(controller.isRunning, isFalse);
      expect(controller.distance, equals(0));
      expect(controller.score, equals(0));
    });

    test('the first jump starts the game and counts as a move', () {
      final controller = DashGameController(random: Random(42))..jump();

      expect(controller.status, equals(GameStatus.playing));
      expect(controller.isRunning, isTrue);
      expect(controller.moves, equals(1));
    });

    test('jump arc reaches the expected height and lands after the air time', () {
      final controller = DashGameController(random: Random(42))..jump();
      var apex = 0.0;
      var airFrames = 0;
      while (!controller.isOnGround) {
        controller.tick(_frame);
        apex = max(apex, controller.runnerY);
        airFrames++;
      }

      const expectedApex = DashGameController.jumpVelocity * DashGameController.jumpVelocity / (2 * DashGameController.gravity);
      expect(apex, closeTo(expectedApex, 0.02));
      expect(airFrames * _frame.inMicroseconds / 1e6, closeTo(DashGameController.airTime, 1 / 60));
      expect(controller.runnerY, equals(0));
    });

    test('the jump arc does not depend on the frame rate', () {
      double heightAfter(int fps) {
        final controller = DashGameController(random: Random(42))..jump();
        _run(controller, 0.2, fps: fps);
        return controller.runnerY;
      }

      expect(heightAfter(25), closeTo(heightAfter(100), 1e-9));
    });

    test('no double jump in the air', () {
      final single = DashGameController(random: Random(42))..jump();
      final second = DashGameController(random: Random(42))..jump();
      _run(single, 0.2);
      _run(second, 0.1);
      second.onSwipe(GameDirection.up);
      _run(second, 0.1);

      expect(second.moves, equals(1));
      expect(second.runnerY, closeTo(single.runnerY, 1e-9));
    });

    test('can jump again after landing', () {
      final controller = _started()..jump();

      expect(controller.moves, equals(2));
      expect(controller.isOnGround, isFalse);
    });

    test('swiping down in the air falls faster', () {
      final controller = DashGameController(random: Random(42))..jump();
      _run(controller, 0.3);
      controller.onSwipe(GameDirection.down);
      var seconds = 0.3;
      while (!controller.isOnGround) {
        controller.tick(_frame);
        seconds += _frame.inMicroseconds / 1e6;
      }

      expect(seconds, lessThan(DashGameController.airTime - 0.1));
    });

    test('ducking lowers the hitbox for a limited time', () {
      final controller = _started();
      final standing = controller.runnerHitbox;

      controller.duck();
      expect(controller.isDucking, isTrue);
      expect(controller.runnerHitbox.bottom, lessThan(standing.bottom));
      expect(controller.runnerHitbox.bottom, lessThan(DashGameController.lowFlyerBottom));

      _run(controller, DashGameController.duckDuration + 0.05);
      expect(controller.isDucking, isFalse);
    });

    test('jumping cancels ducking', () {
      final controller = _started()
        ..duck()
        ..jump();

      expect(controller.isDucking, isFalse);
      expect(controller.isOnGround, isFalse);
    });

    test('obstacles spawn at the right edge and scroll with the speed', () {
      final controller = DashGameController(random: Random(42))..jump();
      while (controller.obstacles.isEmpty) {
        controller.tick(_frame);
      }
      final obstacle = controller.obstacles.single;
      expect(obstacle.type, equals(DashObstacleType.block));
      expect(obstacle.x, closeTo(DashGameController.worldWidth, controller.speed / 60));

      final x = obstacle.x;
      final speed = controller.speed;
      controller.tick(const Duration(milliseconds: 100));
      expect(obstacle.x, closeTo(x - speed * 0.1, 0.01));
    });

    test('obstacles are reproducible with a seeded Random', () {
      List<(DashObstacleType, double, double, double)> obstaclesFor(int seed) {
        final controller = DashGameController(random: Random(seed))..jump();
        _run(controller, 60, beforeFrame: () => _bot(controller));
        return [for (final o in controller.obstacles) (o.type, o.x, o.width, o.height)];
      }

      expect(obstaclesFor(7), equals(obstaclesFor(7)));
      expect(obstaclesFor(7), isNot(equals(obstaclesFor(8))));
    });

    test('obstacles leave room for a full jump plus reaction time', () {
      final controller = DashGameController(random: Random(3))..jump();
      var checked = 0;
      _run(
        controller,
        150,
        beforeFrame: () {
          _bot(controller);
          final obstacles = controller.obstacles;
          for (var i = 1; i < obstacles.length; i++) {
            final gap = obstacles[i].x - obstacles[i - 1].right;
            expect(gap, greaterThanOrEqualTo(controller.speed * (DashGameController.airTime + DashGameController.reactionTime)));
            checked++;
          }
        },
      );
      expect(controller.isFinished, isFalse);
      expect(checked, greaterThan(0));
    });

    test('every generated pattern is clearable (a bot survives with many seeds)', () {
      for (var seed = 0; seed < 12; seed++) {
        final controller = DashGameController(random: Random(seed))..jump();
        final types = <DashObstacleType>{};
        _run(
          controller,
          150,
          beforeFrame: () {
            _bot(controller);
            types.addAll(controller.obstacles.map((obstacle) => obstacle.type));
          },
        );

        expect(controller.isFinished, isFalse, reason: 'seed $seed died at distance ${controller.distance}');
        expect(controller.speed, equals(DashGameController.maxSpeed));
        expect(types, containsAll(DashObstacleType.values), reason: 'seed $seed');
      }
    });

    test('flyers only appear after the flyer distance', () {
      final controller = DashGameController(random: Random(11))..jump();
      _run(
        controller,
        30,
        beforeFrame: () {
          _bot(controller);
          if (controller.distance < DashGameController.flyersFromDistance) {
            expect(controller.obstacles.where((obstacle) => obstacle.isFlyer), isEmpty);
          }
        },
      );
    });

    test('speed increases gradually up to the maximum', () {
      final controller = DashGameController(random: Random(42))..jump();
      _run(controller, 10, beforeFrame: () => _bot(controller));
      expect(controller.speed, closeTo(DashGameController.initialSpeed + 10 * DashGameController.acceleration, 0.01));

      _run(controller, 100, beforeFrame: () => _bot(controller));
      expect(controller.speed, equals(DashGameController.maxSpeed));
    });

    test('score is 10 points per world unit of distance', () {
      final controller = DashGameController(random: Random(42))..jump();
      controller.tick(const Duration(seconds: 1));

      // Distance with a linear speed-up: v0 * t + a * t^2 / 2
      const expected = DashGameController.initialSpeed + DashGameController.acceleration / 2;
      expect(controller.distance, closeTo(expected, 1e-9));
      expect(controller.score, equals((expected * DashGameController.pointsPerUnit).floor()));
    });

    test('hitting a block ends the game and reports the score', () {
      final reported = <GameResult>[];
      final controller = _started()..resultListener = reported.add;
      controller.addObstacle(DashObstacle(type: DashObstacleType.block, x: DashGameController.runnerX + 0.5, width: 1, height: 1));
      controller.tick(_frame);

      expect(controller.isGameOver, isTrue);
      expect(controller.isRunning, isFalse);
      final result = reported.single;
      expect(result.gameId, equals('dash'));
      expect(result.outcome, equals(GameOutcome.lost));
      expect(result.score, equals(controller.score));
      expect(result.score, greaterThan(0));
      expect(result.moves, equals(1));
      expect(result.data['distance'], equals(controller.distance.round()));

      // Nothing moves and input is ignored after game over
      final distance = controller.distance;
      controller
        ..tick(const Duration(seconds: 1))
        ..jump();
      expect(controller.distance, equals(distance));
      expect(controller.moves, equals(1));
    });

    test('standing into a low flyer ends the game, ducking under it does not', () {
      DashObstacle flyer() => DashObstacle(
        type: DashObstacleType.lowFlyer,
        x: DashGameController.runnerX + 0.5,
        width: DashGameController.flyerWidth,
        height: DashGameController.flyerHeight,
        bottom: DashGameController.lowFlyerBottom,
      );

      final standing = _started()..addObstacle(flyer());
      standing.tick(_frame);
      expect(standing.isGameOver, isTrue);

      final ducking = _started()
        ..duck()
        ..addObstacle(flyer());
      ducking.tick(_frame);
      expect(ducking.isGameOver, isFalse);
    });

    test('running under a high flyer is safe', () {
      final controller = _started()
        ..addObstacle(
          DashObstacle(
            type: DashObstacleType.highFlyer,
            x: DashGameController.runnerX,
            width: DashGameController.flyerWidth,
            height: DashGameController.flyerHeight,
            bottom: DashGameController.highFlyerBottom,
          ),
        );
      controller.tick(_frame);

      expect(controller.isGameOver, isFalse);
    });

    test('hitboxes are forgiving: touching the drawn shapes is not a hit', () {
      final controller = _started()
        ..addObstacle(DashObstacle(type: DashObstacleType.block, x: DashGameController.runnerX + DashGameController.runnerWidth - 0.1, width: 1, height: 1));
      controller.tick(const Duration(microseconds: 1));

      expect(controller.isGameOver, isFalse);
    });

    test('resetGame starts a new session', () {
      final controller = _started()..addObstacle(DashObstacle(type: DashObstacleType.block, x: DashGameController.runnerX + 0.5, width: 1, height: 1));
      controller
        ..tick(_frame)
        ..resetGame();

      expect(controller.isReady, isTrue);
      expect(controller.result, isNull);
      expect(controller.moves, equals(0));
      expect(controller.distance, equals(0));
      expect(controller.speed, equals(DashGameController.initialSpeed));
      expect(controller.obstacles, isEmpty);
    });

    test('swiping down before the start does nothing', () {
      final controller = DashGameController(random: Random(42))..onSwipe(GameDirection.down);

      expect(controller.isReady, isTrue);
      expect(controller.isDucking, isFalse);
    });
  });
}
