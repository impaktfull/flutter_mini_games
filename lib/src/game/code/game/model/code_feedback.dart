import 'dart:math';

import 'package:flutter_mini_games/src/game/code/game/model/code_peg.dart';

/// Feedback on one guess: how many pegs are right, and how many are the right symbol in the wrong place.
class CodeFeedback {
  /// Right symbol in the right place
  final int exact;

  /// Right symbol in the wrong place
  final int misplaced;

  const CodeFeedback({
    required this.exact,
    required this.misplaced,
  });

  /// Compares [guess] with [secret] (same length, repeats allowed).
  ///
  /// Every peg counts at most once: a symbol scores `min(count in secret, count in guess)` markers
  /// in total, of which the ones in the right place are [exact] and the rest [misplaced].
  factory CodeFeedback.evaluate(List<CodePeg> secret, List<CodePeg> guess) {
    if (secret.length != guess.length) {
      throw ArgumentError('The guess has ${guess.length} pegs, the code has ${secret.length}');
    }
    var exact = 0;
    final secretCounts = <CodePeg, int>{};
    final guessCounts = <CodePeg, int>{};
    for (var i = 0; i < secret.length; i++) {
      if (secret[i] == guess[i]) {
        exact++;
      } else {
        secretCounts[secret[i]] = (secretCounts[secret[i]] ?? 0) + 1;
        guessCounts[guess[i]] = (guessCounts[guess[i]] ?? 0) + 1;
      }
    }
    var misplaced = 0;
    guessCounts.forEach((peg, count) => misplaced += min(count, secretCounts[peg] ?? 0));
    return CodeFeedback(exact: exact, misplaced: misplaced);
  }

  bool isSolved(int codeLength) => exact == codeLength;

  @override
  bool operator ==(Object other) => other is CodeFeedback && other.exact == exact && other.misplaced == misplaced;

  @override
  int get hashCode => Object.hash(exact, misplaced);

  @override
  String toString() => 'CodeFeedback(exact: $exact, misplaced: $misplaced)';
}
