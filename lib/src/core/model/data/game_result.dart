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

  /// Reads the output of [toJson]. Throws a [FormatException] when a field is missing or has the wrong type.
  factory GameResult.fromJson(Map<String, Object?> json) {
    if (json case {
      'gameId': final String gameId,
      'outcome': final String outcome,
      'durationMs': final int durationMs,
      'moves': final int moves,
      'finishedAt': final String finishedAt,
    }) {
      return GameResult(
        gameId: gameId,
        outcome: GameOutcome.values.byName(outcome),
        score: switch (json['score']) {
          null => null,
          final int score => score,
          _ => throw FormatException('GameResult score is not an int', json),
        },
        duration: Duration(milliseconds: durationMs),
        moves: moves,
        finishedAt: DateTime.parse(finishedAt),
        data: switch (json['data']) {
          null => const {},
          final Map<String, Object?> data => Map.of(data),
          _ => throw FormatException('GameResult data is not a map', json),
        },
      );
    }
    throw FormatException('Invalid GameResult', json);
  }
}
