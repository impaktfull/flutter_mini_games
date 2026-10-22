import 'dart:math';

import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';
import 'package:flutter_mini_games/src/game/flit/game/logic/flit_game_controller.dart';
import 'package:flutter_mini_games/src/game/flit/game/model/flit_column.dart';
import 'package:flutter_test/flutter_test.dart';

typedef C = FlitGameController;

const _frame = Duration(milliseconds: 16);

/// Always returns the same value, so gap positions are known in advance
class _FixedRandom implements Random {
  final double value;

  _FixedRandom(this.value);

  @override
  double nextDouble() => value;

  @override
  int nextInt(int max) => (value * max).floor();

  @override
  bool nextBool() => value >= 0.5;
}

/// Next column the flyer still has to pass
FlitColumn? _nextColumn(FlitGameController controller) {
  for (final column in controller.columns) {
    if (column.x + C.columnWidth > C.flyerX - C.hitboxRadius) return column;
  }
  return null;
}

/// Simple autopilot: flaps when the flyer falls below the center of the next gap
void _fly(FlitGameController controller, {required bool Function() until, int maxFrames = 100000}) {
  for (var frame = 0; frame < maxFrames && !until(); frame++) {
    if (controller.isGameOver) fail('Crashed at score ${controller.score}');
    final target = _nextColumn(controller)?.gapCenter ?? C.startY;
    if (controller.flyerY > target + 0.03 && controller.velocity > 0) controller.flap();
    controller.tick(_frame);
  }
}

