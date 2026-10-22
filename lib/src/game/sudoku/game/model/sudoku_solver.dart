import 'dart:math';

/// Backtracking Sudoku solver.
///
/// A grid is a list of 81 cells in row-major order, `0` is an empty cell.
/// Uses bitmasks per row, column and box and always fills the cell with the fewest
/// candidates first, which keeps counting solutions fast enough for the generator.
class SudokuSolver {
  const SudokuSolver._();

  static const size = 9;
  static const cellCount = size * size;

  /// Number of solutions of [cells], counting stops at [limit].
  /// Returns 0 when the grid is invalid (wrong length, values out of range or conflicting givens).
  static int countSolutions(List<int> cells, {int limit = 2}) {
    final search = _Search.create(cells, limit: limit);
    if (search == null) return 0;
    search.run();
    return search.count;
  }

  /// True when [cells] has exactly one solution
  static bool hasUniqueSolution(List<int> cells) => countSolutions(cells) == 1;

  /// A solution of [cells], or null when it has none.
  /// With a [random], candidates are tried in random order: solving an empty grid
  /// then produces a random complete grid.
  static List<int>? solve(List<int> cells, {Random? random}) {
    final search = _Search.create(cells, limit: 1, random: random);
    if (search == null) return null;
    search.run();
    return search.firstSolution;
  }

  /// True when no row, column or box contains the same digit twice (empty cells allowed)
  static bool hasNoConflicts(List<int> cells) => _Search.create(cells, limit: 1) != null;

  /// True when [cells] is completely and correctly filled
  static bool isSolved(List<int> cells) => !cells.contains(0) && hasNoConflicts(cells);

  static int boxOf(int row, int col) => (row ~/ 3) * 3 + col ~/ 3;
}

class _Search {
  static const _allDigits = 0x3FE; // bits 1..9

  final List<int> cells;
  final int limit;
  final Random? random;
  final List<int> rows = List.filled(SudokuSolver.size, 0);
  final List<int> cols = List.filled(SudokuSolver.size, 0);
  final List<int> boxes = List.filled(SudokuSolver.size, 0);
  int count = 0;
  List<int>? firstSolution;

  _Search._(this.cells, this.limit, this.random);

  /// Null when the grid is invalid
  static _Search? create(List<int> cells, {required int limit, Random? random}) {
    if (cells.length != SudokuSolver.cellCount) return null;
    final search = _Search._(List.of(cells), limit, random);
    for (var i = 0; i < SudokuSolver.cellCount; i++) {
      final value = cells[i];
      if (value == 0) continue;
      if (value < 1 || value > 9) return null;
      final bit = 1 << value;
      final row = i ~/ 9;
      final col = i % 9;
      final box = SudokuSolver.boxOf(row, col);
      if ((search.rows[row] | search.cols[col] | search.boxes[box]) & bit != 0) return null;
      search.rows[row] |= bit;
      search.cols[col] |= bit;
      search.boxes[box] |= bit;
    }
    return search;
  }

  void run() {
    if (count >= limit) return;

    // Pick the empty cell with the fewest candidates
    var best = -1;
    var bestMask = 0;
    var bestCount = 10;
    for (var i = 0; i < SudokuSolver.cellCount; i++) {
      if (cells[i] != 0) continue;
      final row = i ~/ 9;
      final col = i % 9;
      final mask = ~(rows[row] | cols[col] | boxes[SudokuSolver.boxOf(row, col)]) & _allDigits;
      final candidates = _bitCount(mask);
      if (candidates == 0) return; // Dead end
      if (candidates < bestCount) {
        best = i;
        bestMask = mask;
        bestCount = candidates;
        if (candidates == 1) break;
      }
    }

    if (best == -1) {
      count++;
      firstSolution ??= List.of(cells);
      return;
    }

    final digits = [
      for (var digit = 1; digit <= 9; digit++)
        if (bestMask & (1 << digit) != 0) digit,
    ];
    if (random != null) digits.shuffle(random);

    final row = best ~/ 9;
    final col = best % 9;
    final box = SudokuSolver.boxOf(row, col);
    for (final digit in digits) {
      final bit = 1 << digit;
      cells[best] = digit;
      rows[row] |= bit;
      cols[col] |= bit;
      boxes[box] |= bit;
      run();
      cells[best] = 0;
      rows[row] &= ~bit;
      cols[col] &= ~bit;
      boxes[box] &= ~bit;
      if (count >= limit) return;
    }
  }

  static int _bitCount(int mask) {
    var count = 0;
    var value = mask;
    while (value != 0) {
      value &= value - 1;
      count++;
    }
    return count;
  }
}
