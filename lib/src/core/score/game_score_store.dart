import 'package:flutter_mini_games/src/core/model/data/game_result.dart';
import 'package:flutter_mini_games/src/core/model/data/game_stats.dart';

/// Stores the results of all games.
///
/// The library only ships [InMemoryGameScoreStore]. Implement this class to persist
/// results (e.g. with `GameResult.toJson` in shared preferences or on a backend).
abstract class GameScoreStore {
  const GameScoreStore();

  Future<void> save(GameResult result);

  /// All results of a game, oldest first
  Future<List<GameResult>> results(String gameId);

  Future<GameStats> stats(String gameId) async => GameStats.fromResults(gameId, await results(gameId));
}

class InMemoryGameScoreStore extends GameScoreStore {
  final List<GameResult> _results = [];

  @override
  Future<void> save(GameResult result) async => _results.add(result);

  @override
  Future<List<GameResult>> results(String gameId) async => _results.where((result) => result.gameId == gameId).toList();
}
