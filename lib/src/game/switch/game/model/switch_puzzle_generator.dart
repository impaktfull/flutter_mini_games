import 'dart:math';

import 'package:flutter_mini_games/src/game/switch/game/model/switch_difficulty.dart';
import 'package:flutter_mini_games/src/game/switch/game/model/switch_puzzle.dart';
import 'package:flutter_mini_games/src/game/switch/game/model/switch_solver.dart';

/// Generates Switch puzzles by tapping random distinct cells of a dark board,
/// so every generated puzzle is solvable.
class SwitchPuzzleGenerator {
  final Random _random;
  final int size;

  SwitchPuzzleGenerator({
    Random? random,
    this.size = SwitchPuzzle.defaultSize,
  }) : _random = random ?? Random();

  SwitchPuzzle generate(SwitchDifficulty difficulty) {
    final solver = SwitchSolver(size: size);
    final cells = size * size;
    final taps = min(difficulty.taps, cells);
    while (true) {
      final indices = List.generate(cells, (i) => i)..shuffle(_random);
      var lights = 0;
      for (final index in indices.take(taps)) {
        lights ^= solver.toggleMask(index);
      }
      // Some tap sets cancel each other out (a "quiet" pattern): try again
      if (lights != 0) return SwitchPuzzle.fromMask(lights, size: size);
    }
  }
}
