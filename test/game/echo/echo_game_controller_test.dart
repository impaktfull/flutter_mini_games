import 'dart:math';

import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';
import 'package:flutter_mini_games/src/game/echo/game/logic/echo_game_controller.dart';
import 'package:flutter_test/flutter_test.dart';

/// Ticks in frames of 16 ms until the playback is over
void playBack(EchoGameController controller) {
  for (var i = 0; controller.isPlayingBack; i++) {
    if (i > 10000) fail('playback never ended');
    controller.tick(const Duration(milliseconds: 16));
  }
}

/// Repeats the current sequence correctly
void repeat(EchoGameController controller) {
  for (final pad in controller.sequence) {
    controller.tapPad(pad);
  }
}

int wrongPadFor(int pad) => (pad + 1) % EchoGameController.padCount;

void main() {
  group('EchoGameController', () {
    test('starts ready, without a sequence and not running', () {
      final controller = EchoGameController(random: Random(42));

      expect(controller.phase, equals(EchoPhase.ready));
      expect(controller.status, equals(GameStatus.ready));
      expect(controller.sequence, isEmpty);
      expect(controller.isRunning, isFalse);
      expect(controller.litPad, isNull);
      expect(controller.score, equals(0));
    });

    test('start plays back a sequence of one pad without counting a move', () {
      final controller = EchoGameController(random: Random(42))..start();

      expect(controller.status, equals(GameStatus.playing));
      expect(controller.phase, equals(EchoPhase.playback));
      expect(controller.isRunning, isTrue);
      expect(controller.sequence, hasLength(1));
      expect(controller.moves, equals(0));
    });

    test('tapping a pad when ready starts the game', () {
      final controller = EchoGameController(random: Random(42))..tapPad(2);

      expect(controller.phase, equals(EchoPhase.playback));
      expect(controller.sequence, hasLength(1));
      expect(controller.moves, equals(0));
    });

    test('the sequence is reproducible with a seeded Random', () {
      List<int> play(int seed) {
        final controller = EchoGameController(random: Random(seed))..start();
        for (var round = 0; round < 6; round++) {
          playBack(controller);
          repeat(controller);
        }
        return controller.sequence;
      }

      expect(play(7), equals(play(7)));
      expect(play(7), hasLength(7));
      expect(play(7).every((pad) => pad >= 0 && pad < EchoGameController.padCount), isTrue);
    });

    test('the playback lights every pad of the sequence in order, after the lead-in', () {
      final controller = EchoGameController(random: Random(3))..start();
      for (var round = 0; round < 4; round++) {
        playBack(controller);
        repeat(controller);
      }

      // Repeated pads are separated by a dark gap, so count lit periods per pad
      final lit = <int>[];
      var wasLit = false;
      // The last tap flashes during the lead-in, then nothing is lit until the playback starts
      expect(controller.litPad, equals(controller.sequence[3]));
      controller.tick(EchoGameController.leadIn - const Duration(milliseconds: 1));
      expect(controller.litPad, isNull);
      while (controller.isPlayingBack) {
        controller.tick(const Duration(milliseconds: 10));
        final pad = controller.litPad;
        if (pad != null && !wasLit) lit.add(pad);
        wasLit = pad != null;
      }
      expect(lit, equals(controller.sequence));
      expect(controller.phase, equals(EchoPhase.input));
    });

    test('the playback ends exactly after its duration and is faster for longer sequences', () {
      final controller = EchoGameController(random: Random(1))..start();
      controller.tick(EchoGameController.playbackDurationFor(1) - const Duration(milliseconds: 1));
      expect(controller.isPlayingBack, isTrue);
      controller.tick(const Duration(milliseconds: 1));
      expect(controller.isAwaitingInput, isTrue);
      expect(controller.isRunning, isFalse);

      expect(EchoGameController.onDurationFor(10), lessThan(EchoGameController.onDurationFor(1)));
      expect(EchoGameController.offDurationFor(10), lessThan(EchoGameController.offDurationFor(1)));
      expect(EchoGameController.onDurationFor(1000), equals(const Duration(milliseconds: 250)));
      expect(EchoGameController.offDurationFor(1000), equals(const Duration(milliseconds: 100)));
    });

    test('input is ignored during the playback', () {
      final controller = EchoGameController(random: Random(42))..start();
      final pad = controller.sequence.first;

      controller
        ..tapPad(pad)
        ..tapPad(wrongPadFor(pad));

      expect(controller.isPlayingBack, isTrue);
      expect(controller.moves, equals(0));
      expect(controller.result, isNull);
    });

    test('repeating the sequence completes a round and adds one pad', () {
      final controller = EchoGameController(random: Random(42))..start();
      playBack(controller);
      final first = controller.sequence;

      repeat(controller);

      expect(controller.rounds, equals(1));
      expect(controller.score, equals(1));
      expect(controller.moves, equals(1));
      expect(controller.sequence, hasLength(2));
      expect(controller.sequence.first, equals(first.first));
      expect(controller.isPlayingBack, isTrue);
      expect(controller.isFinished, isFalse);
    });

    test('a tapped pad flashes for the press duration', () {
      final controller = EchoGameController(random: Random(42))..start();
      playBack(controller);
      repeat(controller);
      playBack(controller);

      final pad = controller.sequence.first;
      controller.tapPad(pad);
      expect(controller.litPad, equals(pad));
      expect(controller.isRunning, isTrue);
      expect(controller.inputIndex, equals(1));

      controller.tick(EchoGameController.pressFlash);
      expect(controller.litPad, isNull);
      expect(controller.isRunning, isFalse);
    });

    test('a wrong pad ends the game with GameOutcome.lost and the rounds as score', () {
      final controller = EchoGameController(random: Random(5))..start();
      GameResult? reported;
      controller.resultListener = (result) => reported = result;
      for (var round = 0; round < 3; round++) {
        playBack(controller);
        repeat(controller);
      }
      playBack(controller);
      final expected = controller.sequence.first;

      controller.tapPad(wrongPadFor(expected));

      expect(controller.isGameOver, isTrue);
      expect(controller.isRunning, isFalse);
      expect(controller.wrongPad, equals(wrongPadFor(expected)));
      expect(controller.expectedPad, equals(expected));
      expect(controller.litPad, isNull);
      final result = controller.result!;
      expect(reported, same(result));
      expect(result.gameId, equals('echo'));
      expect(result.outcome, equals(GameOutcome.lost));
      expect(result.score, equals(3));
      expect(result.moves, equals(1 + 2 + 3 + 1));
      expect(result.data, equals({'rounds': 3, 'sequenceLength': 4}));
    });

    test('a mistake in the middle of the sequence ends the game', () {
      final controller = EchoGameController(random: Random(9))..start();
      for (var round = 0; round < 2; round++) {
        playBack(controller);
        repeat(controller);
      }
      playBack(controller);
      final sequence = controller.sequence;

      controller
        ..tapPad(sequence[0])
        ..tapPad(wrongPadFor(sequence[1]));

      expect(controller.isGameOver, isTrue);
      expect(controller.expectedPad, equals(sequence[1]));
      expect(controller.result!.score, equals(2));
    });

    test('a mistake in the first round scores 0', () {
      final controller = EchoGameController(random: Random(42))..start();
      playBack(controller);

      controller.tapPad(wrongPadFor(controller.sequence.first));

      expect(controller.result!.outcome, equals(GameOutcome.lost));
      expect(controller.result!.score, equals(0));
    });

    test('taps after the game is over are ignored', () {
      final controller = EchoGameController(random: Random(42))..start();
      playBack(controller);
      controller.tapPad(wrongPadFor(controller.sequence.first));
      final result = controller.result;

      controller
        ..tapPad(0)
        ..tick(const Duration(seconds: 1));

      expect(controller.result, same(result));
      expect(controller.moves, equals(1));
      expect(controller.isGameOver, isTrue);
    });

    test('resetGame starts a new session', () {
      final controller = EchoGameController(random: Random(42))..start();
      playBack(controller);
      repeat(controller);
      playBack(controller);
      controller
        ..tapPad(wrongPadFor(controller.sequence.first))
        ..resetGame();

      expect(controller.phase, equals(EchoPhase.ready));
      expect(controller.status, equals(GameStatus.ready));
      expect(controller.sequence, isEmpty);
      expect(controller.score, equals(0));
      expect(controller.moves, equals(0));
      expect(controller.result, isNull);
      expect(controller.wrongPad, isNull);
      expect(controller.expectedPad, isNull);
    });

    test('a long game keeps growing the sequence', () {
      final controller = EchoGameController(random: Random(11))..start();
      for (var round = 0; round < 30; round++) {
        playBack(controller);
        repeat(controller);
      }

      expect(controller.rounds, equals(30));
      expect(controller.sequence, hasLength(31));
      expect(controller.isFinished, isFalse);
    });
  });
}
