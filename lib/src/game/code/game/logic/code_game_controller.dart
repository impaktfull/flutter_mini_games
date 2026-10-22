import 'dart:math';

import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';
import 'package:flutter_mini_games/src/game/code/game/model/code_feedback.dart';
import 'package:flutter_mini_games/src/game/code/game/model/code_guess.dart';
import 'package:flutter_mini_games/src/game/code/game/model/code_peg.dart';

/// Crack a hidden code of [codeLength] pegs (6 symbols, repeats allowed) in [maxTries] guesses.
class CodeGameController extends GameController {
  static const id = 'code';

  /// Number of pegs in the code
  static const codeLength = 4;

  /// Number of guesses before the game is lost
  static const maxTries = 8;

  final Random _random;
  List<CodePeg> _secret;
  final List<CodeGuess> _guesses = [];
  final List<CodePeg?> _current = List.filled(codeLength, null);

  /// [secret] fixes the first code (for tests), otherwise it is random
  CodeGameController({
    Random? random,
    List<CodePeg>? secret,
  }) : _random = random ?? Random(),
       _secret = const [],
       super(gameId: id) {
    if (secret != null && secret.length != codeLength) {
      throw ArgumentError('A code has $codeLength pegs, got ${secret.length}');
    }
    _secret = secret != null ? List.unmodifiable(secret) : _randomCode();
  }

  /// The hidden code. Only shown to the player when the game is finished.
  List<CodePeg> get secret => _secret;

  /// Submitted guesses with their feedback, oldest first
  List<CodeGuess> get guesses => List.unmodifiable(_guesses);

  /// The guess being built, null for an empty slot
  List<CodePeg?> get currentGuess => List.unmodifiable(_current);

  int get triesUsed => _guesses.length;
  int get triesLeft => maxTries - _guesses.length;
  bool get isCurrentGuessComplete => _current.every((peg) => peg != null);
  bool get isCurrentGuessEmpty => _current.every((peg) => peg == null);
  bool get canSubmit => !isFinished && isCurrentGuessComplete;
  bool get isWon => result?.outcome == GameOutcome.won;
  bool get isLost => result?.outcome == GameOutcome.lost;

  /// Score of a cracked code: `(9 - tries) * 100`, 800 for the first try down to 100 for the last
  static int calculateScore(int tries) => (maxTries + 1 - tries) * 100;

  List<CodePeg> _randomCode() => List.unmodifiable([
    for (var i = 0; i < codeLength; i++) CodePeg.values[_random.nextInt(CodePeg.values.length)],
  ]);

  /// Puts [peg] in the first empty slot of the current guess
  void addPeg(CodePeg peg) {
    if (isFinished) return;
    final index = _current.indexOf(null);
    if (index == -1) return;
    _current[index] = peg;
    // The timer starts with the first peg, a submitted guess counts as a move
    startSession();
    notifyListeners();
  }

  /// Empties one slot of the current guess
  void clearSlot(int index) {
    if (isFinished || _current[index] == null) return;
    _current[index] = null;
    notifyListeners();
  }

  /// Empties the current guess
  void clearGuess() {
    if (isFinished || isCurrentGuessEmpty) return;
    _current.fillRange(0, codeLength, null);
    notifyListeners();
  }

  /// Submits the current guess when all slots are filled
  void submit() {
    if (!canSubmit) return;
    final pegs = List<CodePeg>.unmodifiable(_current.cast<CodePeg>());
    final feedback = CodeFeedback.evaluate(_secret, pegs);
    _guesses.add(CodeGuess(pegs: pegs, feedback: feedback));
    _current.fillRange(0, codeLength, null);
    registerMove();
    if (feedback.isSolved(codeLength)) {
      finish(GameOutcome.won, score: calculateScore(triesUsed), data: {'tries': triesUsed});
    } else if (triesLeft == 0) {
      finish(GameOutcome.lost, data: {'tries': triesUsed});
    }
    notifyListeners();
  }

  /// Starts over with a new random code
  void resetGame() {
    _secret = _randomCode();
    _guesses.clear();
    _current.fillRange(0, codeLength, null);
    restartSession();
    notifyListeners();
  }
}
