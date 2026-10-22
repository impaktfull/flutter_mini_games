/// Board sizes of Minesweeper, sized to fit a portrait phone (columns x rows).
enum MinesweeperDifficulty {
  /// 8 x 8 board, 10 mines (~16% mines)
  easy(cols: 8, rows: 8, mines: 10, label: 'Easy'),

  /// 10 x 12 board, 20 mines (~17% mines)
  medium(cols: 10, rows: 12, mines: 20, label: 'Medium'),

  /// 12 x 16 board, 40 mines (~21% mines)
  hard(cols: 12, rows: 16, mines: 40, label: 'Hard');

  final int cols;
  final int rows;
  final int mines;
  final String label;

  const MinesweeperDifficulty({
    required this.cols,
    required this.rows,
    required this.mines,
    required this.label,
  });

  int get cells => cols * rows;

  int get safeCells => cells - mines;
}
