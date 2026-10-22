/// One of the 6 symbols of a code.
///
/// Every peg has its own shape, so the pegs can be told apart without their color.
enum CodePeg {
  circle('Circle'),
  square('Square'),
  triangle('Triangle'),
  diamond('Diamond'),
  star('Star'),
  hexagon('Hexagon');

  /// Name for screen readers
  final String label;

  const CodePeg(this.label);
}
