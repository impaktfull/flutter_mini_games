enum GameOutcome {
  won,
  lost,
  draw,

  /// The player left before the game was finished
  abandoned,
}

/// Result of one finished (or abandoned) game session. Shared by all games.
class GameResult {
  /// Id of the game, see `FlutterMiniGameBuilder.id`
  final String gameId;
  final GameOutcome outcome;

  /// Game-specific score, higher is better. Null when a game has no score (e.g. Tic Tac Toe).
  final int? score;
  final Duration duration;
  final int moves;
  final DateTime finishedAt;

  /// Game-specific extra information (e.g. the winner of a multiplayer game)
  final Map<String, Object?> data;

  const GameResult({
    required this.gameId,
    required this.outcome,
    required this.duration,
    required this.moves,
    required this.finishedAt,
    this.score,
    this.data = const {},
  });

  Map<String, Object?> toJson() => {
    'gameId': gameId,
    'outcome': outcome.name,
    'score': score,
    'durationMs': duration.inMilliseconds,
    'moves': moves,
    'finishedAt': finishedAt.toIso8601String(),
    'data': data,
  };

  factory GameResult.fromJson(Map<String, Object?> json) => GameResult(
    gameId: json['gameId'] as String,
    outcome: GameOutcome.values.byName(json['outcome'] as String),
    score: json['score'] as int?,
    duration: Duration(milliseconds: json['durationMs'] as int),
    moves: json['moves'] as int,
    finishedAt: DateTime.parse(json['finishedAt'] as String),
    data: Map<String, Object?>.from(json['data'] as Map? ?? const {}),
  );
}
