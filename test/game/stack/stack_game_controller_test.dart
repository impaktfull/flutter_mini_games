import 'dart:math';

import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';
import 'package:flutter_mini_games/src/game/stack/game/logic/stack_game_controller.dart';
import 'package:flutter_test/flutter_test.dart';

Duration _seconds(double seconds) => Duration(microseconds: (seconds * Duration.microsecondsPerSecond).round());

/// Ticks until the moving block is at [left] (within a microsecond of movement)
void _moveTo(StackGameController controller, double left) {
  for (var i = 0; i < 1000; i++) {
    final distance = left - controller.current.left;
    if (distance.abs() < 1e-5) return;
    if (distance.sign == controller.direction) {
      controller.tick(_seconds(distance.abs() / controller.speed));
    } else {
      controller.tick(const Duration(milliseconds: 20));
    }
  }
  fail('Block never reached $left');
}

StackGameController _started() => StackGameController(random: Random(42))..start();

void main() {
  group('StackGameController', () {
    test('starts ready with a centered base and a block on one side', () {
      final controller = StackGameController(random: Random(42));

      expect(controller.isReady, isTrue);
      expect(controller.isRunning, isFalse);
      expect(controller.tower.single.left, closeTo((1 - StackGameController.baseWidth) / 2, 1e-9));
      expect(controller.current.level, equals(1));
      expect(controller.current.width, equals(StackGameController.baseWidth));
      final onLeft = controller.current.left == 0;
      expect(controller.direction, equals(onLeft ? 1 : -1));
    });

    test('does not move before the game is started', () {
      final controller = StackGameController(random: Random(42));
      final left = controller.current.left;
      controller.tick(const Duration(milliseconds: 100));

      expect(controller.current.left, equals(left));
    });

    test('a tap starts the game and the block slides frame-rate independently', () {
      final a = StackGameController(random: Random(1))..onTap();
      final b = StackGameController(random: Random(1))..onTap();
      expect(a.isRunning, isTrue);
      expect(a.status, equals(GameStatus.playing));

      a.tick(const Duration(milliseconds: 200));
      for (var i = 0; i < 20; i++) {
        b.tick(const Duration(milliseconds: 10));
      }

      expect(a.current.left, closeTo(b.current.left, 1e-9));
      final start = a.direction > 0 ? 0.0 : 1 - StackGameController.baseWidth;
      expect((a.current.left - start).abs(), closeTo(StackGameController.startSpeed * 0.2, 1e-9));
    });

    test('bounces at the edges of the world', () {
      final controller = _started();
      final maxLeft = 1 - controller.current.width;
      // Long enough to reach an edge from anywhere
      final toEdge = maxLeft / controller.speed;

      final initialDirection = controller.direction;
      final back = controller.speed * 0.1;

      // Crosses the world, bounces off the far edge and moves back for 0.1s
      controller.tick(_seconds(toEdge + 0.1));
      expect(controller.direction, equals(-initialDirection));
      expect(controller.current.left, closeTo(initialDirection > 0 ? maxLeft - back : back, 1e-5));

      controller.tick(_seconds(toEdge));
      expect(controller.direction, equals(initialDirection));
      expect(controller.current.left, closeTo(initialDirection > 0 ? back : maxLeft - back, 1e-5));
    });

    test('cuts the overhang and lets it fall away', () {
      final controller = _started();
      final base = controller.tower.first;
      _moveTo(controller, base.left + 0.1);
      controller.drop();

      final placed = controller.tower.last;
      expect(controller.placedBlocks, equals(1));
      expect(placed.level, equals(1));
      expect(placed.left, closeTo(base.left + 0.1, 1e-4));
      expect(placed.right, closeTo(base.right, 1e-9));
      expect(placed.width, closeTo(base.width - 0.1, 1e-4));

      final piece = controller.fallingPieces.single;
      expect(piece.block.left, closeTo(base.right, 1e-9));
      expect(piece.block.width, closeTo(0.1, 1e-4));

      // Next block has the remaining width and the piece falls
      expect(controller.current.level, equals(2));
      expect(controller.current.width, closeTo(placed.width, 1e-9));
      controller.tick(const Duration(milliseconds: 100));
      expect(controller.fallingPieces.single.drop, greaterThan(0));
      expect(controller.streak, equals(0));
      expect(controller.score, equals(1));
    });

    test('cuts the overhang on the left side', () {
      final controller = _started();
      final base = controller.tower.first;
      _moveTo(controller, base.left - 0.15);
      controller.drop();

      final placed = controller.tower.last;
      expect(placed.left, closeTo(base.left, 1e-9));
      expect(placed.width, closeTo(base.width - 0.15, 1e-4));
      expect(controller.fallingPieces.single.block.left, closeTo(base.left - 0.15, 1e-4));
    });

    test('snaps a perfect drop to the block below and gives a growing bonus', () {
      final controller = _started();
      final base = controller.tower.first;

      _moveTo(controller, base.left + StackGameController.perfectTolerance / 2);
      controller.drop();
      expect(controller.lastDropWasPerfect, isTrue);
      expect(controller.tower.last.left, equals(base.left));
      expect(controller.tower.last.width, equals(base.width));
      expect(controller.fallingPieces, isEmpty);
      expect(controller.streak, equals(1));
      expect(controller.score, equals(2)); // 1 + bonus 1

      _moveTo(controller, base.left - StackGameController.perfectTolerance / 2);
      controller.drop();
      expect(controller.streak, equals(2));
      expect(controller.score, equals(2 + 3)); // 1 + bonus 2

      // A normal drop ends the streak
      _moveTo(controller, base.left + 0.05);
      controller.drop();
      expect(controller.streak, equals(0));
      expect(controller.lastDropWasPerfect, isFalse);
      expect(controller.score, equals(6));
      expect(controller.perfects, equals(2));
    });

    test('caps the perfect bonus', () {
      final controller = _started();
      final base = controller.tower.first;
      for (var i = 0; i < StackGameController.maxPerfectBonus + 2; i++) {
        _moveTo(controller, base.left);
        controller.drop();
      }

      // Bonus 1+2+3+4+5+5+5 on top of 7 blocks
      expect(controller.score, equals(7 + 1 + 2 + 3 + 4 + 5 + 5 + 5));
    });

    test('speeds up for every placed block', () {
      final controller = _started();
      final base = controller.tower.first;
      expect(controller.speed, equals(StackGameController.startSpeed));

      _moveTo(controller, base.left);
      controller.drop();
      expect(controller.speed, closeTo(StackGameController.startSpeed + StackGameController.speedIncrement, 1e-9));

      for (var i = 0; i < 100; i++) {
        _moveTo(controller, base.left);
        controller.drop();
      }
      expect(controller.speed, equals(StackGameController.maxSpeed));
    });

    test('a miss ends the game and reports the score', () {
      final reported = <GameResult>[];
      final controller = _started()..resultListener = reported.add;
      final base = controller.tower.first;

      // Two cuts leave a narrow block on the right
      _moveTo(controller, base.left + 0.2);
      controller.drop();
      _moveTo(controller, 1 - controller.current.width);
      controller.drop();
      expect(controller.tower.last.width, closeTo(0.2, 1e-4));
      // Completely next to the tower
      _moveTo(controller, 0);
      expect(controller.current.right, lessThan(controller.tower.last.left));
      controller.drop();

      expect(controller.isGameOver, isTrue);
      expect(controller.isRunning, isFalse);
      expect(controller.isFinished, isTrue);
      expect(controller.placedBlocks, equals(2));
      expect(controller.score, equals(2));
      final result = reported.single;
      expect(result.gameId, equals(StackGameController.id));
      expect(result.outcome, equals(GameOutcome.lost));
      expect(result.score, equals(2));
      expect(result.moves, equals(4)); // start + 3 drops
      expect(result.data, equals({'blocks': 2, 'perfects': 0}));

      // Taps and ticks are ignored after game over
      final left = controller.current.left;
      controller
        ..onTap()
        ..tick(const Duration(milliseconds: 100));
      expect(controller.moves, equals(4));
      expect(controller.current.left, equals(left));
      expect(reported, hasLength(1));
    });

    test('the view scrolls up as the tower grows', () {
      final controller = _started();
      final base = controller.tower.first;
      for (var i = 0; i < 20; i++) {
        _moveTo(controller, base.left);
        controller.drop();
      }
      controller.tick(const Duration(seconds: 2));

      expect(controller.targetCameraY, greaterThan(0));
      expect(StackGameController(random: Random(1)).cameraY, equals(-StackGameController.groundHeight));
      expect(controller.cameraY, closeTo(controller.targetCameraY, 0.01));
      // The moving block stays in view
      final currentBottom = controller.current.level * StackGameController.blockHeight;
      expect(currentBottom, greaterThan(controller.cameraY));
      expect(currentBottom + StackGameController.blockHeight, lessThan(controller.cameraY + StackGameController.viewHeight));
    });

    test('reset starts a new game', () {
      final controller = _started();
      final base = controller.tower.first;
      _moveTo(controller, 0);
      controller.drop();
      _moveTo(controller, base.left + 0.2);
      controller.drop();

      controller.resetGame();

      expect(controller.isReady, isTrue);
      expect(controller.isGameOver, isFalse);
      expect(controller.tower, hasLength(1));
      expect(controller.score, equals(0));
      expect(controller.moves, equals(0));
      expect(controller.speed, equals(StackGameController.startSpeed));
      expect(controller.fallingPieces, isEmpty);
      expect(controller.cameraY, equals(-StackGameController.groundHeight));
    });
  });
}
