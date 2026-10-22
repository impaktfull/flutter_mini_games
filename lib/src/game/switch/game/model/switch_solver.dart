/// Solves Lights Out boards with linear algebra over GF(2).
///
/// A board is a bitmask: bit `row * size + col` is set when that light is on. Tapping a cell
/// toggles it and its 4 neighbours, so a solution is a set of taps (also a bitmask) whose
/// toggles add up (xor) to the lit cells. Every cell has to be tapped at most once and the
/// order of the taps does not matter.
class SwitchSolver {
  /// Largest supported board: the bitmasks (plus one bit for the elimination) must stay
  /// within 32 bits, the bitwise limit on the web
  static const maxSize = 5;

  final int size;

  const SwitchSolver({this.size = 5}) : assert(size > 0 && size <= maxSize);

  int get cells => size * size;

  /// Bitmask of the cells toggled by tapping [index]: the cell and its 4 neighbours
  int toggleMask(int index) {
    final row = index ~/ size;
    final col = index % size;
    var mask = 1 << index;
    if (row > 0) mask |= 1 << (index - size);
    if (row < size - 1) mask |= 1 << (index + size);
    if (col > 0) mask |= 1 << (index - 1);
    if (col < size - 1) mask |= 1 << (index + 1);
    return mask;
  }

  /// Applies all taps in [taps] to [lights]
  int applyTaps(int lights, int taps) {
    var result = lights;
    for (var i = 0; i < cells; i++) {
      if (taps & (1 << i) != 0) result ^= toggleMask(i);
    }
    return result;
  }

  /// Every set of taps that turns all [lights] off, empty when the board is not solvable.
  ///
  /// A 5x5 board has 4 solutions for every solvable board (2 free variables).
  List<int> solutions(int lights) {
    final n = cells;
    final rhsBit = 1 << n;
    // Row i: which taps toggle cell i (the matrix is symmetric) + whether cell i is lit
    final rows = [
      for (var i = 0; i < n; i++) toggleMask(i) | (lights & (1 << i) != 0 ? rhsBit : 0),
    ];
    final pivotCols = <int>[];
    var rank = 0;
    for (var col = 0; col < n && rank < n; col++) {
      final bit = 1 << col;
      var pivot = -1;
      for (var r = rank; r < n; r++) {
        if (rows[r] & bit != 0) {
          pivot = r;
          break;
        }
      }
      if (pivot == -1) continue;
      final swap = rows[rank];
      rows[rank] = rows[pivot];
      rows[pivot] = swap;
      for (var r = 0; r < n; r++) {
        if (r != rank && rows[r] & bit != 0) rows[r] ^= rows[rank];
      }
      pivotCols.add(col);
      rank++;
    }
    // A row without taps that still needs a toggle: not solvable
    for (var r = rank; r < n; r++) {
      if (rows[r] & rhsBit != 0) return const [];
    }

    final freeCols = [
      for (var col = 0; col < n; col++)
        if (!pivotCols.contains(col)) col,
    ];
    final result = <int>[];
    for (var assignment = 0; assignment < 1 << freeCols.length; assignment++) {
      var taps = 0;
      for (var f = 0; f < freeCols.length; f++) {
        if (assignment & (1 << f) != 0) taps |= 1 << freeCols[f];
      }
      for (var r = 0; r < rank; r++) {
        var value = rows[r] & rhsBit != 0;
        for (final free in freeCols) {
          if (rows[r] & (1 << free) != 0 && taps & (1 << free) != 0) value = !value;
        }
        if (value) taps |= 1 << pivotCols[r];
      }
      result.add(taps);
    }
    return result;
  }

  bool isSolvable(int lights) => solutions(lights).isNotEmpty;

  /// The solution with the fewest taps (the lowest bitmask on a tie), null when not solvable
  int? minimalSolution(int lights) {
    int? best;
    for (final taps in solutions(lights)) {
      if (best == null) {
        best = taps;
        continue;
      }
      final count = bitCount(taps);
      final bestCount = bitCount(best);
      if (count < bestCount || (count == bestCount && taps < best)) best = taps;
    }
    return best;
  }

  /// Minimal number of taps to turn all [lights] off, null when not solvable
  int? minimalMoves(int lights) {
    final solution = minimalSolution(lights);
    return solution == null ? null : bitCount(solution);
  }

  static int bitCount(int mask) {
    var count = 0;
    var value = mask;
    while (value != 0) {
      value &= value - 1;
      count++;
    }
    return count;
  }
}
