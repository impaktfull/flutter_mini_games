import 'dart:math';

import 'package:flutter_mini_games/src/game/trail/game/model/trail_difficulty.dart';
import 'package:flutter_mini_games/src/game/trail/game/model/trail_puzzle.dart';
import 'package:flutter_mini_games/src/game/trail/game/model/trail_puzzle_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TrailPuzzleGenerator', () {
    late TrailPuzzleGenerator generator;

    setUp(() {
      // Use a fixed seed for reproducible tests
      generator = TrailPuzzleGenerator(random: Random(42));
    });

    group('generate', () {
      test('generates a valid 3x3 puzzle', () {
        final puzzle = generator.generate(rows: 3, cols: 3, checkpointCount: 2);

        expect(puzzle, isNotNull);
        expect(puzzle!.rows, equals(3));
        expect(puzzle.cols, equals(3));
        expect(puzzle.checkpoints.length, equals(2));
        expect(puzzle.isValid(), isTrue);
      });

      test('generates a valid 4x4 puzzle', () {
        final puzzle = generator.generate(rows: 4, cols: 4, checkpointCount: 3);

        expect(puzzle, isNotNull);
        expect(puzzle!.rows, equals(4));
        expect(puzzle.cols, equals(4));
        expect(puzzle.checkpoints.length, equals(3));
        expect(puzzle.isValid(), isTrue);
      });

      test('generates a valid 5x5 puzzle', () {
        final puzzle = generator.generate(rows: 5, cols: 5, checkpointCount: 5);

        expect(puzzle, isNotNull);
        expect(puzzle!.rows, equals(5));
        expect(puzzle.cols, equals(5));
        expect(puzzle.checkpoints.length, equals(5));
        expect(puzzle.isValid(), isTrue);
      });

      test('generates a valid 6x6 puzzle', () {
        final puzzle = generator.generate(rows: 6, cols: 6, checkpointCount: 6);

        expect(puzzle, isNotNull);
        expect(puzzle!.rows, equals(6));
        expect(puzzle.cols, equals(6));
        expect(puzzle.checkpoints.length, equals(6));
        expect(puzzle.isValid(), isTrue);
      });

      test('checkpoints are numbered sequentially starting from 1', () {
        final puzzle = generator.generate(rows: 4, cols: 4, checkpointCount: 4);

        expect(puzzle, isNotNull);
        for (int i = 1; i <= 4; i++) {
          expect(puzzle!.checkpoints.containsKey(i), isTrue);
        }
      });

      test('all checkpoints are within grid bounds', () {
        final puzzle = generator.generate(rows: 5, cols: 5, checkpointCount: 5);

        expect(puzzle, isNotNull);
        for (final pos in puzzle!.checkpoints.values) {
          expect(pos.$1, greaterThanOrEqualTo(0));
          expect(pos.$1, lessThan(5));
          expect(pos.$2, greaterThanOrEqualTo(0));
          expect(pos.$2, lessThan(5));
        }
      });

      test('uses default checkpoint count when not specified', () {
        final puzzle = generator.generate(rows: 5, cols: 5);

        expect(puzzle, isNotNull);
        // Default should be roughly totalCells / 4.5 = 25 / 4.5 ≈ 6
        expect(puzzle!.checkpoints.length, greaterThanOrEqualTo(2));
        expect(puzzle.checkpoints.length, lessThanOrEqualTo(10));
      });

      test('assigns name when provided', () {
        final puzzle = generator.generate(
          rows: 4,
          cols: 4,
          checkpointCount: 3,
          name: 'Test Puzzle',
        );

        expect(puzzle, isNotNull);
        expect(puzzle!.name, equals('Test Puzzle'));
      });

      test('assigns difficulty when provided', () {
        final puzzle = generator.generate(
          rows: 4,
          cols: 4,
          checkpointCount: 3,
          difficulty: TrailDifficulty.medium,
        );

        expect(puzzle, isNotNull);
        expect(puzzle!.difficulty, equals(TrailDifficulty.medium));
      });
    });

    group('generateWithDifficulty', () {
      test('generates easy puzzle', () {
        final puzzle = generator.generateWithDifficulty(TrailDifficulty.easy);

        expect(puzzle, isNotNull);
        expect(puzzle!.rows, equals(3));
        expect(puzzle.cols, equals(3));
        expect(puzzle.checkpoints.length, equals(2));
        expect(puzzle.difficulty, equals(TrailDifficulty.easy));
      });

      test('generates medium puzzle', () {
        final puzzle = generator.generateWithDifficulty(TrailDifficulty.medium);

        expect(puzzle, isNotNull);
        expect(puzzle!.rows, equals(4));
        expect(puzzle.cols, equals(4));
        expect(puzzle.checkpoints.length, greaterThanOrEqualTo(3));
        expect(puzzle.checkpoints.length, lessThanOrEqualTo(4));
        expect(puzzle.difficulty, equals(TrailDifficulty.medium));
      });

      test('generates hard puzzle', () {
        final puzzle = generator.generateWithDifficulty(TrailDifficulty.hard);

        expect(puzzle, isNotNull);
        expect(puzzle!.rows, equals(5));
        expect(puzzle.cols, equals(5));
        expect(puzzle.checkpoints.length, greaterThanOrEqualTo(5));
        expect(puzzle.checkpoints.length, lessThanOrEqualTo(7));
        expect(puzzle.difficulty, equals(TrailDifficulty.hard));
      });

      test('generates expert puzzle', () {
        final puzzle = generator.generateWithDifficulty(TrailDifficulty.expert);

        expect(puzzle, isNotNull);
        expect(puzzle!.rows, equals(6));
        expect(puzzle.cols, equals(6));
        expect(puzzle.checkpoints.length, greaterThanOrEqualTo(6));
        expect(puzzle.checkpoints.length, lessThanOrEqualTo(9));
        expect(puzzle.difficulty, equals(TrailDifficulty.expert));
      });

      test('generates master puzzle', () {
        final puzzle = generator.generateWithDifficulty(TrailDifficulty.master);

        expect(puzzle, isNotNull);
        expect(puzzle!.rows, equals(7));
        expect(puzzle.cols, equals(7));
        expect(puzzle.checkpoints.length, greaterThanOrEqualTo(7));
        expect(puzzle.checkpoints.length, lessThanOrEqualTo(9));
        expect(puzzle.difficulty, equals(TrailDifficulty.master));
      }, timeout: const Timeout(Duration(minutes: 2)));
    });

    group('verifySolvable', () {
      test('generated puzzles are solvable', () {
        // Test multiple generated puzzles
        for (int i = 0; i < 10; i++) {
          final genWithSeed = TrailPuzzleGenerator(random: Random(i));
          final puzzle = genWithSeed.generate(rows: 4, cols: 4, checkpointCount: 3);

          expect(puzzle, isNotNull, reason: 'Puzzle $i should be generated');

          final solution = TrailPuzzleGenerator.verifySolvable(puzzle!);
          expect(
            solution,
            isNotNull,
            reason: 'Puzzle $i should be solvable',
          );
          expect(
            solution!.length,
            equals(16),
            reason: 'Solution should visit all 16 cells',
          );
        }
      });

      test('verifies 3x3 puzzles are solvable', () {
        for (int i = 0; i < 5; i++) {
          final genWithSeed = TrailPuzzleGenerator(random: Random(i * 10));
          final puzzle = genWithSeed.generate(rows: 3, cols: 3, checkpointCount: 2);

          expect(puzzle, isNotNull);
          final solution = TrailPuzzleGenerator.verifySolvable(puzzle!);
          expect(solution, isNotNull);
          expect(solution!.length, equals(9));
        }
      });

      test('verifies 5x5 puzzles are solvable', () {
        for (int i = 0; i < 5; i++) {
          final genWithSeed = TrailPuzzleGenerator(random: Random(i * 100));
          final puzzle = genWithSeed.generate(rows: 5, cols: 5, checkpointCount: 4);

          expect(puzzle, isNotNull);
          final solution = TrailPuzzleGenerator.verifySolvable(puzzle!);
          expect(solution, isNotNull);
          expect(solution!.length, equals(25));
        }
      });

      test('solution starts at checkpoint 1', () {
        final puzzle = generator.generate(rows: 4, cols: 4, checkpointCount: 3);
        expect(puzzle, isNotNull);

        final solution = TrailPuzzleGenerator.verifySolvable(puzzle!);
        expect(solution, isNotNull);
        expect(solution!.first, equals(puzzle.checkpoints[1]));
      });

      test('solution visits checkpoints in order', () {
        final puzzle = generator.generate(rows: 4, cols: 4, checkpointCount: 4);
        expect(puzzle, isNotNull);

        final solution = TrailPuzzleGenerator.verifySolvable(puzzle!);
        expect(solution, isNotNull);

        // Check that each checkpoint appears in the solution in order
        int lastCheckpointIndex = -1;
        for (int checkpointNum = 1; checkpointNum <= puzzle.checkpoints.length; checkpointNum++) {
          final checkpointPos = puzzle.checkpoints[checkpointNum];
          final index = solution!.indexOf(checkpointPos!);
          expect(index, greaterThan(lastCheckpointIndex));
          lastCheckpointIndex = index;
        }
      });

      test('solution starts at checkpoint 1 and ends at last checkpoint', () {
        final puzzle = generator.generate(rows: 4, cols: 4, checkpointCount: 4);
        expect(puzzle, isNotNull);

        final solution = TrailPuzzleGenerator.verifySolvable(puzzle!);
        expect(solution, isNotNull);

        // Solution must start at checkpoint 1
        expect(solution!.first, equals(puzzle.checkpoints[1]));

        // Solution must end at the last checkpoint
        expect(solution.last, equals(puzzle.checkpoints[puzzle.checkpoints.length]));
      });

      test('predefined puzzles are solvable', () {
        final puzzles = [
          TrailPuzzles.tutorial,
          TrailPuzzles.easy1,
          TrailPuzzles.medium1,
          TrailPuzzles.medium2,
          TrailPuzzles.hard1,
        ];

        for (final puzzle in puzzles) {
          final solution = TrailPuzzleGenerator.verifySolvable(puzzle);
          expect(
            solution,
            isNotNull,
            reason: '${puzzle.name} should be solvable',
          );
          expect(
            solution!.length,
            equals(puzzle.rows * puzzle.cols),
            reason: '${puzzle.name} solution should fill all cells',
          );
        }
      });
    });

    group('edge cases', () {
      test('handles minimum grid size (3x3)', () {
        final puzzle = generator.generate(rows: 3, cols: 3, checkpointCount: 2);
        expect(puzzle, isNotNull);
        expect(TrailPuzzleGenerator.verifySolvable(puzzle!), isNotNull);
      });

      test('handles minimum checkpoint count (2)', () {
        final puzzle = generator.generate(rows: 4, cols: 4, checkpointCount: 2);
        expect(puzzle, isNotNull);
        expect(puzzle!.checkpoints.length, equals(2));
        expect(TrailPuzzleGenerator.verifySolvable(puzzle), isNotNull);
      });

      test('handles maximum reasonable checkpoint count', () {
        final puzzle = generator.generate(rows: 4, cols: 4, checkpointCount: 8);
        expect(puzzle, isNotNull);
        expect(puzzle!.checkpoints.length, equals(8));
        expect(TrailPuzzleGenerator.verifySolvable(puzzle), isNotNull);
      });

      test('generates different puzzles with different seeds', () {
        final gen1 = TrailPuzzleGenerator(random: Random(1));
        final gen2 = TrailPuzzleGenerator(random: Random(2));

        final puzzle1 = gen1.generate(rows: 4, cols: 4, checkpointCount: 3);
        final puzzle2 = gen2.generate(rows: 4, cols: 4, checkpointCount: 3);

        expect(puzzle1, isNotNull);
        expect(puzzle2, isNotNull);

        // Puzzles should be different (though technically could be same by chance)
        final checkpoints1 = puzzle1!.checkpoints.values.toList();
        final checkpoints2 = puzzle2!.checkpoints.values.toList();

        // At least one checkpoint position should differ
        bool different = false;
        for (int i = 0; i < checkpoints1.length; i++) {
          if (checkpoints1[i] != checkpoints2[i]) {
            different = true;
            break;
          }
        }
        // This assertion might occasionally fail due to randomness,
        // but with different seeds it should almost always be true
        expect(different, isTrue);
      });
    });

    group('consistency', () {
      test('same seed produces same puzzle', () {
        final gen1 = TrailPuzzleGenerator(random: Random(42));
        final gen2 = TrailPuzzleGenerator(random: Random(42));

        final puzzle1 = gen1.generate(rows: 4, cols: 4, checkpointCount: 3);
        final puzzle2 = gen2.generate(rows: 4, cols: 4, checkpointCount: 3);

        expect(puzzle1, isNotNull);
        expect(puzzle2, isNotNull);
        expect(puzzle1!.checkpoints, equals(puzzle2!.checkpoints));
      });
    });
  });

  group('TrailPuzzle', () {
    test('isValid returns true for valid puzzle', () {
      const puzzle = TrailPuzzle(
        rows: 3,
        cols: 3,
        checkpoints: {1: (0, 0), 2: (2, 2)},
      );
      expect(puzzle.isValid(), isTrue);
    });

    test('isValid returns false for non-sequential checkpoints', () {
      const puzzle = TrailPuzzle(
        rows: 3,
        cols: 3,
        checkpoints: {1: (0, 0), 3: (2, 2)}, // Missing checkpoint 2
      );
      expect(puzzle.isValid(), isFalse);
    });

    test('isValid returns false for out-of-bounds checkpoints', () {
      const puzzle = TrailPuzzle(
        rows: 3,
        cols: 3,
        checkpoints: {1: (0, 0), 2: (5, 5)}, // Out of bounds
      );
      expect(puzzle.isValid(), isFalse);
    });

    test('isValid returns false for empty checkpoints', () {
      const puzzle = TrailPuzzle(
        rows: 3,
        cols: 3,
        checkpoints: {},
      );
      expect(puzzle.isValid(), isFalse);
    });

    test('copyWith creates modified copy', () {
      const original = TrailPuzzle(
        rows: 3,
        cols: 3,
        checkpoints: {1: (0, 0), 2: (2, 2)},
        name: 'Original',
      );

      final copy = original.copyWith(
        name: 'Copy',
        difficulty: TrailDifficulty.medium,
      );

      expect(copy.name, equals('Copy'));
      expect(copy.difficulty, equals(TrailDifficulty.medium));
      expect(copy.rows, equals(3));
      expect(copy.cols, equals(3));
      expect(copy.checkpoints, equals(original.checkpoints));
    });
  });

  group('TrailDifficulty', () {
    test('has correct grid sizes', () {
      expect(TrailDifficulty.easy.gridSize, equals(3));
      expect(TrailDifficulty.medium.gridSize, equals(4));
      expect(TrailDifficulty.hard.gridSize, equals(5));
      expect(TrailDifficulty.expert.gridSize, equals(6));
      expect(TrailDifficulty.master.gridSize, equals(7));
    });

    test('fromValue returns correct difficulty', () {
      expect(TrailDifficulty.fromValue(1), equals(TrailDifficulty.easy));
      expect(TrailDifficulty.fromValue(2), equals(TrailDifficulty.medium));
      expect(TrailDifficulty.fromValue(3), equals(TrailDifficulty.hard));
      expect(TrailDifficulty.fromValue(4), equals(TrailDifficulty.expert));
      expect(TrailDifficulty.fromValue(5), equals(TrailDifficulty.master));
    });

    test('fromValue returns default for invalid value', () {
      expect(TrailDifficulty.fromValue(99), equals(TrailDifficulty.hard));
    });
  });
}
