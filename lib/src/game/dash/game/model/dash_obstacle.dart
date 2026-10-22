enum DashObstacleType {
  /// Stands on the ground, jump over it
  block,

  /// Low flyer: duck under it or jump over it
  lowFlyer,

  /// High flyer: stay on the ground and run under it
  highFlyer,
}

/// Obstacle in world units: x to the right, y up from the ground.
class DashObstacle {
  final DashObstacleType type;
  final double width;
  final double height;

  /// Height of the bottom edge above the ground
  final double bottom;

  /// Left edge, decreases while the world scrolls
  double x;

  DashObstacle({
    required this.type,
    required this.x,
    required this.width,
    required this.height,
    this.bottom = 0,
  });

  double get right => x + width;
  double get top => bottom + height;
  bool get isFlyer => type != DashObstacleType.block;
}
