/// Board sizes of Pairs (columns x rows), every board has an even number of cards.
enum PairsDifficulty {
  /// 4 x 4 board, 8 pairs
  easy(cols: 4, rows: 4, label: 'Easy'),

  /// 4 x 5 board, 10 pairs
  medium(cols: 4, rows: 5, label: 'Medium'),

  /// 5 x 6 board, 15 pairs
  hard(cols: 5, rows: 6, label: 'Hard');

  final int cols;
  final int rows;
  final String label;

  const PairsDifficulty({
    required this.cols,
    required this.rows,
    required this.label,
  });

  int get cards => cols * rows;

  int get pairs => cards ~/ 2;
}
