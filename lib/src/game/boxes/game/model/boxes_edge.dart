/// A line between two adjacent dots.
///
/// A horizontal edge runs from dot (row, col) to dot (row, col + 1),
/// a vertical edge from dot (row, col) to dot (row + 1, col).
class BoxesEdge {
  final bool isHorizontal;
  final int row;
  final int col;

  const BoxesEdge.horizontal(this.row, this.col) : isHorizontal = true;

  const BoxesEdge.vertical(this.row, this.col) : isHorizontal = false;

  /// Every edge of a grid of [rows] x [cols] boxes
  static List<BoxesEdge> all({required int rows, required int cols}) => [
    for (var row = 0; row <= rows; row++)
      for (var col = 0; col < cols; col++) BoxesEdge.horizontal(row, col),
    for (var row = 0; row < rows; row++)
      for (var col = 0; col <= cols; col++) BoxesEdge.vertical(row, col),
  ];

  /// The four sides of box (row, col)
  static List<BoxesEdge> sidesOf(int row, int col) => [
    BoxesEdge.horizontal(row, col),
    BoxesEdge.horizontal(row + 1, col),
    BoxesEdge.vertical(row, col),
    BoxesEdge.vertical(row, col + 1),
  ];

  /// The boxes (row, col) next to this edge, only those inside a grid of [rows] x [cols] boxes
  List<(int, int)> adjacentBoxes({required int rows, required int cols}) {
    final candidates = isHorizontal ? [(row - 1, col), (row, col)] : [(row, col - 1), (row, col)];
    return [
      for (final (r, c) in candidates)
        if (r >= 0 && r < rows && c >= 0 && c < cols) (r, c),
    ];
  }

  /// Whether this edge exists in a grid of [rows] x [cols] boxes
  bool isInside({required int rows, required int cols}) {
    if (row < 0 || col < 0) return false;
    return isHorizontal ? row <= rows && col < cols : row < rows && col <= cols;
  }

  @override
  bool operator ==(Object other) => other is BoxesEdge && other.isHorizontal == isHorizontal && other.row == row && other.col == col;

  @override
  int get hashCode => Object.hash(isHorizontal, row, col);

  @override
  String toString() => 'BoxesEdge.${isHorizontal ? 'horizontal' : 'vertical'}($row, $col)';
}
