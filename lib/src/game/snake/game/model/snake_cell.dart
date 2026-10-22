import 'package:flutter_mini_games/src/core/widget/input/game_input_detector.dart';

/// A cell on the Snake board, [x] is the column and [y] the row (0 is the top row)
class SnakeCell {
  final int x;
  final int y;

  const SnakeCell(this.x, this.y);

  /// The neighbouring cell in [direction]
  SnakeCell move(GameDirection direction) => switch (direction) {
    GameDirection.up => SnakeCell(x, y - 1),
    GameDirection.down => SnakeCell(x, y + 1),
    GameDirection.left => SnakeCell(x - 1, y),
    GameDirection.right => SnakeCell(x + 1, y),
  };

  @override
  bool operator ==(Object other) => other is SnakeCell && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'SnakeCell($x, $y)';
}
