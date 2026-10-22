import 'package:flutter_mini_games/src/game/sudoku/game/model/sudoku_difficulty.dart';
import 'package:flutter_mini_games/src/game/sudoku/game/model/sudoku_solver.dart';

/// A 9x9 Sudoku puzzle with its solution.
///
/// Cells are stored in row-major order (index = row * 9 + col), `0` is an empty cell.
class SudokuPuzzle {
  /// The 81 starting cells, `0` = empty
  final List<int> givens;

  /// The 81 cells of the (unique) solution
  final List<int> solution;

  /// Optional name for the puzzle
  final String? name;

  /// Difficulty level (optional, estimated from the number of givens when not set)
  final SudokuDifficulty? difficulty;

  const SudokuPuzzle({
    required this.givens,
    required this.solution,
    this.name,
    this.difficulty,
  });

  /// Creates a puzzle from 81 characters (row by row): `1`-`9` for a given, `0` or `.` for an empty cell.
  /// Whitespace is ignored. The solution is calculated.
  ///
  /// Throws an [ArgumentError] when the puzzle does not have exactly one solution.
  factory SudokuPuzzle.fromString(
    String givens, {
    String? name,
    SudokuDifficulty? difficulty,
  }) {
    final cells = [
      for (final char in givens.replaceAll(RegExp(r'\s'), '').split('')) char == '.' ? 0 : int.tryParse(char) ?? -1,
    ];
    if (cells.length != SudokuSolver.cellCount || cells.any((value) => value < 0 || value > 9)) {
      throw ArgumentError.value(givens, 'givens', 'Expected 81 characters 0-9 or .');
    }
    if (!SudokuSolver.hasUniqueSolution(cells)) {
      throw ArgumentError.value(givens, 'givens', 'The puzzle must have exactly one solution');
    }
    return SudokuPuzzle(
      givens: cells,
      solution: SudokuSolver.solve(cells)!,
      name: name,
      difficulty: difficulty,
    );
  }

  int get givenCount => givens.where((value) => value != 0).length;

  /// [difficulty], or an estimate based on the number of givens
  SudokuDifficulty get effectiveDifficulty => difficulty ?? SudokuDifficulty.fromGivens(givenCount);

  int givenAt(int row, int col) => givens[row * 9 + col];

  int solutionAt(int row, int col) => solution[row * 9 + col];

  /// True when the solution is a correctly filled grid, the givens match it
  /// and the givens have exactly one solution
  bool isValid() {
    if (givens.length != SudokuSolver.cellCount || solution.length != SudokuSolver.cellCount) return false;
    if (!SudokuSolver.isSolved(solution)) return false;
    for (var i = 0; i < SudokuSolver.cellCount; i++) {
      if (givens[i] != 0 && givens[i] != solution[i]) return false;
    }
    return SudokuSolver.hasUniqueSolution(givens);
  }
}
