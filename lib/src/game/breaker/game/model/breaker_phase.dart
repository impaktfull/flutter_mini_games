enum BreakerPhase {
  /// New game, the ball rests on the paddle until the first launch
  ready,

  /// A life was lost, the ball rests on the paddle until it is launched again
  serving,

  /// A level was cleared, the next level waits for a launch
  levelCleared,

  /// The ball is moving
  playing,

  /// The last life was lost
  gameOver,

  /// The last level was cleared
  won;

  /// Whether the ball rests on the paddle and waits for a launch
  bool get isWaitingForLaunch => this == ready || this == serving || this == levelCleared;
}
