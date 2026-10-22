/// Read-only view of one card on the Pairs board
class PairsCard {
  /// Position on the board, row by row
  final int index;

  /// Both cards of a pair share the same value (0 until pairs - 1)
  final int value;

  /// Shown face up: one of the flipped cards or a found pair
  final bool isFaceUp;

  /// Part of a found pair, stays open
  final bool isMatched;

  /// One of the two flipped cards that don't match, about to turn back
  final bool isMismatch;

  const PairsCard({
    required this.index,
    required this.value,
    required this.isFaceUp,
    required this.isMatched,
    required this.isMismatch,
  });
}
