import 'dart:math';

import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';
import 'package:flutter_mini_games/src/game/switch/game/model/switch_difficulty.dart';
import 'package:flutter_mini_games/src/game/switch/game/model/switch_puzzle.dart';
import 'package:flutter_mini_games/src/game/switch/game/model/switch_puzzle_generator.dart';
import 'package:flutter_mini_games/src/game/switch/game/model/switch_solver.dart';

/// Lights Out: tapping a light toggles it and its 4 neighbours, turn every light off.
class SwitchGameController extends GameController {
  static const id = 'switch_lights';

  /// Score of a solve at par within the first second
  static const maxScore = 1000;

  /// Lowest score of a solved puzzle
  static const minScore = 100;

  /// Points lost per move above par
  static const pointsPerExtraMove = 50;

  final List<SwitchPuzzle>? _puzzles;
  final SwitchPuzzleGenerator _generator;
  SwitchDifficulty _difficulty;
  int _puzzleIndex = 0;
  late SwitchPuzzle _puzzle;
  late SwitchSolver _solver;
  int _lights = 0;
  int? _hint;
  int _hints = 0;

  /// Plays the [puzzles] in order (and starts over after the last one), or generates
  /// puzzles of the [difficulty] when there are none.
  SwitchGameController({
    SwitchDifficulty difficulty = SwitchDifficulty.medium,
    List<SwitchPuzzle>? puzzles,
    Random? random,
  }) : _difficulty = difficulty,
       _puzzles = puzzles == null || puzzles.isEmpty ? null : List.unmodifiable(puzzles),
       _generator = SwitchPuzzleGenerator(random: random),
       super(gameId: id) {
    _loadPuzzle(_puzzles?.first ?? _generator.generate(_difficulty));
  }

  SwitchDifficulty get difficulty => _difficulty;

  /// Whether the puzzles come from a custom list instead of the generator
  bool get hasCustomPuzzles => _puzzles != null;
  SwitchPuzzle get puzzle => _puzzle;
  int get size => _puzzle.size;
  int get par => _puzzle.par;

  /// Bitmask of the lights that are on (bit `row * size + col`)
  int get lights => _lights;
  int get litCount => SwitchSolver.bitCount(_lights);

  /// Number of hints shown for this puzzle
  int get hints => _hints;

  /// Cell of the current hint, null when no hint is shown
  (int row, int col)? get hint {
    final hint = _hint;
    return hint == null ? null : (hint ~/ size, hint % size);
  }

  bool get isWon => result?.outcome == GameOutcome.won;

  bool isLit(int row, int col) => _lights & (1 << _index(row, col)) != 0;

  bool isHint(int row, int col) => _hint == _index(row, col);

  /// `max(100, 1000 - (moves - par) * 50 - seconds)`
  static int calculateScore({required int moves, required int par, required Duration elapsed}) {
    return max(minScore, maxScore - (moves - par) * pointsPerExtraMove - elapsed.inSeconds);
  }

  /// Toggles the light at ([row], [col]) and its 4 neighbours
  void tap(int row, int col) {
    if (isFinished) return;
    final index = _index(row, col);
    registerMove();
    _lights ^= _solver.toggleMask(index);
    _hint = null;
    if (_lights == 0) {
      finish(
        GameOutcome.won,
        score: calculateScore(moves: moves, par: par, elapsed: elapsed),
        data: {
          'difficulty': hasCustomPuzzles ? null : _difficulty.name,
          'par': par,
          'hints': _hints,
        },
      );
    }
    notifyListeners();
  }

  /// Highlights one tap of the shortest solution from the current board
  void showHint() {
    if (isFinished) return;
    final solution = _solver.minimalSolution(_lights);
    if (solution == null || solution == 0) return;
    final next = _lowestBit(solution);
    if (_hint == next) return;
    _hint = next;
    _hints++;
    notifyListeners();
  }

  /// Starts the same puzzle again
  void resetGame() {
    _loadPuzzle(_puzzle);
    notifyListeners();
  }

  /// The next puzzle of the list, or a new generated one
  void nextPuzzle() {
    final puzzles = _puzzles;
    if (puzzles != null) {
      _puzzleIndex = (_puzzleIndex + 1) % puzzles.length;
      _loadPuzzle(puzzles[_puzzleIndex]);
    } else {
      _loadPuzzle(_generator.generate(_difficulty));
    }
    notifyListeners();
  }

  /// Switches to generated puzzles of [difficulty] and starts a new one
  void newGame({required SwitchDifficulty difficulty}) {
    _difficulty = difficulty;
    _loadPuzzle(_generator.generate(_difficulty));
    notifyListeners();
  }

  void _loadPuzzle(SwitchPuzzle puzzle) {
    _puzzle = puzzle;
    _solver = SwitchSolver(size: puzzle.size);
    _lights = puzzle.lights;
    _hint = null;
    _hints = 0;
    restartSession();
  }

  int _index(int row, int col) {
    RangeError.checkValueInInterval(row, 0, size - 1, 'row');
    RangeError.checkValueInInterval(col, 0, size - 1, 'col');
    return row * size + col;
  }

  static int _lowestBit(int mask) {
    var index = 0;
    while (mask & (1 << index) == 0) {
      index++;
    }
    return index;
  }
}
