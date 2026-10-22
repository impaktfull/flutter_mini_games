import 'dart:math';

import 'package:flutter_mini_games/src/game/switch/game/model/switch_difficulty.dart';
import 'package:flutter_mini_games/src/game/switch/game/model/switch_puzzle.dart';
import 'package:flutter_mini_games/src/game/switch/game/model/switch_puzzle_generator.dart';
import 'package:flutter_mini_games/src/game/switch/game/model/switch_solver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Minimal number of taps for every reachable board, by trying every set of taps
  Map<int, int> bruteForce(SwitchSolver solver) {
    final minimal = <int, int>{};
    for (var taps = 0; taps < 1 << solver.cells; taps++) {
      final lights = solver.applyTaps(0, taps);
      final count = SwitchSolver.bitCount(taps);
      final best = minimal[lights];
      if (best == null || count < best) minimal[lights] = count;
    }
    return minimal;
  }

  group('SwitchSolver', () {
    const solver = SwitchSolver();

    test('a tap toggles the cell and its 4 neighbours, fewer on edges and corners', () {
      expect(SwitchSolver.bitCount(solver.toggleMask(0)), 3); // corner
      expect(SwitchSolver.bitCount(solver.toggleMask(2)), 4); // edge
      expect(SwitchSolver.bitCount(solver.toggleMask(12)), 5); // center
      expect(solver.toggleMask(12), (1 << 12) | (1 << 7) | (1 << 17) | (1 << 11) | (1 << 13));
      expect(solver.toggleMask(24), (1 << 24) | (1 << 19) | (1 << 23));
    });

    test('a single tap is solved by that tap', () {
      for (var i = 0; i < solver.cells; i++) {
        final lights = solver.toggleMask(i);
        expect(solver.minimalSolution(lights), 1 << i);
        expect(solver.minimalMoves(lights), 1);
      }
    });

    test('a single lit corner can not be solved on 5x5', () {
      expect(solver.isSolvable(1), isFalse);
      expect(solver.solutions(1), isEmpty);
      expect(solver.minimalSolution(1), isNull);
      expect(solver.minimalMoves(1), isNull);
    });

    test('a dark board needs no taps', () {
      expect(solver.minimalSolution(0), 0);
      expect(solver.minimalMoves(0), 0);
    });

    test('every solvable 5x5 board has 4 solutions that all turn the lights off', () {
      final random = Random(42);
      for (var i = 0; i < 200; i++) {
        final lights = solver.applyTaps(0, random.nextInt(1 << solver.cells));
        final solutions = solver.solutions(lights);
        expect(solutions.toSet(), hasLength(4));
        for (final taps in solutions) {
          expect(solver.applyTaps(lights, taps), 0);
        }
        final minimal = solver.minimalSolution(lights)!;
        expect(solutions.every((taps) => SwitchSolver.bitCount(taps) >= SwitchSolver.bitCount(minimal)), isTrue);
      }
    });

    for (final size in [1, 2, 3, 4]) {
      test('matches a brute force search on every ${size}x$size board', () {
        final small = SwitchSolver(size: size);
        final minimal = bruteForce(small);
        for (var lights = 0; lights < 1 << small.cells; lights++) {
          expect(small.minimalMoves(lights), minimal[lights], reason: 'board $lights');
          final solution = small.minimalSolution(lights);
          if (solution != null) expect(small.applyTaps(lights, solution), 0);
        }
      });
    }
  });

  group('SwitchPuzzle', () {
    test('parses a string and computes par', () {
      final puzzle = SwitchPuzzle.fromString('.#... ###.. .#... ..... .....', name: 'Plus');
      expect(puzzle.size, 5);
      expect(puzzle.name, 'Plus');
      expect(puzzle.isLit(0, 1), isTrue);
      expect(puzzle.isLit(1, 1), isTrue);
      expect(puzzle.isLit(0, 0), isFalse);
      expect(puzzle.par, 1);
    });

    test('supports smaller boards', () {
      final puzzle = SwitchPuzzle.fromString('#.# ... #.#');
      expect(puzzle.size, 3);
      expect(puzzle.par, greaterThan(0));
    });

    test('rejects dark, unsolvable, non-square and unknown boards', () {
      expect(() => SwitchPuzzle.fromString('.........'), throwsArgumentError);
      expect(() => SwitchPuzzle.fromString('#.... ..... ..... ..... .....'), throwsArgumentError);
      expect(() => SwitchPuzzle.fromString('##...'), throwsArgumentError);
      expect(() => SwitchPuzzle.fromString(''), throwsArgumentError);
      expect(() => SwitchPuzzle.fromString('#?.. .... .... ....'), throwsArgumentError);
      expect(() => SwitchPuzzle.fromMask(1, size: 6), throwsArgumentError);
    });
  });

  group('SwitchPuzzleGenerator', () {
    for (final difficulty in SwitchDifficulty.values) {
      test('generates solvable ${difficulty.name} puzzles with par up to ${difficulty.taps}', () {
        const solver = SwitchSolver();
        for (var seed = 0; seed < 50; seed++) {
          final puzzle = SwitchPuzzleGenerator(random: Random(seed)).generate(difficulty);
          expect(puzzle.size, 5);
          expect(puzzle.lights, isNot(0));
          expect(solver.isSolvable(puzzle.lights), isTrue);
          expect(puzzle.par, inInclusiveRange(1, difficulty.taps));
          expect(puzzle.par, solver.minimalMoves(puzzle.lights));
        }
      });
    }

    test('is reproducible with a seeded random', () {
      final a = SwitchPuzzleGenerator(random: Random(7));
      final b = SwitchPuzzleGenerator(random: Random(7));
      for (var i = 0; i < 10; i++) {
        expect(a.generate(SwitchDifficulty.hard).lights, b.generate(SwitchDifficulty.hard).lights);
      }
    });

    test('easy puzzles are mostly at par 3, harder ones need more taps on average', () {
      double averagePar(SwitchDifficulty difficulty) {
        final generator = SwitchPuzzleGenerator(random: Random(1));
        var total = 0;
        for (var i = 0; i < 100; i++) {
          total += generator.generate(difficulty).par;
        }
        return total / 100;
      }

      final averages = [for (final difficulty in SwitchDifficulty.values) averagePar(difficulty)];
      for (var i = 1; i < averages.length; i++) {
        expect(averages[i], greaterThan(averages[i - 1]));
      }
    });
  });
}
