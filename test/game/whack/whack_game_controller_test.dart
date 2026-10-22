import 'dart:math';

import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';
import 'package:flutter_mini_games/src/game/whack/game/logic/whack_game_controller.dart';
import 'package:flutter_mini_games/src/game/whack/game/model/whack_target.dart';
import 'package:flutter_test/flutter_test.dart';

Duration _seconds(double seconds) => Duration(microseconds: (seconds * Duration.microsecondsPerSecond).round());

WhackGameController _started({int seed = 42}) => WhackGameController(random: Random(seed))..start();

/// Ticks in frames of [frame] for [seconds]
void _run(WhackGameController controller, double seconds, {Duration frame = const Duration(milliseconds: 16)}) {
  var left = _seconds(seconds);
  while (left > Duration.zero) {
    final step = left < frame ? left : frame;
    controller.tick(step);
    left -= step;
  }
}

/// Ticks until a target of [kind] is up and can be hit
WhackTarget _waitFor(WhackGameController controller, WhackTargetKind kind) {
  for (var i = 0; i < 2000; i++) {
    for (final target in controller.targets) {
      if (target.kind == kind && target.isHittableAt(controller.time)) return target;
    }
    controller.tick(const Duration(milliseconds: 10));
  }
  fail('No $kind showed up');
}

