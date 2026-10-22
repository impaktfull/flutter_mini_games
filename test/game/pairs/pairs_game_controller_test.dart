import 'dart:math';

import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';
import 'package:flutter_mini_games/src/game/pairs/game/logic/pairs_game_controller.dart';
import 'package:flutter_mini_games/src/game/pairs/game/model/pairs_difficulty.dart';
import 'package:flutter_mini_games/src/game/pairs/widget/pairs_card_tile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Positions of both cards of every pair, by value
  Map<int, List<int>> pairsOf(PairsGameController controller) {
    final pairs = <int, List<int>>{};
    for (var i = 0; i < controller.cardCount; i++) {
      pairs.putIfAbsent(controller.valueAt(i), () => []).add(i);
    }
    return pairs;
  }

  /// 4x4 board where cards 2n and 2n + 1 are a pair
  PairsGameController ordered() {
    return PairsGameController(random: Random(42))..setValues([for (var i = 0; i < 16; i++) i ~/ 2]);
  }

  group('PairsDifficulty', () {
    test('has the board sizes of the issue with an even number of cards', () {
      expect([for (final d in PairsDifficulty.values) (d.cols, d.rows)], [(4, 4), (4, 5), (5, 6)]);
      for (final difficulty in PairsDifficulty.values) {
        expect(difficulty.cards.isEven, isTrue);
        expect(difficulty.pairs, lessThanOrEqualTo(PairsCardTile.faceIcons.length));
      }
    });
  });

  group('shuffle', () {
    for (final difficulty in PairsDifficulty.values) {
      test('places every value exactly twice on ${difficulty.name}', () {
        final controller = PairsGameController(difficulty: difficulty, random: Random(42));
        final pairs = pairsOf(controller);
        expect(pairs.keys.toSet(), {for (var i = 0; i < difficulty.pairs; i++) i});
        expect(pairs.values.every((positions) => positions.length == 2), isTrue);
        expect(controller.status, GameStatus.ready);
        expect(controller.pairsFound, 0);
      });
    }

    test('is reproducible with a seeded Random and differs between seeds', () {
      List<int> board(int seed) {
        final controller = PairsGameController(random: Random(seed));
        return [for (var i = 0; i < controller.cardCount; i++) controller.valueAt(i)];
      }

      expect(board(1), board(1));
      expect(board(1), isNot(board(2)));
    });

    test('reset shuffles a new board', () {
      final controller = PairsGameController(random: Random(3));
      final before = [for (var i = 0; i < 16; i++) controller.valueAt(i)];
      controller.resetGame();
      expect([for (var i = 0; i < 16; i++) controller.valueAt(i)], isNot(before));
    });
  });

  group('flipping', () {
    test('the first card starts the timer without counting a move', () {
      final controller = ordered()..flip(0);
      expect(controller.status, GameStatus.playing);
      expect(controller.moves, 0);
      expect(controller.cardAt(0).isFaceUp, isTrue);
      expect(controller.flipped, [0]);
    });

    test('a matching pair stays open and counts one move', () {
      final controller = ordered()
        ..flip(0)
        ..flip(1);
      expect(controller.moves, 1);
      expect(controller.pairsFound, 1);
      expect(controller.cardAt(0).isMatched, isTrue);
      expect(controller.cardAt(1).isMatched, isTrue);
      expect(controller.flipped, isEmpty);
      expect(controller.isShowingMismatch, isFalse);
    });

    // testWidgets runs in fake time, so the mismatch timer is deterministic
    testWidgets('a mismatch blocks input and turns back after the delay', (tester) async {
      final controller = ordered()
        ..flip(0)
        ..flip(2);
      expect(controller.moves, 1);
      expect(controller.isShowingMismatch, isTrue);
      expect(controller.cardAt(0).isMismatch, isTrue);
      expect(controller.cardAt(2).isFaceUp, isTrue);

      controller.flip(4);
      expect(controller.cardAt(4).isFaceUp, isFalse);
      expect(controller.canFlip(4), isFalse);

      await tester.pump(PairsGameController.defaultMismatchDelay - const Duration(milliseconds: 1));
      expect(controller.isShowingMismatch, isTrue);
      await tester.pump(const Duration(milliseconds: 1));
      expect(controller.isShowingMismatch, isFalse);
      expect(controller.cardAt(0).isFaceUp, isFalse);
      expect(controller.cardAt(2).isFaceUp, isFalse);
      expect(controller.pairsFound, 0);

      controller.flip(4);
      expect(controller.cardAt(4).isFaceUp, isTrue);
    });

    test('hideMismatch turns the cards back right away', () {
      final controller = ordered()
        ..flip(0)
        ..flip(2)
        ..hideMismatch();
      expect(controller.isShowingMismatch, isFalse);
      expect(controller.flipped, isEmpty);
      controller.dispose();
    });

    test('ignores flipping the same card twice and found pairs', () {
      final controller = ordered()
        ..flip(0)
        ..flip(0);
      expect(controller.flipped, [0]);
      expect(controller.moves, 0);

      controller
        ..flip(1)
        ..flip(0)
        ..flip(1);
      expect(controller.flipped, isEmpty);
      expect(controller.moves, 1);
    });

    test('throws for cards outside the board', () {
      final controller = ordered();
      expect(() => controller.flip(16), throwsRangeError);
      expect(() => controller.cardAt(-1), throwsRangeError);
    });

    testWidgets('reset during a mismatch cancels the timer and restarts the session', (tester) async {
      final controller = ordered()
        ..flip(0)
        ..flip(2)
        ..resetGame();
      expect(controller.isShowingMismatch, isFalse);
      expect(controller.status, GameStatus.ready);
      expect(controller.moves, 0);
      await tester.pump(const Duration(seconds: 2));
      expect(controller.flipped, isEmpty);
    });

    test('newGame switches the difficulty', () {
      final controller = ordered()..newGame(difficulty: PairsDifficulty.hard);
      expect(controller.cardCount, 30);
      expect(controller.totalPairs, 15);
      expect(pairsOf(controller).length, 15);
    });
  });

  group('result', () {
    test('finding all pairs wins with the score', () {
      final controller = PairsGameController(difficulty: PairsDifficulty.medium, random: Random(7));
      final results = <GameResult>[];
      controller.resultListener = results.add;
      for (final positions in pairsOf(controller).values) {
        controller
          ..flip(positions[0])
          ..flip(positions[1]);
      }

      expect(controller.isWon, isTrue);
      expect(results, hasLength(1));
      final result = results.single;
      expect(result.gameId, 'pairs');
      expect(result.outcome, GameOutcome.won);
      expect(result.moves, 10);
      expect(result.score, PairsGameController.calculateScore(10, result.duration));
      expect(result.data, {'difficulty': 'medium', 'rows': 5, 'cols': 4, 'pairs': 10});
    });

    testWidgets('mistakes count as moves', (tester) async {
      final controller = ordered()
        ..flip(0)
        ..flip(2);
      await tester.pump(PairsGameController.defaultMismatchDelay);
      for (var i = 0; i < 16; i += 2) {
        controller
          ..flip(i)
          ..flip(i + 1);
      }
      expect(controller.result?.moves, 9);
      expect(controller.result?.score, 1000 - 9 * 10);
    });

    test('ignores flips after winning', () {
      final controller = ordered();
      for (var i = 0; i < 16; i += 2) {
        controller
          ..flip(i)
          ..flip(i + 1);
      }
      expect(controller.isFinished, isTrue);
      expect(controller.canFlip(0), isFalse);
    });

    test('score is 1000 - moves * 10 - seconds, never below 100', () {
      expect(PairsGameController.calculateScore(8, Duration.zero), 920);
      expect(PairsGameController.calculateScore(8, const Duration(seconds: 30, milliseconds: 900)), 890);
      expect(PairsGameController.calculateScore(50, const Duration(seconds: 300)), 200);
      expect(PairsGameController.calculateScore(70, const Duration(seconds: 300)), 100);
      expect(PairsGameController.calculateScore(90, Duration.zero), 100);
    });

    test('leaving while playing is reported as abandoned', () {
      final controller = ordered();
      final results = <GameResult>[];
      controller
        ..resultListener = results.add
        ..flip(0)
        ..dispose();
      expect(results.single.outcome, GameOutcome.abandoned);
    });
  });
}
