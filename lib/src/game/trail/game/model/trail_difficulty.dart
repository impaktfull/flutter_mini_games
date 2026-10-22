/// Difficulty levels for Trail puzzles
enum TrailDifficulty {
  /// 3x3 grid, 2 checkpoints
  easy(1, 3, 2),

  /// 4x4 grid, 3-4 checkpoints
  medium(2, 4, 3),

  /// 5x5 grid, 4-6 checkpoints
  hard(3, 5, 5),

  /// 6x6 grid, 5-8 checkpoints
  expert(4, 6, 6),

  /// 7x7 grid, 6-8 checkpoints
  master(5, 7, 7);

  /// Numeric value for storage/comparison
  final int value;

  /// Grid size (rows and cols)
  final int gridSize;

  /// Base number of checkpoints
  final int baseCheckpoints;

  const TrailDifficulty(this.value, this.gridSize, this.baseCheckpoints);

  /// Get difficulty from numeric value
  static TrailDifficulty fromValue(int value) {
    return TrailDifficulty.values.firstWhere(
      (d) => d.value == value,
      orElse: () => TrailDifficulty.hard,
    );
  }
}
