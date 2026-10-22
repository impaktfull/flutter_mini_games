import 'package:flutter_mini_games/src/game/code/game/model/code_feedback.dart';
import 'package:flutter_mini_games/src/game/code/game/model/code_peg.dart';

/// A submitted guess with its feedback
class CodeGuess {
  final List<CodePeg> pegs;
  final CodeFeedback feedback;

  const CodeGuess({
    required this.pegs,
    required this.feedback,
  });
}
