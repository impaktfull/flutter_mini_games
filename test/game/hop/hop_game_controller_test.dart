import 'dart:math';

import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';
import 'package:flutter_mini_games/src/game/hop/game/logic/hop_game_controller.dart';
import 'package:flutter_mini_games/src/game/hop/game/model/hop_platform.dart';
import 'package:flutter_mini_games/src/game/hop/game/model/hop_steer.dart';
import 'package:flutter_test/flutter_test.dart';

const _frame = Duration(milliseconds: 16);

HopGameController _started({int seed = 42}) => HopGameController(random: Random(seed))..start();

void _tickFor(HopGameController controller, Duration duration, {Duration step = _frame}) {
  var elapsed = Duration.zero;
  while (elapsed < duration && controller.isRunning) {
    controller.tick(step);
    elapsed += step;
  }
}

void main() {
  group('HopGameController', () {
    test('starts ready on the start platform and does not run', () {
      final controller = HopGameController(random: Random(1));

      expect(controller.isReady, isTrue);
      expect(controller.isRunning, isFalse);
      expect(controller.platforms.first.y, equals(controller.characterY));
      expect(controller.score, equals(0));
    });

    test('gravity slows the jump down and pulls the character back', () {
      final controller = _started()..debugSetPlatforms([]);
      final startY = controller.characterY;

      controller.tick(const Duration(milliseconds: 100));
      expect(controller.characterY, greaterThan(startY));
      expect(controller.velocityY, closeTo(HopGameController.jumpVelocity - HopGameController.gravity * 0.1, 1e-9));

      _tickFor(controller, const Duration(seconds: 1));
      expect(controller.velocityY, lessThan(0));
    });

    test('physics are frame-rate independent', () {
      final fast = _started()..debugSetPlatforms([]);
      final slow = _started()..debugSetPlatforms([]);

      _tickFor(fast, const Duration(milliseconds: 480), step: const Duration(milliseconds: 8));
      _tickFor(slow, const Duration(milliseconds: 480), step: const Duration(milliseconds: 48));

      expect(fast.characterY, closeTo(slow.characterY, 1e-9));
      expect(fast.velocityY, closeTo(slow.velocityY, 1e-9));
    });

    test('passes through a platform from below and bounces when falling onto it', () {
      final platform = HopPlatform(x: 0.5, y: 0.5, width: 0.2);
      final controller = _started()
        ..debugSetPlatforms([platform])
        ..debugPlaceCharacter(x: 0.5, y: 0.4, velocityY: 1.5);

      controller.tick(const Duration(milliseconds: 100));
      expect(controller.characterY, greaterThan(platform.y));
      expect(controller.velocityY, greaterThan(0));

      // Wait until it falls back onto the platform
      var bounced = false;
      for (var i = 0; i < 200 && !bounced; i++) {
        final wasFalling = controller.velocityY < 0;
        controller.tick(_frame);
        bounced = wasFalling && controller.velocityY == HopGameController.jumpVelocity;
      }
      expect(bounced, isTrue);
      expect(controller.characterY, equals(platform.y));
    });

    test('does not bounce when it misses the platform horizontally', () {
      final controller = _started()
        ..debugSetPlatforms([HopPlatform(x: 0.2, y: 0.5, width: 0.2)])
        ..debugPlaceCharacter(x: 0.7, y: 0.55, velocityY: -1);

      _tickFor(controller, const Duration(milliseconds: 200));

      expect(controller.characterY, lessThan(0.5));
      expect(controller.velocityY, lessThan(0));
    });

    test('lands on platforms across the horizontal wrap', () {
      final controller = _started()
        ..debugSetPlatforms([HopPlatform(x: 0.1, y: 0.5, width: 0.2)])
        ..debugPlaceCharacter(x: 0.97, y: 0.52, velocityY: -1);

      _tickFor(controller, const Duration(milliseconds: 32));

      expect(controller.characterY, equals(0.5));
      expect(controller.velocityY, equals(HopGameController.jumpVelocity));
    });

    test('breakable platforms break without a bounce', () {
      final platform = HopPlatform(x: 0.5, y: 0.5, width: 0.2, type: HopPlatformType.breakable);
      final controller = _started()
        ..debugSetPlatforms([platform])
        ..debugPlaceCharacter(x: 0.5, y: 0.52, velocityY: -1);

      _tickFor(controller, const Duration(milliseconds: 100));

      expect(platform.isBroken, isTrue);
      expect(controller.characterY, lessThan(0.5));
      expect(controller.velocityY, lessThan(0));
    });

    test('steering moves horizontally and wraps around the edges', () {
      final controller = HopGameController(random: Random(3))
        ..steerTo(HopSteer.left)
        ..debugPlaceCharacter(x: 0.02);

      controller.tick(const Duration(milliseconds: 100));
      expect(controller.characterX, closeTo(0.92, 1e-9));

      controller
        ..steerTo(HopSteer.right)
        ..debugPlaceCharacter(x: 0.98)
        ..tick(const Duration(milliseconds: 100));
      expect(controller.characterX, closeTo(0.08, 1e-9));

      controller
        ..steerTo(HopSteer.none)
        ..tick(const Duration(milliseconds: 100));
      expect(controller.characterX, closeTo(0.08, 1e-9));
      expect(controller.facing, equals(HopSteer.right));
    });

    test('counts a move each time the player steers in a new direction', () {
      final controller = HopGameController(random: Random(3));

      controller.steerTo(HopSteer.left);
      expect(controller.status, equals(GameStatus.playing));
      expect(controller.velocityY, equals(HopGameController.jumpVelocity));
      controller
        ..steerTo(HopSteer.left)
        ..steerTo(HopSteer.none)
        ..steerTo(HopSteer.right)
        ..steerTo(HopSteer.left);

      expect(controller.moves, equals(3));
    });

    test('moving platforms move and bounce between the edges', () {
      final platform = HopPlatform(x: 0.5, y: 3, width: 0.2, type: HopPlatformType.moving, velocityX: 0.3);
      final controller = _started()..debugSetPlatforms([HopPlatform(x: 0.5, y: 0.1, width: 0.3), platform]);

      controller.tick(const Duration(milliseconds: 500));
      expect(platform.x, closeTo(0.65, 1e-9));

      for (var i = 0; i < 6 * 60; i++) {
        controller
          ..debugPlaceCharacter(y: 0.5, velocityY: 0)
          ..tick(_frame);
        expect(platform.left, greaterThanOrEqualTo(-1e-9));
        expect(platform.right, lessThanOrEqualTo(1 + 1e-9));
      }
      expect(platform.velocityX.abs(), equals(0.3));
    });

    test('the camera follows the character up and never down', () {
      final controller = _started(seed: 7);
      var camera = controller.cameraY;
      var steps = 0;
      while (controller.isRunning && steps < 60 * 30) {
        // Simple autopilot so the character climbs a bit
        controller.steerTo(_autopilot(controller));
        controller.tick(_frame);
        expect(controller.cameraY, greaterThanOrEqualTo(camera));
        camera = controller.cameraY;
        steps++;
      }
      expect(camera, greaterThan(0));
    });

    test('falling below the view ends the game with the height as score', () {
      final reported = <GameResult>[];
      final controller = _started()..resultListener = reported.add;
      controller.debugSetPlatforms([]);

      _tickFor(controller, const Duration(seconds: 10));

      expect(controller.isGameOver, isTrue);
      expect(controller.isRunning, isFalse);
      expect(controller.maxHeight, closeTo(HopGameController.maxJumpHeight, 0.05));
      expect(controller.score, equals((controller.maxHeight * HopGameController.scorePerUnit).floor()));
      expect(reported.single.gameId, equals(HopGameController.id));
      expect(reported.single.outcome, equals(GameOutcome.lost));
      expect(reported.single.score, equals(controller.score));
      expect(reported.single.moves, equals(0), reason: "starting without steering is not a move");

      // Input after game over is ignored
      controller.steerTo(HopSteer.left);
      expect(controller.steer, equals(HopSteer.none));
    });

    test('reset starts a new session', () {
      final controller = _started()..debugSetPlatforms([]);
      _tickFor(controller, const Duration(seconds: 10));

      controller.resetGame();

      expect(controller.isReady, isTrue);
      expect(controller.isGameOver, isFalse);
      expect(controller.result, isNull);
      expect(controller.moves, equals(0));
      expect(controller.score, equals(0));
      expect(controller.cameraY, equals(0));
      expect(controller.platforms, isNotEmpty);
    });

    test('an autopilot keeps climbing on generated platforms', () {
      for (var seed = 0; seed < 5; seed++) {
        final controller = _started(seed: seed);
        var steps = 0;
        while (controller.isRunning && steps < 60 * 60) {
          controller.steerTo(_autopilot(controller));
          controller.tick(_frame);
          steps++;
        }
        expect(controller.maxHeight, greaterThan(15), reason: 'seed $seed');
      }
    });
  });
}

/// Steers towards the highest landable platform that the current jump can still reach
HopSteer _autopilot(HopGameController controller) {
  final v = controller.velocityY;
  final apex = controller.characterY + (v > 0 ? v * v / (2 * HopGameController.gravity) : 0);
  HopPlatform? target;
  for (final platform in controller.platforms) {
    if (!platform.isSolid || platform.type == HopPlatformType.breakable) continue;
    if (platform.y > apex - 0.02) continue;
    if (v <= 0 && platform.y > controller.characterY) continue;
    if (target == null || platform.y > target.y) target = platform;
  }
  if (target == null) return HopSteer.none;
  var dx = target.x - controller.characterX;
  if (dx > 0.5) dx -= 1;
  if (dx < -0.5) dx += 1;
  if (dx.abs() < target.width / 4) return HopSteer.none;
  return dx < 0 ? HopSteer.left : HopSteer.right;
}
