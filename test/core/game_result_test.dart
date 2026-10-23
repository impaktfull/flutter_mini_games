import 'dart:convert';

import 'package:flutter_mini_games/flutter_mini_games.dart';
import 'package:flutter_test/flutter_test.dart';

GameResult _result(
  GameOutcome outcome, {
  String gameId = 'game',
  int? score,
  Duration duration = const Duration(seconds: 10),
}) => GameResult(
  gameId: gameId,
  outcome: outcome,
  score: score,
  duration: duration,
  moves: 5,
  finishedAt: DateTime(2026, 1, 1),
);

void main() {
  group('GameResult', () {
    test('survives a JSON round trip', () {
      final result = GameResult(
        gameId: 'trail',
        outcome: GameOutcome.won,
        score: 420,
        duration: const Duration(milliseconds: 12345),
        moves: 24,
        finishedAt: DateTime.utc(2026, 1, 29, 12),
        data: const {'puzzle': 'Tutorial'},
      );

      final copy = GameResult.fromJson(result.toJson());

      expect(copy.gameId, equals('trail'));
      expect(copy.outcome, equals(GameOutcome.won));
      expect(copy.score, equals(420));
      expect(copy.duration, equals(const Duration(milliseconds: 12345)));
      expect(copy.moves, equals(24));
      expect(copy.finishedAt, equals(DateTime.utc(2026, 1, 29, 12)));
      expect(copy.data, equals({'puzzle': 'Tutorial'}));
    });

    test('reads results stored as JSON text', () {
      final json = jsonDecode(jsonEncode(_result(GameOutcome.lost, score: 3).toJson()));

      final copy = GameResult.fromJson(json as Map<String, Object?>);

      expect(copy.score, equals(3));
      expect(copy.data, isEmpty);
    });

    test('rejects JSON with missing fields or wrong types', () {
      final json = _result(GameOutcome.won).toJson();

      expect(() => GameResult.fromJson({...json}..remove('moves')), throwsFormatException);
      expect(() => GameResult.fromJson({...json, 'durationMs': '10'}), throwsFormatException);
      expect(() => GameResult.fromJson({...json, 'score': 1.5}), throwsFormatException);
      expect(() => GameResult.fromJson({...json, 'data': 'x'}), throwsFormatException);
    });
  });

  group('GameStats', () {
    test('counts outcomes and keeps the best score and fastest win', () {
      final stats = GameStats.fromResults('game', [
        _result(GameOutcome.won, score: 100, duration: const Duration(seconds: 30)),
        _result(GameOutcome.won, score: 300, duration: const Duration(seconds: 50)),
        _result(GameOutcome.lost, score: 250),
        _result(GameOutcome.abandoned, score: 999),
        _result(GameOutcome.draw),
        _result(GameOutcome.abandoned),
        _result(GameOutcome.won, gameId: 'other', score: 5000),
      ]);

      expect(stats.played, equals(6));
      expect(stats.won, equals(2));
      expect(stats.lost, equals(1));
      expect(stats.draw, equals(1));
      expect(stats.abandoned, equals(2));
      expect(stats.bestScore, equals(300));
      expect(stats.fastestWin, equals(const Duration(seconds: 30)));
    });

    test('counts the score of lost games, for endless games', () {
      final stats = GameStats.fromResults('game', [_result(GameOutcome.lost, score: 10)]);

      expect(stats.bestScore, equals(10));
      expect(stats.fastestWin, isNull);
    });
  });

  group('InMemoryGameScoreStore', () {
    test('keeps results per game', () async {
      final store = InMemoryGameScoreStore();
      await store.save(_result(GameOutcome.won, gameId: 'a', score: 10));
      await store.save(_result(GameOutcome.won, gameId: 'b', score: 20));

      expect(await store.results('a'), hasLength(1));
      expect((await store.stats('b')).bestScore, equals(20));
    });
  });
}
