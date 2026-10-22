/// Horizontal steering of the paddle with the keyboard or by holding a half of the board
enum BreakerSteer {
  none(0),
  left(-1),
  right(1);

  /// -1 for left, 1 for right
  final int sign;

  const BreakerSteer(this.sign);
}
