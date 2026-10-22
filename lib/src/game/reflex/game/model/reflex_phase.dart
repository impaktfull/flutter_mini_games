/// Phase of a Reflex game
enum ReflexPhase {
  /// Before the first try, a tap starts the game
  ready,

  /// Waiting for the random delay to pass, tapping now is too early
  waiting,

  /// The board changed color, the reaction time is running
  go,

  /// Tapped before the change, a tap retries the same try
  tooEarly,

  /// A try was measured, a tap starts the next one
  measured,

  /// All tries are done
  finished,
}
