import 'dart:math';

import 'package:flutter_mini_games/src/game/sudoku/game/model/sudoku_difficulty.dart';
import 'package:flutter_mini_games/src/game/sudoku/game/model/sudoku_puzzle_generator.dart';
import 'package:flutter_mini_games/src/game/sudoku/game/model/sudoku_solver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SudokuPuzzleGenerator', () {
    for (final difficulty in SudokuDifficulty.values) {
      test('generates valid puzzles with a unique solution for ${difficulty.name}', () {
        final generator = SudokuPuzzleGenerator(random: Random(42));
        for (var i = 0; i < 3; i++) {
          final puzzle = generator.generate(difficulty: difficulty);

          expect(puzzle.difficulty, equals(difficulty));
          expect(puzzle.givens, hasLength(81));
          expect(SudokuSolver.isSolved(puzzle.solution), isTrue);
          expect(SudokuSolver.countSolutions(puzzle.givens), equals(1));
          expect(SudokuSolver.solve(puzzle.givens), equals(puzzle.solution));
          for (var cell = 0; cell < 81; cell++) {
            if (puzzle.givens[cell] != 0) expect(puzzle.givens[cell], equals(puzzle.solution[cell]));
          }
          expect(puzzle.isValid(), isTrue);
          // Never fewer givens than the target, and close to it
          expect(puzzle.givenCount, greaterThanOrEqualTo(difficulty.givens));
          expect(puzzle.givenCount, lessThanOrEqualTo(difficulty.givens + 6));
        }
      });
    }

    test('easy and medium reach their target exactly', () {
      final generator = SudokuPuzzleGenerator(random: Random(7));
      expect(generator.generate(difficulty: SudokuDifficulty.easy).givenCount, equals(40));
      expect(generator.generate(difficulty: SudokuDifficulty.medium).givenCount, equals(32));
    });

    test('harder difficulties have fewer givens', () {
      final generator = SudokuPuzzleGenerator(random: Random(3));
      final easy = generator.generate(difficulty: SudokuDifficulty.easy);
      final expert = generator.generate(difficulty: SudokuDifficulty.expert);
      expect(expert.givenCount, lessThan(easy.givenCount));
    });

    test('is reproducible with a seeded random', () {
      final first = SudokuPuzzleGenerator(random: Random(42)).generate(difficulty: SudokuDifficulty.hard);
      final second = SudokuPuzzleGenerator(random: Random(42)).generate(difficulty: SudokuDifficulty.hard);
      final other = SudokuPuzzleGenerator(random: Random(43)).generate(difficulty: SudokuDifficulty.hard);

      expect(second.givens, equals(first.givens));
      expect(second.solution, equals(first.solution));
      expect(other.givens, isNot(equals(first.givens)));
    });

    test('estimates the difficulty from the number of givens', () {
      expect(SudokuDifficulty.fromGivens(45), equals(SudokuDifficulty.easy));
      expect(SudokuDifficulty.fromGivens(33), equals(SudokuDifficulty.medium));
      expect(SudokuDifficulty.fromGivens(28), equals(SudokuDifficulty.hard));
      expect(SudokuDifficulty.fromGivens(22), equals(SudokuDifficulty.expert));
    });
  });
}
