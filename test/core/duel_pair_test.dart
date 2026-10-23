import 'package:flutter_mini_games/flutter_mini_games.dart';
import 'package:flutter_mini_games/src/core/duel/duel_pair.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DuelPair', () {
    test('reads and writes the value of each player', () {
      final pair = DuelPair(1, 2);

      pair[DuelPlayer.top] = 5;

      expect(pair[DuelPlayer.bottom], equals(1));
      expect(pair[DuelPlayer.top], equals(5));
      expect(pair.values, equals([1, 5]));
    });

    test('generate creates a separate value per player', () {
      final pair = DuelPair.generate((player) => <int>{});

      pair[DuelPlayer.bottom].add(1);

      expect(pair[DuelPlayer.top], isEmpty);
    });

    test('updateAll and toJson', () {
      final pair = DuelPair(1, 2)..updateAll((player, value) => value * 10);

      expect(pair.toJson(), equals({'bottom': 10, 'top': 20}));
    });
  });
}
