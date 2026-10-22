/// Difficulty of a generated Switch puzzle: the number of distinct random taps applied to a dark board.
enum SwitchDifficulty {
  easy(taps: 3, label: 'Easy'),
  medium(taps: 6, label: 'Medium'),
  hard(taps: 9, label: 'Hard'),
  expert(taps: 13, label: 'Expert');

  /// Number of distinct cells tapped to scramble the dark board
  final int taps;
  final String label;

  const SwitchDifficulty({
    required this.taps,
    required this.label,
  });
}
