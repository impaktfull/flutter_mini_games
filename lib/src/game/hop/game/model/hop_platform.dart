enum HopPlatformType {
  /// Stays in place
  normal,

  /// Slides left and right
  moving,

  /// Breaks when the character lands on it, without a bounce
  breakable,
}

/// A platform in world units: the world is 1.0 wide and y grows upwards.
class HopPlatform {
  /// Horizontal center
  double x;

  /// Top of the platform, where the character lands
  double y;

  final double width;
  final HopPlatformType type;

  /// Horizontal speed in world units per second, only for [HopPlatformType.moving]
  double velocityX;

  /// A breakable platform that was landed on, it falls and can no longer be landed on
  bool isBroken = false;

  HopPlatform({
    required this.x,
    required this.y,
    required this.width,
    this.type = HopPlatformType.normal,
    this.velocityX = 0,
  });

  double get left => x - width / 2;

  double get right => x + width / 2;

  /// Whether the character can land on it
  bool get isSolid => !isBroken;
}
