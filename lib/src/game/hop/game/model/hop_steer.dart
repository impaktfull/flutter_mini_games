/// Horizontal steering of the character
enum HopSteer {
  none(0),
  left(-1),
  right(1);

  /// -1 for left, 1 for right
  final int sign;

  const HopSteer(this.sign);
}
