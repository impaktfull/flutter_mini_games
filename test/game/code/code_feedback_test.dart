import 'dart:math';

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
  void expectFeedback(List<CodePeg> secret, List<CodePeg> guess, int exact, int misplaced) {
    expect(
      CodeFeedback.evaluate(secret, guess),
      equals(CodeFeedback(exact: exact, misplaced: misplaced)),
      reason: 'secret $secret, guess $guess',
    );
  }

  group('without repeats', () {
    test('all exact', () => expectFeedback([a, b, c, d], [a, b, c, d], 4, 0));
    test('nothing in common', () => expectFeedback([a, b, c, d], [e, f, e, f], 0, 0));
    test('all misplaced', () => expectFeedback([a, b, c, d], [d, c, b, a], 0, 4));
    test('mixed', () => expectFeedback([a, b, c, d], [a, c, e, b], 1, 2));
    test('two swapped', () => expectFeedback([a, b, c, d], [b, a, c, d], 2, 2));
  });

  group('with repeats (min-count rule)', () {
    test('a repeated guess symbol counts once for a single secret symbol', () {
      expectFeedback([a, b, c, d], [a, a, a, a], 1, 0);
      expectFeedback([a, b, c, d], [b, b, e, e], 1, 0);
      expectFeedback([a, b, c, d], [e, a, a, e], 0, 1);
    });

    test('a repeated secret symbol counts once for a single guess symbol', () {
      expectFeedback([a, a, b, b], [a, c, d, e], 1, 0);
      expectFeedback([a, a, b, b], [c, d, a, e], 0, 1);
    });

    test('exact hits are taken before misplaced ones', () {
      // The first a is exact, the second a in the guess has no a left in the secret
      expectFeedback([a, b, c, d], [a, a, e, e], 1, 0);
      // The secret's a at 2 is exact, the guess's a at 0 matches the secret's a at 3
      expectFeedback([b, c, a, a], [a, d, a, e], 1, 1);
    });

    test('repeats on both sides', () {
      expectFeedback([a, a, b, b], [b, b, a, a], 0, 4);
      expectFeedback([a, a, b, b], [a, b, a, b], 2, 2);
      expectFeedback([a, a, a, b], [a, a, b, b], 3, 0);
      expectFeedback([a, a, a, b], [b, a, a, a], 2, 2);
      expectFeedback([a, a, b, c], [c, c, a, a], 0, 3);
    });

    test('all the same symbol', () {
      expectFeedback([a, a, a, a], [a, a, a, a], 4, 0);
      expectFeedback([a, a, a, a], [a, b, b, b], 1, 0);
      expectFeedback([a, a, a, a], [b, b, b, b], 0, 0);
    });

    test('classic examples', () {
      expectFeedback([c, c, a, b], [c, a, c, d], 1, 2);
      expectFeedback([f, e, f, e], [e, f, e, f], 0, 4);
      expectFeedback([d, d, e, f], [d, e, d, d], 1, 2);
    });
  });

  test('matches a brute-force reference for random codes', () {
    final random = Random(42);
    List<CodePeg> code() => [for (var i = 0; i < 4; i++) CodePeg.values[random.nextInt(CodePeg.values.length)]];

    for (var round = 0; round < 2000; round++) {
      final secret = code();
      final guess = code();
      final feedback = CodeFeedback.evaluate(secret, guess);

      // Reference: mark exact hits, then pair every other guess peg with an unused secret peg
      final usedSecret = List.filled(4, false);
      final usedGuess = List.filled(4, false);
      var exact = 0;
      for (var i = 0; i < 4; i++) {
        if (secret[i] == guess[i]) {
          exact++;
          usedSecret[i] = usedGuess[i] = true;
        }
      }
      var misplaced = 0;
      for (var i = 0; i < 4; i++) {
        if (usedGuess[i]) continue;
        for (var j = 0; j < 4; j++) {
          if (!usedSecret[j] && secret[j] == guess[i]) {
            usedSecret[j] = true;
            misplaced++;
            break;
          }
        }
      }

      expect(
        feedback,
        equals(CodeFeedback(exact: exact, misplaced: misplaced)),
        reason: 'secret $secret, guess $guess',
      );
      expect(feedback.exact + feedback.misplaced, lessThanOrEqualTo(4));
    }
  });

  test('is symmetric in secret and guess', () {
    expect(CodeFeedback.evaluate([a, a, b, c], [c, a, d, a]), equals(CodeFeedback.evaluate([c, a, d, a], [a, a, b, c])));
  });

  test('rejects guesses of a different length', () {
    expect(() => CodeFeedback.evaluate([a, b, c, d], [a, b, c]), throwsArgumentError);
  });

  test('isSolved only with all pegs exact', () {
    expect(const CodeFeedback(exact: 4, misplaced: 0).isSolved(4), isTrue);
    expect(const CodeFeedback(exact: 3, misplaced: 0).isSolved(4), isFalse);
  });
}
