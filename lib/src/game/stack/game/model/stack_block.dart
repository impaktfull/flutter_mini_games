/// A block of the tower in world coordinates: the world is 1 wide, levels are counted from the ground.
class StackBlock {
  /// Level in the tower, 0 is the base
  final int level;

  /// Left edge, 0 is the left side of the world
  final double left;

  /// Width, 1 is the width of the world
  final double width;

  const StackBlock({
    required this.level,
    required this.left,
    required this.width,
  });

  double get right => left + width;

  StackBlock copyWith({
    int? level,
    double? left,
    double? width,
  }) => StackBlock(
    level: level ?? this.level,
    left: left ?? this.left,
    width: width ?? this.width,
  );

  @override
  bool operator ==(Object other) => other is StackBlock && other.level == level && other.left == left && other.width == width;

  @override
  int get hashCode => Object.hash(level, left, width);

  @override
  String toString() => 'StackBlock(level: $level, left: $left, width: $width)';
}

/// The part of a block that was cut off and falls down
class StackFallingPiece {
  final StackBlock block;

  /// Distance the piece has fallen, in world units
  final double drop;

  /// Downward speed in world units per second
  final double velocity;

  const StackFallingPiece({
    required this.block,
    this.drop = 0,
    this.velocity = 0,
  });
}
