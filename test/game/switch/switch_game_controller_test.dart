import 'dart:math';

import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';
import 'package:flutter_mini_games/src/game/switch/game/logic/switch_game_controller.dart';
import 'package:flutter_mini_games/src/game/switch/game/model/switch_difficulty.dart';
import 'package:flutter_mini_games/src/game/switch/game/model/switch_puzzle.dart';
import 'package:flutter_mini_games/src/game/switch/game/model/switch_solver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Tapping (1, 1) and (3, 3) turns these off: par 2
  final twoCrosses = SwitchPuzzle.fromString('.#... ###.. .#.#. ..### ...#.', name: 'Two crosses');
  final plus = SwitchPuzzle.fromString('.#... ###.. .#... ..... .....', name: 'Plus');

  /// Taps the minimal solution of the current board
  void solve(SwitchGameController controller) {
    final taps = const SwitchSolver().minimalSolution(controller.lights)!;
    for (var i = 0; i < 25; i++) {
      if (taps & (1 << i) != 0) controller.tap(i ~/ 5, i % 5);
    }
  }

  group('SwitchGameController', () {
    test('starts with the lights of the puzzle', () {
      final controller = SwitchGameController(puzzles: [twoCrosses]);
      expect(controller.size, 5);
      expect(controller.lights, twoCrosses.lights);
      expect(controller.litCount, 10);
      expect(controller.par, 2);
      expect(controller.status, GameStatus.ready);
      expect(controller.hasCustomPuzzles, isTrue);
      expect(controller.hint, isNull);
    });

    test('a tap toggles the light and its 4 neighbours', () {
      final controller = SwitchGameController(puzzles: [twoCrosses])..tap(2, 2);
      expect(controller.isLit(2, 2), isTrue);
      expect(controller.isLit(1, 2), isFalse); // was on
      expect(controller.isLit(3, 2), isFalse); // was on
      expect(controller.isLit(2, 1), isFalse); // was on
      expect(controller.isLit(2, 3), isFalse); // was on
      expect(controller.isLit(1, 1), isTrue); // diagonal, unchanged
      expect(controller.moves, 1);
      expect(controller.status, GameStatus.playing);
    });

    test('a corner tap toggles 3 lights, tapping twice restores the board', () {
      final controller = SwitchGameController(puzzles: [twoCrosses])..tap(0, 0);
      expect(controller.isLit(0, 0), isTrue);
      expect(controller.isLit(0, 1), isFalse);
      expect(controller.isLit(1, 0), isFalse);
      controller.tap(0, 0);
      expect(controller.lights, twoCrosses.lights);
      expect(controller.moves, 2);
      expect(controller.isFinished, isFalse);
    });

    test('turning every light off at par wins with the full score', () {
      final results = <GameResult>[];
      final controller = SwitchGameController(puzzles: [twoCrosses])..resultListener = results.add;
      controller
        ..tap(1, 1)
        ..tap(3, 3);

      expect(controller.lights, 0);
      expect(controller.isWon, isTrue);
      expect(results, hasLength(1));
      final result = results.single;
      expect(result.gameId, 'switch_lights');
      expect(result.outcome, GameOutcome.won);
      expect(result.moves, 2);
      expect(result.score, 1000 - controller.elapsed.inSeconds);
      expect(result.data, {'difficulty': null, 'par': 2, 'hints': 0});
    });

    test('moves above par cost 50 points each', () {
      final controller = SwitchGameController(puzzles: [plus])
        ..tap(4, 4)
        ..tap(4, 4)
        ..tap(1, 1);

      expect(controller.isWon, isTrue);
      expect(controller.result!.moves, 3);
      expect(controller.result!.score, 1000 - 2 * 50 - controller.elapsed.inSeconds);
    });

    test('ignores taps after winning', () {
      final controller = SwitchGameController(puzzles: [plus])..tap(1, 1);
      controller.tap(2, 2);
      expect(controller.lights, 0);
      expect(controller.moves, 1);
    });

    test('rejects cells outside the board', () {
      final controller = SwitchGameController(puzzles: [plus]);
      expect(() => controller.tap(5, 0), throwsRangeError);
      expect(() => controller.tap(0, -1), throwsRangeError);
    });

    group('calculateScore', () {
      test('follows max(100, 1000 - (moves - par) * 50 - seconds)', () {
        expect(SwitchGameController.calculateScore(moves: 5, par: 5, elapsed: Duration.zero), 1000);
        expect(SwitchGameController.calculateScore(moves: 7, par: 5, elapsed: const Duration(seconds: 30)), 870);
        expect(SwitchGameController.calculateScore(moves: 5, par: 5, elapsed: const Duration(milliseconds: 1999)), 999);
      });

      test('never goes below 100', () {
        expect(SwitchGameController.calculateScore(moves: 40, par: 5, elapsed: Duration.zero), 100);
        expect(SwitchGameController.calculateScore(moves: 5, par: 5, elapsed: const Duration(hours: 1)), 100);
      });
    });

    group('hint', () {
      test('shows one tap of the shortest solution', () {
        final controller = SwitchGameController(puzzles: [twoCrosses])..showHint();
        expect(controller.hint, (1, 1));
        expect(controller.isHint(1, 1), isTrue);
        expect(controller.hints, 1);
        expect(controller.moves, 0);

        // Showing the same hint again does not count
        controller.showHint();
        expect(controller.hints, 1);
      });

      test('following the hints solves the puzzle at par', () {
        for (var seed = 0; seed < 20; seed++) {
          final controller = SwitchGameController(difficulty: SwitchDifficulty.expert, random: Random(seed));
          final par = controller.par;
          while (!controller.isFinished) {
            controller.showHint();
            final (row, col) = controller.hint!;
            controller.tap(row, col);
            expect(controller.hint, isNull);
          }
          expect(controller.moves, par);
          expect(controller.result!.data['hints'], par);
        }
      });

      test('recomputes the solution after a wrong move', () {
        final controller = SwitchGameController(puzzles: [plus])
          ..tap(4, 4)
          ..showHint();
        final (row, col) = controller.hint!;
        controller.tap(row, col);
        controller.showHint();
        final (row2, col2) = controller.hint!;
        controller.tap(row2, col2);
        expect(controller.isWon, isTrue);
        expect(controller.moves, 3);
      });

      test('does nothing after winning', () {
        final controller = SwitchGameController(puzzles: [plus])
          ..tap(1, 1)
          ..showHint();
        expect(controller.hint, isNull);
        expect(controller.hints, 0);
      });
    });

    test('reset restores the same puzzle and a new session', () {
      final controller = SwitchGameController(puzzles: [twoCrosses])
        ..tap(0, 0)
        ..showHint()
        ..resetGame();
      expect(controller.lights, twoCrosses.lights);
      expect(controller.moves, 0);
      expect(controller.hints, 0);
      expect(controller.hint, isNull);
      expect(controller.status, GameStatus.ready);
    });

    test('next puzzle cycles through the custom puzzles', () {
      final controller = SwitchGameController(puzzles: [twoCrosses, plus]);
      expect(controller.puzzle, twoCrosses);
      controller
        ..tap(1, 1)
        ..tap(3, 3)
        ..nextPuzzle();
      expect(controller.puzzle, plus);
      expect(controller.result, isNull);
      expect(controller.status, GameStatus.ready);
      controller.nextPuzzle();
      expect(controller.puzzle, twoCrosses);
    });

    test('generates solvable puzzles of the difficulty, reproducible with a seed', () {
      final a = SwitchGameController(difficulty: SwitchDifficulty.easy, random: Random(3));
      final b = SwitchGameController(difficulty: SwitchDifficulty.easy, random: Random(3));
      expect(a.hasCustomPuzzles, isFalse);
      expect(a.lights, b.lights);
      expect(a.par, inInclusiveRange(1, SwitchDifficulty.easy.taps));

      solve(a);
      expect(a.isWon, isTrue);
      expect(a.result!.data['difficulty'], 'easy');
      expect(a.result!.moves, a.par);

      a.nextPuzzle();
      expect(a.isFinished, isFalse);
      expect(a.lights, isNot(0));
    });

    test('a new game switches the difficulty', () {
      final controller = SwitchGameController(random: Random(5))..tap(0, 0);
      expect(controller.difficulty, SwitchDifficulty.medium);
      controller.newGame(difficulty: SwitchDifficulty.expert);
      expect(controller.difficulty, SwitchDifficulty.expert);
      expect(controller.moves, 0);
      expect(controller.status, GameStatus.ready);
      expect(controller.par, inInclusiveRange(1, SwitchDifficulty.expert.taps));
    });

    test('an empty puzzle list falls back to generated puzzles', () {
      final controller = SwitchGameController(puzzles: const [], random: Random(1));
      expect(controller.hasCustomPuzzles, isFalse);
      expect(controller.lights, isNot(0));
    });

    test('leaving while playing is reported as abandoned', () {
      final results = <GameResult>[];
      SwitchGameController(puzzles: [twoCrosses])
        ..resultListener = results.add
        ..tap(0, 0)
        ..dispose();
      expect(results.single.outcome, GameOutcome.abandoned);
    });
  });
}
