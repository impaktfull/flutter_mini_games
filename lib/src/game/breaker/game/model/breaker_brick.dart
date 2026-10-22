/// A brick in world units, (left, top) is its top left corner (y grows downwards)
class BreakerBrick {
  final int row;
  final int column;
  final double left;
  final double top;
  final double width;
  final double height;

  const BreakerBrick({
    required this.row,
    required this.column,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  double get right => left + width;

  double get bottom => top + height;
}