void main() {
  group('WhackGameController', () {
    test('starts ready, nothing happens before the start tap', () {
      final controller = WhackGameController(random: Random(42));
      expect(controller.isReady, isTrue);
      expect(controller.isRunning, isFalse);
      expect(controller.remaining, equals(WhackGameController.roundDuration));

      controller
        ..tick(const Duration(seconds: 1))
        ..whack(0);
      expect(controller.time, equals(0));
      expect(controller.targets, isEmpty);
      expect(controller.moves, equals(0));
      expect(controller.misses, equals(0));
    });

    test('the start tap starts the round without counting a move', () {
      final controller = _started();
      expect(controller.status, equals(GameStatus.playing));
      expect(controller.isRunning, isTrue);
      expect(controller.moves, equals(0));
    });

    test('spawns the first target after the first spawn delay, then at the spawn interval', () {
      final controller = _started();
      _run(controller, WhackGameController.firstSpawnDelay - 0.01);
      expect(controller.targets, isEmpty);

      _run(controller, 0.02);
      final first = controller.targets.single;
      expect(first.spawnedAt, closeTo(WhackGameController.firstSpawnDelay, 1e-9));
      expect(first.visibleDuration, closeTo(WhackGameController.visibleDurationAt(first.spawnedAt), 1e-9));
      expect(controller.nextSpawnAt, closeTo(first.spawnedAt + WhackGameController.spawnIntervalAt(first.spawnedAt), 1e-9));
    });

    test('visible durations and spawn intervals shrink during the round', () {
      expect(WhackGameController.visibleDurationAt(0), equals(WhackGameController.startVisibleDuration));
      expect(WhackGameController.visibleDurationAt(WhackGameController.roundDuration), closeTo(WhackGameController.endVisibleDuration, 1e-9));
      expect(WhackGameController.spawnIntervalAt(0), equals(WhackGameController.startSpawnInterval));
      expect(WhackGameController.spawnIntervalAt(WhackGameController.roundDuration), closeTo(WhackGameController.endSpawnInterval, 1e-9));

      // Every spawned target is up shorter than the one before it
      final controller = _started();
      final seen = <double, double>{};
      for (var i = 0; i < 2000 && !controller.isFinished; i++) {
        controller.tick(const Duration(milliseconds: 16));
        for (final target in controller.targets) {
          seen[target.spawnedAt] = target.visibleDuration;
        }
      }
      final durations = (seen.keys.toList()..sort()).map((at) => seen[at]!).toList();
      expect(durations.length, greaterThan(30));
      for (var i = 1; i < durations.length; i++) {
        expect(durations[i], lessThan(durations[i - 1]));
      }
      expect(durations.first, closeTo(WhackGameController.startVisibleDuration, 0.05));
      expect(durations.last, closeTo(WhackGameController.endVisibleDuration, 0.05));
    });

    test('several targets can be up at once, never two in the same hole', () {
      final controller = _started();
      var maxUp = 0;
      for (var i = 0; i < 2000 && !controller.isFinished; i++) {
        controller.tick(const Duration(milliseconds: 16));
        final holes = controller.targets.map((target) => target.hole).toList();
        expect(holes.toSet(), hasLength(holes.length));
        maxUp = max(maxUp, holes.length);
      }
      expect(maxUp, greaterThan(1));
    });

    test('a target hides again after its visible duration and counts as escaped', () {
      final controller = _started();
      final target = _waitFor(controller, WhackTargetKind.critter);
      final escaped = controller.escaped;
      _run(controller, target.hidesAt - controller.time + 0.001, frame: const Duration(milliseconds: 1));

      expect(controller.targets.where((t) => t.spawnedAt == target.spawnedAt), isEmpty);
      expect(controller.escaped, equals(escaped + 1));
    });

    test('pops up and hides with an animation', () {
      const target = WhackTarget(hole: 0, kind: WhackTargetKind.critter, spawnedAt: 1, visibleDuration: 1);
      double pop(double time) => target.popAt(time, popDuration: WhackGameController.popDuration, hitLinger: WhackGameController.hitLinger);

      expect(pop(1), equals(0));
      expect(pop(1 + WhackGameController.popDuration / 2), closeTo(0.5, 1e-9));
      expect(pop(1.5), equals(1));
      expect(pop(2 - WhackGameController.popDuration / 2), closeTo(0.5, 1e-9));
      expect(pop(2), equals(0));

      final hit = target.copyWith(hitAt: 1.5);
      expect(hit.popAt(1.5 + WhackGameController.hitLinger / 2, popDuration: WhackGameController.popDuration, hitLinger: WhackGameController.hitLinger), closeTo(0.5, 1e-9));
      expect(hit.goneAt(WhackGameController.hitLinger), closeTo(1.5 + WhackGameController.hitLinger, 1e-9));
    });

    test('tapping a critter scores a point, tapping it again is a miss', () {
      final controller = _started();
      final target = _waitFor(controller, WhackTargetKind.critter);

      controller.whack(target.hole);
      expect(controller.hits, equals(1));
      expect(controller.score, equals(1));
      expect(controller.moves, equals(1));
      expect(controller.targetAt(target.hole)!.isHit, isTrue);

      controller.whack(target.hole);
      expect(controller.hits, equals(1));
      expect(controller.misses, equals(1));
      expect(controller.moves, equals(2));

      // The hit target drops back and frees the hole
      _run(controller, WhackGameController.hitLinger + 0.01, frame: const Duration(milliseconds: 1));
      expect(controller.targets.where((t) => t.spawnedAt == target.spawnedAt), isEmpty);
      expect(controller.escaped, equals(0));
    });

    test('tapping a decoy costs a point', () {
      final controller = _started();
      final critter = _waitFor(controller, WhackTargetKind.critter);
      controller.whack(critter.hole);
      final decoy = _waitFor(controller, WhackTargetKind.decoy);
      controller.whack(decoy.hole);

      expect(controller.hits, equals(1));
      expect(controller.decoysHit, equals(1));
      expect(controller.score, equals(0));
    });

    test('a tap on an empty hole is a miss and does not cost points', () {
      final controller = _started();
      _run(controller, 1);
      final empty = List.generate(WhackGameController.holeCount, (i) => i).firstWhere((hole) => controller.targetAt(hole) == null);

      controller.whack(empty);
      expect(controller.misses, equals(1));
      expect(controller.score, equals(0));
      expect(controller.moves, equals(1));
    });

    test('the round ends after 30 seconds and reports the result', () {
      final reported = <GameResult>[];
      final controller = _started()..resultListener = reported.add;
      final critter = _waitFor(controller, WhackTargetKind.critter);
      controller.whack(critter.hole);
      final second = _waitFor(controller, WhackTargetKind.critter);
      controller.whack(second.hole);
      final decoy = _waitFor(controller, WhackTargetKind.decoy);
      controller.whack(decoy.hole);
      controller.whack(-1); // Ignored

      _run(controller, WhackGameController.roundDuration - controller.time - 0.01);
      expect(controller.isFinished, isFalse);
      expect(reported, isEmpty);

      _run(controller, 0.05);
      expect(controller.isFinished, isTrue);
      expect(controller.isGameOver, isTrue);
      expect(controller.isRunning, isFalse);
      expect(controller.time, equals(WhackGameController.roundDuration));
      expect(controller.remaining, equals(0));
      expect(controller.targets, isEmpty);

      final result = reported.single;
      expect(result.gameId, equals(WhackGameController.id));
      expect(result.outcome, equals(GameOutcome.won));
      expect(result.score, equals(1));
      expect(result.moves, equals(3));
      expect(result.data['hits'], equals(2));
      expect(result.data['decoys'], equals(1));
      expect(result.data['misses'], equals(0));
      expect(result.data['escaped'], equals(controller.escaped));
      expect(controller.escaped, greaterThan(0));

      // Taps and ticks are ignored after the round
      controller
        ..whack(0)
        ..tick(const Duration(seconds: 1));
      expect(controller.moves, equals(3));
      expect(reported, hasLength(1));
    });

    test('a long frame at the end of the round does not overshoot', () {
      final controller = _started();
      controller.tick(const Duration(seconds: 40));
      expect(controller.isFinished, isTrue);
      expect(controller.time, equals(WhackGameController.roundDuration));
      expect(controller.result!.score, equals(0));
    });

    test('is frame-rate independent', () {
      final a = _started(seed: 7);
      final b = _started(seed: 7);
      _run(a, 12.345, frame: const Duration(milliseconds: 50));
      _run(b, 12.345, frame: const Duration(milliseconds: 7));

      expect(a.time, equals(b.time));
      expect(a.targets.map((t) => (t.hole, t.kind, t.spawnedAt)).toList(), equals(b.targets.map((t) => (t.hole, t.kind, t.spawnedAt)).toList()));
      expect(a.escaped, equals(b.escaped));
    });

    test('the same seed gives the same targets', () {
      List<(int, WhackTargetKind)> play(int seed) {
        final controller = _started(seed: seed);
        final spawned = <double, (int, WhackTargetKind)>{};
        for (var i = 0; i < 2000 && !controller.isFinished; i++) {
          controller.tick(const Duration(milliseconds: 16));
          for (final target in controller.targets) {
            spawned[target.spawnedAt] = (target.hole, target.kind);
          }
        }
        return (spawned.keys.toList()..sort()).map((at) => spawned[at]!).toList();
      }

      final first = play(3);
      expect(play(3), equals(first));
      expect(play(4), isNot(equals(first)));
      final decoys = first.where((t) => t.$2 == WhackTargetKind.decoy).length;
      expect(decoys, greaterThan(0));
      expect(decoys, lessThan(first.length / 2));
    });

    test('a perfect player scores every critter', () {
      final reported = <GameResult>[];
      final controller = _started()..resultListener = reported.add;
      var critters = 0;
      for (var i = 0; i < 4000 && !controller.isFinished; i++) {
        controller.tick(const Duration(milliseconds: 16));
        for (final target in controller.targets) {
          if (!target.isDecoy && target.isHittableAt(controller.time)) {
            critters++;
            controller.whack(target.hole);
          }
        }
      }
      expect(controller.escaped, equals(0));
      expect(reported.single.score, equals(critters));
      expect(critters, greaterThan(20));
    });

    test('reset starts a new round', () {
      final controller = _started();
      final target = _waitFor(controller, WhackTargetKind.critter);
      controller.whack(target.hole);
      _run(controller, 3);

      controller.resetGame();
      expect(controller.isReady, isTrue);
      expect(controller.time, equals(0));
      expect(controller.targets, isEmpty);
      expect(controller.score, equals(0));
      expect(controller.hits, equals(0));
      expect(controller.misses, equals(0));
      expect(controller.escaped, equals(0));
      expect(controller.moves, equals(0));
      expect(controller.nextSpawnAt, equals(WhackGameController.firstSpawnDelay));
    });
  });
}
