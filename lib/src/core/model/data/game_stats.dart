import 'package:flutter_mini_games/src/core/model/data/game_result.dart';

/// Statistics of one game, calculated from its results
class GameStats {
  final String gameId;
  final int played;
  final int won;
  final int lost;
  final int draw;
  final int abandoned;

  /// Highest score of a finished (not abandoned) game, null when none has a score.
  /// Endless games finish with [GameOutcome.lost] and their score, so it counts every outcome.
  final int? bestScore;

  /// Shortest duration of a won game
  final Duration? fastestWin;

  const GameStats({
    required this.gameId,
    this.played = 0,
    this.won = 0,
    this.lost = 0,
    this.draw = 0,
    this.abandoned = 0,
    this.bestScore,
    this.fastestWin,
  });

  factory GameStats.fromResults(String gameId, Iterable<GameResult> results) {
    var won = 0, lost = 0, draw = 0, abandoned = 0;
    int? bestScore;
    Duration? fastestWin;
    for (final result in results.where((result) => result.gameId == gameId)) {
      final score = result.score;
      if (result.outcome != GameOutcome.abandoned && score != null && (bestScore == null || score > bestScore)) bestScore = score;
      switch (result.outcome) {
        case GameOutcome.won:
          won++;
          if (fastestWin == null || result.duration < fastestWin) fastestWin = result.duration;
        case GameOutcome.lost:
          lost++;
        case GameOutcome.draw:
          draw++;
        case GameOutcome.abandoned:
          abandoned++;
      }
    }
    return GameStats(
      gameId: gameId,
      played: won + lost + draw + abandoned,
      won: won,
      lost: lost,
      draw: draw,
      abandoned: abandoned,
      bestScore: bestScore,
      fastestWin: fastestWin,
    );
  }
}
