import 'package:flutter_mini_games/src/core/model/data/game_result.dart';
import 'package:flutter_mini_games/src/game/trail/game/logic/trail_game_controller.dart';
import 'package:flutter_mini_games/src/game/trail/game/model/trail_direction.dart';
import 'package:flutter_mini_games/src/game/trail/game/model/trail_puzzle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Tutorial: 3x3 grid, checkpoint 1 at (0,0), checkpoint 2 at (2,2)
  const snakeSolution = [(0, 1), (0, 2), (1, 2), (1, 1), (1, 0), (2, 0), (2, 1), (2, 2)];

  TrailGameController createController() => TrailGameController(puzzles: [TrailPuzzles.tutorial]);

  group('TrailGameController', () {
    test('starts the trail on checkpoint 1', () {
      final controller = createController();

      expect(controller.path, equals([(0, 0)]));
      expect(controller.currentTargetCheckpoint, equals(2));
      expect(controller.canUndo, isFalse);
    });

    test('only allows moves to adjacent empty cells', () {
      final controller = createController();

      expect(controller.canMoveTo(0, 1), isTrue);
      expect(controller.canMoveTo(1, 1), isFalse); // diagonal
      expect(controller.canMoveTo(0, 2), isFalse); // not adjacent
      expect(controller.canMoveTo(0, 0), isFalse); // already filled
    });

    test('wins when every cell is filled and the trail ends on the last checkpoint', () {
      final controller = createController();
      for (final (row, col) in snakeSolution) {
        controller.moveTo(row, col);
      }

      expect(controller.isWon, isTrue);
      expect(controller.isFinished, isTrue);
      expect(controller.canUndo, isFalse);
      expect(controller.result?.outcome, equals(GameOutcome.won));
      expect(controller.result?.moves, equals(snakeSolution.length));
      expect(controller.result?.score, greaterThan(0));
    });

    test('is stuck without finishing the game when no move is left', () {
      final controller = createController();
      for (final (row, col) in [(0, 1), (1, 1), (1, 2), (0, 2)]) {
        controller.moveTo(row, col);
      }

      expect(controller.isStuck, isTrue);
      expect(controller.isFinished, isFalse);
      expect(controller.isWon, isFalse);
    });

    test('undo removes the last step and recovers from being stuck', () {
      final controller = createController();
      for (final (row, col) in [(0, 1), (1, 1), (1, 2), (0, 2)]) {
        controller.moveTo(row, col);
      }

      controller.undo();

      expect(controller.isStuck, isFalse);
      expect(controller.undos, equals(1));
      expect(controller.path, equals([(0, 0), (0, 1), (1, 1), (1, 2)]));
      expect(controller.isInPath(0, 2), isFalse);
    });

    test('undo steps back over a visited checkpoint', () {
      final controller = TrailGameController(
        puzzles: [
          const TrailPuzzle(rows: 3, cols: 3, checkpoints: {1: (0, 0), 2: (0, 1), 3: (2, 2)}),
        ],
      );
      controller.moveTo(0, 1);
      expect(controller.currentTargetCheckpoint, equals(3));

      controller.undo();
      expect(controller.currentTargetCheckpoint, equals(2));
    });

    test('reset restores the starting state', () {
      final controller = createController();
      controller.moveTo(0, 1);
      controller.moveTo(0, 2);

      controller.resetGame();

      expect(controller.path, equals([(0, 0)]));
      expect(controller.filledCells, equals(1));
      expect(controller.isInPath(0, 2), isFalse);
    });

    test('score rewards bigger grids and penalises time and undos', () {
      final base = TrailGameController.calculateScore(totalCells: 25, elapsed: Duration.zero, undos: 0);

      expect(base, equals(500));
      expect(TrailGameController.calculateScore(totalCells: 25, elapsed: const Duration(seconds: 30), undos: 0), equals(470));
      expect(TrailGameController.calculateScore(totalCells: 25, elapsed: Duration.zero, undos: 2), equals(490));
      // Never lower than the number of cells
      expect(TrailGameController.calculateScore(totalCells: 25, elapsed: const Duration(hours: 1), undos: 0), equals(25));
    });

    test('next puzzle starts a new session', () {
      final controller = createController();
      for (final (row, col) in snakeSolution) {
        controller.moveTo(row, col);
      }

      controller.nextPuzzle();

      expect(controller.isFinished, isFalse);
      expect(controller.result, isNull);
      expect(controller.moves, equals(0));
    });

    test('reports trail directions for rendering', () {
      final controller = createController();
      controller.moveTo(0, 1);
      controller.moveTo(1, 1);

      expect(controller.getPathDirections(0, 0), equals({TrailDirection.right}));
      expect(controller.getPathDirections(0, 1), equals({TrailDirection.left, TrailDirection.down}));
      expect(controller.getPathDirections(1, 1), equals({TrailDirection.up}));
      expect(controller.getPathDirections(2, 2), isEmpty);
    });
  });
}
