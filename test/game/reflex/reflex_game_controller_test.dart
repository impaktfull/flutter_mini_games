import 'dart:math';

import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';
import 'package:flutter_mini_games/src/game/reflex/game/logic/reflex_game_controller.dart';
import 'package:flutter_mini_games/src/game/reflex/game/model/reflex_phase.dart';
import 'package:flutter_test/flutter_test.dart';

const _frame = Duration(milliseconds: 16);

/// Ticks in frames until the board changes color
void _waitForGo(ReflexGameController controller, {Duration frame = _frame}) {
  for (var i = 0; i < 10000; i++) {
    if (controller.phase == ReflexPhase.go) return;
    controller.tick(frame);
  }
  fail('The board never changed color');
}

/// Plays one try with a reaction of [reaction] and taps
void _react(ReflexGameController controller, Duration reaction) {
  _waitForGo(controller);
  controller.tick(reaction);
  controller.onTap();
}

void main() {
  group('ReflexGameController', () {
    test('starts ready and does not run before the first tap', () {
      final controller = ReflexGameController(random: Random(42));

      expect(controller.phase, equals(ReflexPhase.ready));
      expect(controller.isRunning, isFalse);
      controller.tick(const Duration(seconds: 10));
      expect(controller.phase, equals(ReflexPhase.ready));
      expect(controller.status, equals(GameStatus.ready));
    });

    test('the start tap starts the session without counting a move', () {
      final controller = ReflexGameController(random: Random(42))..onTap();

      expect(controller.phase, equals(ReflexPhase.waiting));
      expect(controller.isRunning, isTrue);
      expect(controller.status, equals(GameStatus.playing));
      expect(controller.moves, equals(0));
      expect(controller.currentTry, equals(1));
    });

    test('delays are random and within 1.5 to 5 seconds', () {
      final random = Random(7);
      final delays = <Duration>{};
      for (var i = 0; i < 500; i++) {
        final controller = ReflexGameController(random: random)..onTap();
        expect(controller.delay, greaterThanOrEqualTo(ReflexGameController.minDelay));
        expect(controller.delay, lessThanOrEqualTo(ReflexGameController.maxDelay));
        delays.add(controller.delay);
      }
      expect(delays.length, greaterThan(400));
    });

    test('a seeded Random gives the same delays', () {
      final a = ReflexGameController(random: Random(3))..onTap();
      final b = ReflexGameController(random: Random(3))..onTap();
      expect(a.delay, equals(b.delay));
    });

    test('the board changes color exactly when the delay has passed', () {
      final controller = ReflexGameController(random: Random(42))..onTap();
      final delay = controller.delay;

      controller.tick(delay - const Duration(microseconds: 1));
      expect(controller.phase, equals(ReflexPhase.waiting));
      controller.tick(const Duration(microseconds: 1));
      expect(controller.phase, equals(ReflexPhase.go));
    });

    test('measures the game time from the change to the tap, frame-rate independent', () {
      final a = ReflexGameController(random: Random(1))..onTap();
      final b = ReflexGameController(random: Random(1))..onTap();
      _waitForGo(a, frame: const Duration(milliseconds: 8));
      _waitForGo(b, frame: const Duration(milliseconds: 33));

      a.tick(const Duration(milliseconds: 240));
      for (var i = 0; i < 12; i++) {
        b.tick(const Duration(milliseconds: 20));
      }
      a.onTap();
      b.onTap();

      expect(a.times, equals([240]));
      expect(b.times, equals([240]));
      expect(a.phase, equals(ReflexPhase.measured));
      expect(a.lastTime, equals(240));
      expect(a.moves, equals(1));
    });

    test('ticks while measured do not change the time and a tap starts the next try', () {
      final controller = ReflexGameController(random: Random(42))..onTap();
      _react(controller, const Duration(milliseconds: 300));
      controller.tick(const Duration(seconds: 2));
      expect(controller.times, equals([300]));
      expect(controller.isRunning, isFalse);

      controller.onTap();
      expect(controller.phase, equals(ReflexPhase.waiting));
      expect(controller.currentTry, equals(2));
    });

    test('tapping too early retries the same try with a new delay', () {
      final controller = ReflexGameController(random: Random(42))..onTap();
      final firstDelay = controller.delay;
      controller.tick(const Duration(milliseconds: 500));

      controller.onTap();
      expect(controller.phase, equals(ReflexPhase.tooEarly));
      expect(controller.earlyTaps, equals(1));
      expect(controller.times, isEmpty);
      expect(controller.isRunning, isFalse);
      expect(controller.currentTry, equals(1));

      // Time does not pass while the message is shown
      controller.tick(const Duration(seconds: 10));
      expect(controller.phase, equals(ReflexPhase.tooEarly));

      controller.onTap();
      expect(controller.phase, equals(ReflexPhase.waiting));
      expect(controller.currentTry, equals(1));
      expect(controller.delay, isNot(equals(firstDelay)));

      // The retry starts waiting from zero
      controller.tick(controller.delay - const Duration(milliseconds: 1));
      expect(controller.phase, equals(ReflexPhase.waiting));
      _react(controller, const Duration(milliseconds: 200));
      expect(controller.times, equals([200]));
    });

    test('averages the tries and finishes after 5 with the score', () {
      final controller = ReflexGameController(random: Random(42))..onTap();
      const reactions = [200, 250, 300, 220, 281];
      for (final (i, ms) in reactions.indexed) {
        _react(controller, Duration(milliseconds: ms));
        if (i < reactions.length - 1) {
          expect(controller.isFinished, isFalse);
          controller.onTap();
        }
      }

      expect(controller.times, equals(reactions));
      // (200 + 250 + 300 + 220 + 281) / 5 = 250.2
      expect(controller.averageMs, equals(250));
      expect(controller.bestMs, equals(200));
      expect(controller.phase, equals(ReflexPhase.finished));
      expect(controller.isGameOver, isTrue);
      expect(controller.isRunning, isFalse);
      expect(controller.score, equals(750));
    });

    test('reports a won GameResult with the score and the average', () {
      final results = <GameResult>[];
      final controller = ReflexGameController(random: Random(42))
        ..resultListener = results.add
        ..onTap();
      controller.tick(const Duration(milliseconds: 100));
      controller.onTap(); // too early
      controller.onTap(); // retry
      for (var i = 0; i < ReflexGameController.tries; i++) {
        _react(controller, const Duration(milliseconds: 180));
        if (i < ReflexGameController.tries - 1) controller.onTap();
      }

      final result = results.single;
      expect(result.gameId, equals('reflex'));
      expect(result.outcome, equals(GameOutcome.won));
      expect(result.score, equals(820));
      expect(result.data['averageMs'], equals(180));
      expect(result.data['bestMs'], equals(180));
      expect(result.data['timesMs'], equals([180, 180, 180, 180, 180]));
      expect(result.data['earlyTaps'], equals(1));
      expect(result.moves, equals(6));

      // Taps after the end are ignored
      controller.onTap();
      expect(results, hasLength(1));
    });

    test('the score is never negative', () {
      expect(ReflexGameController.calculateScore(250), equals(750));
      expect(ReflexGameController.calculateScore(1000), equals(0));
      expect(ReflexGameController.calculateScore(1800), equals(0));

      final controller = ReflexGameController(random: Random(42))..onTap();
      for (var i = 0; i < ReflexGameController.tries; i++) {
        _react(controller, const Duration(milliseconds: 1500));
        if (i < ReflexGameController.tries - 1) controller.onTap();
      }
      expect(controller.result!.score, equals(0));
      expect(controller.result!.data['averageMs'], equals(1500));
    });

    test('reset starts a new game', () {
      final controller = ReflexGameController(random: Random(42))..onTap();
      _react(controller, const Duration(milliseconds: 300));
      controller.resetGame();

      expect(controller.phase, equals(ReflexPhase.ready));
      expect(controller.times, isEmpty);
      expect(controller.averageMs, isNull);
      expect(controller.moves, equals(0));
      expect(controller.status, equals(GameStatus.ready));
      expect(controller.earlyTaps, equals(0));
    });
  });
}
