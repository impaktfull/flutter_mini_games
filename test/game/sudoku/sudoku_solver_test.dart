import 'dart:math';

import 'package:flutter_mini_games/src/game/sudoku/game/model/sudoku_puzzle.dart';
import 'package:flutter_mini_games/src/game/sudoku/game/model/sudoku_solver.dart';
import 'package:flutter_test/flutter_test.dart';

// Classic puzzle (Wikipedia) with a unique solution
const classic = '53..7....6..195....98....6.8...6...34..8.3..17...2...6.6....28....419..5....8..79';
const classicSolution = '534678912672195348198342567859761423426853791713924856961537284287419635345286179';

List<int> parse(String value) => [for (final char in value.split('')) char == '.' ? 0 : int.parse(char)];

void main() {
  group('SudokuSolver', () {
    test('solves a classic puzzle', () {
      expect(SudokuSolver.solve(parse(classic)), equals(parse(classicSolution)));
      expect(SudokuSolver.countSolutions(parse(classic)), equals(1));
      expect(SudokuSolver.hasUniqueSolution(parse(classic)), isTrue);
    });

    test('counts multiple solutions up to the limit', () {
      final empty = List.filled(81, 0);
      expect(SudokuSolver.countSolutions(empty), equals(2));
      expect(SudokuSolver.countSolutions(empty, limit: 5), equals(5));
      expect(SudokuSolver.hasUniqueSolution(empty), isFalse);
    });

    test('returns no solution for conflicting or invalid grids', () {
      final conflict = parse(classic)..[2] = 5; // second 5 in the first row
      expect(SudokuSolver.hasNoConflicts(conflict), isFalse);
      expect(SudokuSolver.countSolutions(conflict), equals(0));
      expect(SudokuSolver.solve(conflict), isNull);
      expect(SudokuSolver.countSolutions(List.filled(80, 0)), equals(0));
      expect(SudokuSolver.countSolutions(List.filled(81, 0)..[0] = 10), equals(0));
    });

    test('returns no solution when a valid looking grid has none', () {
      // Row 0 needs a 9 in its last cell, but column 8 already has one
      final cells = List.filled(81, 0);
      for (var col = 0; col < 8; col++) {
        cells[col] = col + 1;
      }
      cells[9 * 4 + 8] = 9;

      expect(SudokuSolver.hasNoConflicts(cells), isTrue);
      expect(SudokuSolver.countSolutions(cells), equals(0));
      expect(SudokuSolver.solve(cells), isNull);
    });

    test('solving an empty grid with a random gives a random valid grid', () {
      final first = SudokuSolver.solve(List.filled(81, 0), random: Random(1))!;
      final second = SudokuSolver.solve(List.filled(81, 0), random: Random(2))!;

      expect(SudokuSolver.isSolved(first), isTrue);
      expect(SudokuSolver.isSolved(second), isTrue);
      expect(first, isNot(equals(second)));
      expect(SudokuSolver.solve(List.filled(81, 0), random: Random(1)), equals(first));
    });

    test('isSolved requires a full grid without conflicts', () {
      expect(SudokuSolver.isSolved(parse(classicSolution)), isTrue);
      expect(SudokuSolver.isSolved(parse(classic)), isFalse);
      final swapped = parse(classicSolution)
        ..[0] = 3
        ..[1] = 5;
      expect(SudokuSolver.isSolved(swapped), isFalse);
    });
  });

  group('SudokuPuzzle', () {
    test('fromString parses givens and calculates the solution', () {
      final puzzle = SudokuPuzzle.fromString(classic, name: 'Classic');

      expect(puzzle.givens, equals(parse(classic)));
      expect(puzzle.solution, equals(parse(classicSolution)));
      expect(puzzle.givenCount, equals(30));
      expect(puzzle.givenAt(0, 0), equals(5));
      expect(puzzle.solutionAt(0, 2), equals(4));
      expect(puzzle.isValid(), isTrue);
    });

    test('fromString accepts 0 for empty cells and ignores whitespace', () {
      final puzzle = SudokuPuzzle.fromString(classic.replaceAll('.', '0').replaceAllMapped(RegExp('.{9}'), (match) => '${match[0]}\n'));
      expect(puzzle.givens, equals(parse(classic)));
    });

    test('fromString rejects invalid input and puzzles without a unique solution', () {
      expect(() => SudokuPuzzle.fromString('123'), throwsArgumentError);
      expect(() => SudokuPuzzle.fromString(classic.replaceFirst('5', 'x')), throwsArgumentError);
      expect(() => SudokuPuzzle.fromString('.' * 81), throwsArgumentError);
    });

    test('isValid detects givens that do not match the solution', () {
      final puzzle = SudokuPuzzle(givens: parse(classic)..[0] = 4, solution: parse(classicSolution));
      expect(puzzle.isValid(), isFalse);
    });
  });
}
