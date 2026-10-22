import 'dart:math';

import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';
import 'package:flutter_mini_games/src/game/sudoku/game/logic/sudoku_game_controller.dart';
import 'package:flutter_mini_games/src/game/sudoku/game/model/sudoku_difficulty.dart';
import 'package:flutter_mini_games/src/game/sudoku/game/model/sudoku_puzzle.dart';
import 'package:flutter_test/flutter_test.dart';

const classic = '53..7....6..195....98....6.8...6...34..8.3..17...2...6.6....28....419..5....8..79';

void main() {
  final puzzle = SudokuPuzzle.fromString(classic, name: 'Classic');

  SudokuGameController createController() => SudokuGameController(puzzles: [puzzle]);

  /// Fills every empty cell with the solution
  void solve(SudokuGameController controller) {
    for (var row = 0; row < 9; row++) {
      for (var col = 0; col < 9; col++) {
        if (controller.isLocked(row, col)) continue;
        controller.select(row, col);
        controller.enterDigit(puzzle.solutionAt(row, col));
      }
    }
  }

  group('SudokuGameController', () {
    test('starts with the givens and nothing selected', () {
      final controller = createController();

      expect(controller.valueAt(0, 0), equals(5));
      expect(controller.isGiven(0, 0), isTrue);
      expect(controller.valueAt(0, 2), equals(0));
      expect(controller.isGiven(0, 2), isFalse);
      expect(controller.selected, isNull);
      expect(controller.correctCells, equals(30));
      expect(controller.difficulty, equals(SudokuDifficulty.hard)); // 30 givens
      expect(controller.status, equals(GameStatus.ready));
    });

    test('selecting a cell highlights its row, column, box and same digits', () {
      final controller = createController()..select(0, 0); // 5

      expect(controller.isSelected(0, 0), isTrue);
      expect(controller.isPeerOfSelected(0, 8), isTrue); // row
      expect(controller.isPeerOfSelected(8, 0), isTrue); // column
      expect(controller.isPeerOfSelected(2, 2), isTrue); // box
      expect(controller.isPeerOfSelected(4, 4), isFalse);
      expect(controller.isPeerOfSelected(0, 0), isFalse);
      expect(controller.hasSameValueAsSelected(4, 4), isFalse); // empty
      expect(controller.hasSameValueAsSelected(1, 5), isTrue); // 6..195 -> (1,5) = 5
      expect(controller.hasSameValueAsSelected(0, 1), isFalse);

      controller.select(0, 0);
      expect(controller.selected, equals((0, 0)));
    });

    test('givens can not be changed', () {
      final controller = createController()
        ..select(0, 0)
        ..enterDigit(1)
        ..erase();

      expect(controller.valueAt(0, 0), equals(5));
      expect(controller.moves, equals(0));
    });

    test('a correct entry is placed, registered and locked', () {
      final controller = createController()
        ..select(0, 2)
        ..enterDigit(4);

      expect(controller.valueAt(0, 2), equals(4));
      expect(controller.isWrong(0, 2), isFalse);
      expect(controller.isLocked(0, 2), isTrue);
      expect(controller.mistakes, equals(0));
      expect(controller.moves, equals(1));
      expect(controller.status, equals(GameStatus.playing));

      controller
        ..enterDigit(1)
        ..erase();
      expect(controller.valueAt(0, 2), equals(4));
      expect(controller.moves, equals(1));
    });

    test('a wrong entry is marked, counted as a mistake and can be replaced', () {
      final controller = createController()
        ..select(0, 2)
        ..enterDigit(1);

      expect(controller.isWrong(0, 2), isTrue);
      expect(controller.mistakes, equals(1));

      // Entering the same wrong digit again is not a new mistake
      controller.enterDigit(1);
      expect(controller.mistakes, equals(1));

      controller.enterDigit(2);
      expect(controller.mistakes, equals(2));

      controller.erase();
      expect(controller.valueAt(0, 2), equals(0));
      expect(controller.isWrong(0, 2), isFalse);
      expect(controller.mistakes, equals(2));

      controller.enterDigit(4);
      expect(controller.isLocked(0, 2), isTrue);
      expect(controller.moves, equals(4));
    });

    test('notes mode toggles pencil marks and correct entries clear them in peers', () {
      final controller = createController()
        ..toggleNotesMode()
        ..select(0, 2)
        ..enterDigit(4)
        ..enterDigit(1)
        ..enterDigit(2)
        ..enterDigit(2);

      expect(controller.isNotesMode, isTrue);
      expect(controller.notesAt(0, 2), equals({4, 1}));
      expect(controller.valueAt(0, 2), equals(0));
      expect(controller.mistakes, equals(0));

      controller
        ..select(0, 3)
        ..enterDigit(4)
        ..enterDigit(6)
        ..toggleNotesMode()
        ..select(0, 2)
        ..enterDigit(4);

      expect(controller.valueAt(0, 2), equals(4));
      expect(controller.notesAt(0, 2), isEmpty);
      // 4 is removed from the notes in the same row
      expect(controller.notesAt(0, 3), equals({6}));
    });

    test('erase clears notes', () {
      final controller = createController()
        ..toggleNotesMode()
        ..select(0, 2)
        ..enterDigit(4)
        ..erase();

      expect(controller.notesAt(0, 2), isEmpty);
    });

    test('marks a digit complete when all nine are placed correctly', () {
      final controller = createController();
      expect(controller.isDigitComplete(5), isFalse);

      solve(controller);
      for (var digit = 1; digit <= 9; digit++) {
        expect(controller.isDigitComplete(digit), isTrue);
      }
    });

    test('wins when every cell matches the solution and reports the result', () {
      final controller = createController();
      final reported = <GameResult>[];
      controller.resultListener = reported.add;

      controller
        ..select(0, 2)
        ..enterDigit(1); // one mistake
      solve(controller);

      expect(controller.isWon, isTrue);
      expect(controller.isFinished, isTrue);
      expect(controller.selected, isNull);
      expect(reported, hasLength(1));
      final result = reported.single;
      expect(result.gameId, equals('sudoku'));
      expect(result.outcome, equals(GameOutcome.won));
      expect(result.moves, equals(51 + 1)); // 51 empty cells + the mistake
      expect(result.score, equals(SudokuGameController.calculateScore(difficulty: SudokuDifficulty.hard, elapsed: result.duration, mistakes: 1)));
      expect(result.data, equals({'puzzle': 'Classic', 'difficulty': 'hard', 'mistakes': 1}));

      // No more input after winning
      controller.select(0, 2);
      expect(controller.selected, isNull);
    });

    test('a wrong entry blocks the win until it is fixed', () {
      final controller = createController();
      solve(controller);
      expect(controller.isWon, isTrue);

      final other = createController();
      // Solve all but one cell, put a wrong digit there
      for (var row = 0; row < 9; row++) {
        for (var col = 0; col < 9; col++) {
          if (other.valueAt(row, col) != 0 || (row, col) == (8, 0)) continue;
          other
            ..select(row, col)
            ..enterDigit(puzzle.solutionAt(row, col));
        }
      }
      final wrong = puzzle.solutionAt(8, 0) % 9 + 1;
      other
        ..select(8, 0)
        ..enterDigit(wrong);
      expect(other.isWon, isFalse);

      other.enterDigit(puzzle.solutionAt(8, 0));
      expect(other.isWon, isTrue);
    });

    test('score rewards difficulty and penalises time and mistakes', () {
      int score(SudokuDifficulty difficulty, {int seconds = 0, int mistakes = 0}) => SudokuGameController.calculateScore(
        difficulty: difficulty,
        elapsed: Duration(seconds: seconds),
        mistakes: mistakes,
      );

      expect(score(SudokuDifficulty.easy), equals(1000));
      expect(score(SudokuDifficulty.medium), equals(1500));
      expect(score(SudokuDifficulty.hard), equals(2000));
      expect(score(SudokuDifficulty.expert), equals(2500));
      expect(score(SudokuDifficulty.medium, seconds: 300), equals(1200));
      expect(score(SudokuDifficulty.medium, mistakes: 3), equals(1350));
      // Never lower than a tenth of the base points
      expect(score(SudokuDifficulty.medium, seconds: 3600, mistakes: 10), equals(150));
      expect(score(SudokuDifficulty.expert, seconds: 3600), equals(250));
    });

    test('reset restores the starting state', () {
      final controller = createController()
        ..select(0, 2)
        ..enterDigit(1)
        ..toggleNotesMode();

      controller.resetGame();

      expect(controller.valueAt(0, 2), equals(0));
      expect(controller.mistakes, equals(0));
      expect(controller.isNotesMode, isFalse);
      expect(controller.selected, isNull);
      expect(controller.moves, equals(0));
      expect(controller.status, equals(GameStatus.ready));
    });

    test('next puzzle plays the list and then generates puzzles', () {
      final second = SudokuPuzzle(givens: puzzle.givens, solution: puzzle.solution, name: 'Second');
      final controller = SudokuGameController(puzzles: [puzzle, second], difficulty: SudokuDifficulty.easy, random: Random(42));
      expect(controller.totalPuzzles, equals(2));
      expect(controller.hasMorePuzzles, isTrue);

      solve(controller);
      controller.nextPuzzle();

      expect(controller.puzzle.name, equals('Second'));
      expect(controller.isFinished, isFalse);
      expect(controller.result, isNull);
      expect(controller.moves, equals(0));
      expect(controller.hasMorePuzzles, isFalse);

      controller.nextPuzzle();
      expect(controller.puzzle.difficulty, equals(SudokuDifficulty.easy));
      expect(controller.puzzle.isValid(), isTrue);
    });

    test('generates a puzzle of the difficulty without a list', () {
      final controller = SudokuGameController(difficulty: SudokuDifficulty.expert, random: Random(1));

      expect(controller.isGeneratedMode, isTrue);
      expect(controller.difficulty, equals(SudokuDifficulty.expert));
      expect(controller.puzzle.isValid(), isTrue);
    });

    test('leaving while playing is reported as abandoned', () {
      final controller = createController();
      final reported = <GameResult>[];
      controller.resultListener = reported.add;
      controller
        ..select(0, 2)
        ..enterDigit(4)
        ..dispose();

      expect(reported.single.outcome, equals(GameOutcome.abandoned));
    });
  });
}
