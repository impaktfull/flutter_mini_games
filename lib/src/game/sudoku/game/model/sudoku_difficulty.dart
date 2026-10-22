/// Difficulty levels for Sudoku puzzles, based on the number of givens
enum SudokuDifficulty {
  /// 40 givens
  easy('Easy', 40, 1000),

  /// 32 givens
  medium('Medium', 32, 1500),

  /// 28 givens
  hard('Hard', 28, 2000),

  /// As few givens as possible (target 24) while the solution stays unique
  expert('Expert', 24, 2500);

  final String label;

  /// Target number of givens. The generator never removes a given when the solution
  /// would stop being unique, so a puzzle can have a few more givens than this target.
  final int givens;

  /// Score of a puzzle solved instantly without mistakes, see `SudokuGameController.calculateScore`
  final int basePoints;

  const SudokuDifficulty(this.label, this.givens, this.basePoints);

  /// Estimates the difficulty of a (custom) puzzle from its number of givens
  static SudokuDifficulty fromGivens(int givens) {
    if (givens >= easy.givens) return easy;
    if (givens >= medium.givens) return medium;
    if (givens >= hard.givens) return hard;
    return expert;
  }
}
