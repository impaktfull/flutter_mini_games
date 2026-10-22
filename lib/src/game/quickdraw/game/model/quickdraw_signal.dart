/// The signal of a playing round
enum QuickdrawSignal {
  /// Random wait before the signal: tapping now loses the round
  waiting,

  /// The signal is shown: the first tap wins the round
  go,
}