void main() {
  group('FlitGameController', () {
    test('waits for the first flap', () {
      final controller = FlitGameController(random: Random(1));

      expect(controller.isReady, isTrue);
      expect(controller.isRunning, isFalse);
      expect(controller.columns, isEmpty);

      controller.tick(const Duration(seconds: 1));
      expect(controller.flyerY, equals(C.startY));
    });

    test('the first flap starts the game and spawns columns off screen', () {
      final controller = FlitGameController(random: Random(1))..flap();

      expect(controller.status, equals(GameStatus.playing));
      expect(controller.isRunning, isTrue);
      expect(controller.moves, equals(1));
      expect(controller.velocity, equals(C.flapVelocity));
      expect(controller.columns.first.x, equals(C.worldWidth + C.firstColumnOffset));
      expect(controller.columns.every((column) => column.x > C.worldWidth), isTrue);
    });

    test('gravity pulls the flyer down and a flap sets an upward velocity', () {
      final controller = FlitGameController(random: Random(1))..flap();

      controller.tick(const Duration(milliseconds: 100));
      expect(controller.velocity, closeTo(C.flapVelocity + C.gravity * 0.1, 1e-9));
      expect(controller.flyerY, closeTo(C.startY + controller.velocity * 0.1, 1e-9));
      expect(controller.flyerY, lessThan(C.startY));

      for (var i = 0; i < 20; i++) {
        controller.tick(_frame);
      }
      expect(controller.velocity, greaterThan(0));

      controller.flap();
      expect(controller.velocity, equals(C.flapVelocity));
      expect(controller.moves, equals(2));
    });

    test('limits the fall speed', () {
      final controller = FlitGameController(random: Random(1));
      while (controller.flyerY > 0.25) {
        controller
          ..flap()
          ..tick(_frame);
      }
      var fastest = 0.0;
      while (!controller.isGameOver) {
        controller.tick(_frame);
        fastest = max(fastest, controller.velocity);
      }

      expect(fastest, equals(C.maxFallSpeed));
    });

    test('physics are independent of the frame rate', () {
      final fast = FlitGameController(random: Random(1))..flap();
      final slow = FlitGameController(random: Random(1))..flap();
      for (var i = 0; i < 100; i++) {
        fast.tick(const Duration(milliseconds: 4));
      }
      for (var i = 0; i < 20; i++) {
        slow.tick(const Duration(milliseconds: 20));
      }

      expect(fast.flyerY, closeTo(slow.flyerY, 0.01));
      expect(fast.columns.first.x, closeTo(slow.columns.first.x, 1e-9));
    });

    test('columns scroll at a constant speed', () {
      final controller = FlitGameController(random: Random(1))..flap();
      final start = controller.columns.first.x;

      controller.tick(const Duration(milliseconds: 200));

      expect(controller.columns.first.x, closeTo(start - C.scrollSpeed * 0.2, 1e-9));
    });

    test('spawns new columns at a fixed spacing and recycles the ones that left the board', () {
      final controller = FlitGameController(random: Random(3))..flap();
      final first = controller.columns.first;

      _fly(controller, until: () => !controller.columns.contains(first));

      final columns = controller.columns;
      expect(columns.first.x + C.columnWidth, greaterThanOrEqualTo(0));
      expect(columns.last.x, greaterThan(C.worldWidth));
      expect(columns.length, lessThanOrEqualTo((C.worldWidth / C.columnSpacing).ceil() + 2));
      for (var i = 1; i < columns.length; i++) {
        expect(columns[i].x - columns[i - 1].x, closeTo(C.columnSpacing, 1e-9));
      }
    });

    test('gaps are always within bounds and reachable from the previous gap', () {
      for (final seed in [1, 2, 3, 42]) {
        final controller = FlitGameController(random: Random(seed))..flap();
        final seen = <FlitColumn>[];
        _fly(
          controller,
          until: () {
            for (final column in controller.columns) {
              if (!seen.any((seenColumn) => identical(seenColumn, column) || seenColumn.gapCenter == column.gapCenter)) seen.add(column);
            }
            return controller.score >= 60;
          },
        );

        expect(seen.length, greaterThanOrEqualTo(60));
        for (var i = 0; i < seen.length; i++) {
          final column = seen[i];
          expect(column.gapTop, greaterThanOrEqualTo(C.gapMargin - 1e-9));
          expect(column.gapBottom, lessThanOrEqualTo(C.groundY - C.gapMargin + 1e-9));
          expect(column.gapSize, greaterThanOrEqualTo(C.minGapSize));
          if (i > 0) {
            expect((column.gapCenter - seen[i - 1].gapCenter).abs(), lessThanOrEqualTo(C.maxGapShift + 1e-9));
            expect(column.gapSize, lessThanOrEqualTo(seen[i - 1].gapSize));
          }
        }
        expect(seen.first.gapSize, equals(C.initialGapSize));
        expect(seen.last.gapSize, equals(C.minGapSize));
      }
    });

    test('scores a point when the flyer passes a column', () {
      final controller = FlitGameController(random: Random(7))..flap();
      final first = controller.columns.first;

      _fly(controller, until: () => controller.columns.first.x + C.columnWidth < C.flyerX + C.scrollSpeed * 0.1);
      expect(controller.score, equals(0));

      _fly(controller, until: () => controller.score == 1);
      final passed = controller.columns.firstWhere((column) => column.gapCenter == first.gapCenter);
      expect(passed.isPassed, isTrue);
      expect(passed.x + C.columnWidth, lessThan(C.flyerX));
      expect(passed.x + C.columnWidth, greaterThan(C.flyerX - C.scrollSpeed * 0.02));

      _fly(controller, until: () => controller.score == 5);
      expect(controller.score, equals(5));
    });

    test('hitting the top ends the game', () {
      final controller = FlitGameController(random: Random(1));
      while (!controller.isGameOver) {
        controller
          ..flap()
          ..tick(_frame);
      }

      expect(controller.flyerY - C.hitboxRadius, lessThanOrEqualTo(0.01));
      expect(controller.result?.outcome, equals(GameOutcome.lost));
      expect(controller.result?.score, equals(0));
    });

    test('hitting the ground ends the game', () {
      final controller = FlitGameController(random: Random(1))..flap();
      while (!controller.isGameOver) {
        controller.tick(_frame);
      }

      expect(controller.flyerY + C.hitboxRadius, closeTo(C.groundY, 1e-9));
      expect(controller.columns.first.x, greaterThan(C.flyerX));
      expect(controller.isRunning, isFalse);
      expect(controller.result?.outcome, equals(GameOutcome.lost));
    });

    test('hitting a column ends the game', () {
      // Every gap at the top: 0.1 .. 0.4
      final controller = FlitGameController(random: _FixedRandom(0))..flap();
      expect(controller.columns.first.gapTop, closeTo(C.gapMargin, 1e-9));

      // Hover low, below the gap
      while (!controller.isGameOver) {
        if (controller.flyerY > 0.65 && controller.velocity > 0) controller.flap();
        controller.tick(_frame);
      }

      final column = controller.columns.first;
      expect(column.x, lessThanOrEqualTo(C.flyerX + C.hitboxRadius));
      expect(controller.flyerY, greaterThan(column.gapBottom));
      expect(controller.flyerY + C.hitboxRadius, lessThan(C.groundY));
      expect(controller.result?.outcome, equals(GameOutcome.lost));
    });

    test('reports the score of the finished game', () {
      final reported = <GameResult>[];
      final controller = FlitGameController(random: Random(5))..resultListener = reported.add;
      controller.flap();

      _fly(controller, until: () => controller.score == 3);
      final flaps = controller.moves;
      while (!controller.isGameOver) {
        controller.tick(_frame);
      }

      final result = reported.single;
      expect(result.gameId, equals('flit'));
      expect(result.outcome, equals(GameOutcome.lost));
      expect(result.score, equals(3));
      expect(result.moves, equals(flaps));
    });

    test('ignores flaps after game over and starts over on reset', () {
      final controller = FlitGameController(random: Random(1))..flap();
      while (!controller.isGameOver) {
        controller.tick(_frame);
      }
      final y = controller.flyerY;

      controller.flap();
      expect(controller.flyerY, equals(y));
      expect(controller.moves, equals(1));

      controller.resetGame();
      expect(controller.isReady, isTrue);
      expect(controller.result, isNull);
      expect(controller.score, equals(0));
      expect(controller.columns, isEmpty);
      expect(controller.flyerY, equals(C.startY));
      expect(controller.velocity, equals(0));
    });
  });
}
