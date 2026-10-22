import 'dart:math';

import 'package:flutter_mini_games/src/game/sudoku/game/model/sudoku_difficulty.dart';
import 'package:flutter_mini_games/src/game/sudoku/game/model/sudoku_puzzle.dart';
import 'package:flutter_mini_games/src/game/sudoku/game/model/sudoku_solver.dart';

/// Generates random Sudoku puzzles that have exactly one solution
class SudokuPuzzleGenerator {
  final Random _random;

  SudokuPuzzleGenerator({Random? random}) : _random = random ?? Random();

  /// 1. Fills an empty grid with a random complete solution (randomised backtracking)
  /// 2. Removes givens in random order, but only when the solution stays unique,
  ///    until [SudokuDifficulty.givens] is reached or no given can be removed anymore
  SudokuPuzzle generate({
    SudokuDifficulty difficulty = SudokuDifficulty.medium,
    String? name,
  }) {
    final solution = SudokuSolver.solve(List.filled(SudokuSolver.cellCount, 0), random: _random)!;
    final givens = List.of(solution);
    final order = List.generate(SudokuSolver.cellCount, (index) => index)..shuffle(_random);

    var remaining = SudokuSolver.cellCount;
    for (final index in order) {
      if (remaining <= difficulty.givens) break;
      final value = givens[index];
      givens[index] = 0;
      if (SudokuSolver.hasUniqueSolution(givens)) {
        remaining--;
      } else {
        // Removing more givens only adds solutions, so this cell stays a given
        givens[index] = value;
      }
    }

    return SudokuPuzzle(
      givens: List.unmodifiable(givens),
      solution: List.unmodifiable(solution),
      name: name ?? difficulty.label,
      difficulty: difficulty,
    );
  }
}
