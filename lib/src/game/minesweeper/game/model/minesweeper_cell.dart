/// Read-only view of one cell of the Minesweeper board
class MinesweeperCell {
  final int row;
  final int col;

  /// Always false until the mines are placed on the first reveal
  final bool isMine;
  final bool isRevealed;
  final bool isFlagged;

  /// The mine that was revealed and lost the game
  final bool isExploded;

  /// Number of mines in the 8 neighbouring cells
  final int adjacentMines;

  const MinesweeperCell({
    required this.row,
    required this.col,
    required this.isMine,
    required this.isRevealed,
    required this.isFlagged,
    required this.isExploded,
    required this.adjacentMines,
  });
}
