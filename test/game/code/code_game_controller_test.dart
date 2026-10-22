import 'dart:math';

import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';
import 'package:flutter_mini_games/src/game/code/game/logic/code_game_controller.dart';
import 'package:flutter_mini_games/src/game/code/game/model/code_feedback.dart';
import 'package:flutter_mini_games/src/game/code/game/model/code_peg.dart';
import 'package:flutter_test/flutter_test.dart';

const a = CodePeg.circle;
const b = CodePeg.square;
const c = CodePeg.triangle;
const d = CodePeg.diamond;
const e = CodePeg.star;
const f = CodePeg.hexagon;

void main() {
  void guess(CodeGameController controller, List<CodePeg> pegs) {
    for (final peg in pegs) {
      controller.addPeg(peg);
    }
    controller.submit();
  }

  group('code', () {
    test('random codes have 4 pegs and are reproducible with a seed', () {
      final first = CodeGameController(random: Random(42)).secret;
      final second = CodeGameController(random: Random(42)).secret;
      expect(first, hasLength(CodeGameController.codeLength));
      expect(first, equals(second));
    });

    test('random codes use all symbols and allow repeats', () {
      final random = Random(7);
      final seen = <CodePeg>{};
      var hasRepeat = false;
      for (var i = 0; i < 200; i++) {
        final secret = CodeGameController(random: random).secret;
        seen.addAll(secret);
        if (secret.toSet().length < secret.length) hasRepeat = true;
      }
      expect(seen, equals(CodePeg.values.toSet()));
      expect(hasRepeat, isTrue);
    });

    test('rejects a fixed code of the wrong length', () {
      expect(() => CodeGameController(secret: [a, b]), throwsArgumentError);
    });
  });

  group('building a guess', () {
    test('fills the next empty slot and ignores pegs when full', () {
      final controller = CodeGameController(secret: [a, b, c, d]);
      controller
        ..addPeg(e)
        ..addPeg(f);
      expect(controller.currentGuess, equals([e, f, null, null]));

      controller
        ..addPeg(a)
        ..addPeg(b)
        ..addPeg(c);
      expect(controller.currentGuess, equals([e, f, a, b]));
      expect(controller.isCurrentGuessComplete, isTrue);
    });

    test('a cleared slot is filled first', () {
      final controller = CodeGameController(secret: [a, b, c, d]);
      for (final peg in [a, b, c, d]) {
        controller.addPeg(peg);
      }
      controller.clearSlot(1);
      expect(controller.currentGuess, equals([a, null, c, d]));
      expect(controller.canSubmit, isFalse);

      controller.addPeg(f);
      expect(controller.currentGuess, equals([a, f, c, d]));
    });

    test('clearGuess empties all slots', () {
      final controller = CodeGameController(secret: [a, b, c, d])
        ..addPeg(a)
        ..addPeg(b)
        ..clearGuess();
      expect(controller.isCurrentGuessEmpty, isTrue);
    });

    test('the first peg starts the timer, a submitted guess is a move', () {
      final controller = CodeGameController(secret: [a, b, c, d]);
      expect(controller.status, GameStatus.ready);

      controller.addPeg(a);
      expect(controller.status, GameStatus.playing);
      expect(controller.moves, equals(0));

      controller
        ..addPeg(a)
        ..addPeg(a)
        ..addPeg(a)
        ..submit();
      expect(controller.moves, equals(1));
    });

    test('an incomplete guess cannot be submitted', () {
      final controller = CodeGameController(secret: [a, b, c, d])
        ..addPeg(a)
        ..submit();
      expect(controller.guesses, isEmpty);
      expect(controller.currentGuess, equals([a, null, null, null]));
    });
  });

  group('playing', () {
    test('records each guess with its feedback and empties the current guess', () {
      final controller = CodeGameController(secret: [a, a, b, c]);
      guess(controller, [a, b, a, d]);

      expect(controller.guesses, hasLength(1));
      expect(controller.guesses.single.pegs, equals([a, b, a, d]));
      expect(controller.guesses.single.feedback, equals(const CodeFeedback(exact: 1, misplaced: 2)));
      expect(controller.isCurrentGuessEmpty, isTrue);
      expect(controller.triesLeft, equals(CodeGameController.maxTries - 1));
      expect(controller.isFinished, isFalse);
    });

    test('cracking the code wins with (9 - tries) * 100', () {
      final controller = CodeGameController(secret: [d, e, f, a]);
      final results = <GameResult>[];
      controller.resultListener = results.add;

      guess(controller, [a, b, c, d]);
      guess(controller, [d, e, f, b]);
      guess(controller, [d, e, f, a]);

      expect(controller.isWon, isTrue);
      expect(results, hasLength(1));
      final result = results.single;
      expect(result.gameId, equals('code'));
      expect(result.outcome, GameOutcome.won);
      expect(result.score, equals(600));
      expect(result.moves, equals(3));
      expect(result.data, equals({'tries': 3}));
    });

    test('score per number of tries', () {
      expect(CodeGameController.calculateScore(1), equals(800));
      expect(CodeGameController.calculateScore(4), equals(500));
      expect(CodeGameController.calculateScore(8), equals(100));
    });

    test('cracking it on the first and on the last try', () {
      final first = CodeGameController(secret: [b, b, b, b]);
      guess(first, [b, b, b, b]);
      expect(first.result?.score, equals(800));

      final last = CodeGameController(secret: [b, b, b, b]);
      for (var i = 0; i < CodeGameController.maxTries - 1; i++) {
        guess(last, [a, a, a, a]);
      }
      expect(last.isFinished, isFalse);
      guess(last, [b, b, b, b]);
      expect(last.result?.outcome, GameOutcome.won);
      expect(last.result?.score, equals(100));
    });

    test('8 wrong guesses lose without a score', () {
      final controller = CodeGameController(secret: [a, b, c, d]);
      final results = <GameResult>[];
      controller.resultListener = results.add;

      for (var i = 0; i < CodeGameController.maxTries; i++) {
        guess(controller, [e, e, f, f]);
      }

      expect(controller.isLost, isTrue);
      expect(controller.triesLeft, equals(0));
      expect(results.single.outcome, GameOutcome.lost);
      expect(results.single.score, isNull);
      expect(results.single.moves, equals(8));
      expect(results.single.data, equals({'tries': 8}));
    });

    test('ignores input after the game is finished', () {
      final controller = CodeGameController(secret: [a, b, c, d]);
      guess(controller, [a, b, c, d]);

      controller
        ..addPeg(a)
        ..clearGuess()
        ..submit();
      expect(controller.isCurrentGuessEmpty, isTrue);
      expect(controller.guesses, hasLength(1));
      expect(controller.moves, equals(1));
    });

    test('resetGame starts a new session with a new code', () {
      final controller = CodeGameController(random: Random(42), secret: [a, b, c, d]);
      guess(controller, [a, b, c, d]);
      controller.resetGame();

      expect(controller.status, GameStatus.ready);
      expect(controller.result, isNull);
      expect(controller.guesses, isEmpty);
      expect(controller.moves, equals(0));
      expect(controller.secret, hasLength(4));
      expect(controller.secret, equals(CodeGameController(random: Random(42)).secret));
    });

    test('leaving while playing is abandoned', () {
      final controller = CodeGameController(secret: [a, b, c, d]);
      final results = <GameResult>[];
      controller.resultListener = results.add;
      guess(controller, [a, a, a, a]);
      controller.dispose();
      expect(results.single.outcome, GameOutcome.abandoned);
    });
  });
}
