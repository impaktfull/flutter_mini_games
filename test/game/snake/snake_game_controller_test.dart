import 'dart:math';

import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';
import 'package:flutter_mini_games/src/core/widget/input/game_input_detector.dart';
import 'package:flutter_mini_games/src/game/snake/game/logic/snake_game_controller.dart';
import 'package:flutter_mini_games/src/game/snake/game/model/snake_cell.dart';
import 'package:flutter_test/flutter_test.dart';

/// Starts the game (the first step is taken right away)
SnakeGameController start(SnakeGameController controller, [GameDirection direction = GameDirection.right]) {
  controller
    ..changeDirection(direction)
    ..tick(Duration.zero);
  return controller;
}

/// Advances exactly one step
void step(SnakeGameController controller) => controller.tick(controller.stepInterval);

GameDirection directionTo(SnakeCell from, SnakeCell to) {
  if (to.x > from.x) return GameDirection.right;
  if (to.x < from.x) return GameDirection.left;
  if (to.y > from.y) return GameDirection.down;
  return GameDirection.up;
}

void main() {
  group('SnakeGameController', () {
    test('starts in the middle, ready, with food on an empty cell', () {
      final controller = SnakeGameController(random: Random(42));

      expect(controller.status, equals(GameStatus.ready));
      expect(controller.isRunning, isFalse);
      expect(controller.snake, equals(const [SnakeCell(7, 7), SnakeCell(6, 7), SnakeCell(5, 7)]));
      expect(controller.food, isNotNull);
      expect(controller.snake, isNot(contains(controller.food)));
    });

    test('does not move before the first swipe', () {
      final controller = SnakeGameController(random: Random(42))..tick(const Duration(seconds: 1));

      expect(controller.head, equals(const SnakeCell(7, 7)));
    });

    test('the first swipe starts the game and takes a step', () {
      final controller = start(SnakeGameController(random: Random(42)), GameDirection.up);

      expect(controller.status, equals(GameStatus.playing));
      expect(controller.isRunning, isTrue);
      expect(controller.moves, equals(1));
      expect(controller.snake, equals(const [SnakeCell(7, 6), SnakeCell(7, 7), SnakeCell(6, 7)]));
      expect(controller.removedTail, equals(const SnakeCell(5, 7)));
    });

    test('a reversing first swipe starts the game in the current direction', () {
      final controller = start(SnakeGameController(random: Random(42)), GameDirection.left);

      expect(controller.isRunning, isTrue);
      expect(controller.head, equals(const SnakeCell(8, 7)));
    });

    test('moves one cell per step interval, independent of the frame rate', () {
      final controller = start(SnakeGameController(random: Random(1)));
      expect(controller.head, equals(const SnakeCell(8, 7)));

      // Many small frames that add up to one interval
      for (var i = 0; i < 18; i++) {
        controller.tick(const Duration(milliseconds: 10));
      }
      expect(controller.head, equals(const SnakeCell(9, 7)));
      expect(controller.snake, hasLength(SnakeGameController.initialLength));

      controller.tick(const Duration(milliseconds: 90));
      expect(controller.head, equals(const SnakeCell(9, 7)));
      expect(controller.stepProgress, closeTo(0.5, 0.001));

      controller.tick(const Duration(milliseconds: 90));
      expect(controller.head, equals(const SnakeCell(10, 7)));
    });

    test('takes several steps when a long delta is passed', () {
      final controller = start(SnakeGameController(random: Random(1)));
      controller.tick(SnakeGameController.initialStepInterval * 3);

      expect(controller.head, equals(const SnakeCell(11, 7)));
    });

    test('ignores reversing and repeating the current direction', () {
      final controller = start(SnakeGameController(random: Random(1)));
      final moves = controller.moves;

      controller
        ..changeDirection(GameDirection.left)
        ..changeDirection(GameDirection.right);
      expect(controller.queuedDirections, isEmpty);
      expect(controller.moves, equals(moves));

      step(controller);
      expect(controller.head, equals(const SnakeCell(9, 7)));
    });

    test('queues two quick direction changes and applies them on the next steps', () {
      final controller = start(SnakeGameController(random: Random(1)));

      controller
        ..changeDirection(GameDirection.up)
        ..changeDirection(GameDirection.left)
        ..changeDirection(GameDirection.down); // queue is full
      expect(controller.queuedDirections, equals([GameDirection.up, GameDirection.left]));
      expect(controller.moves, equals(3));

      step(controller);
      expect(controller.head, equals(const SnakeCell(8, 6)));
      step(controller);
      expect(controller.head, equals(const SnakeCell(7, 6)));
      expect(controller.direction, equals(GameDirection.left));
    });

    test('a queued direction cannot reverse the previous queued one', () {
      final controller = start(SnakeGameController(random: Random(1)));

      controller
        ..changeDirection(GameDirection.up)
        ..changeDirection(GameDirection.down);
      expect(controller.queuedDirections, equals([GameDirection.up]));
    });

    test('eating grows the snake, adds points, spawns new food and speeds up', () {
      final controller = start(SnakeGameController(random: Random(3)));
      final interval = controller.stepInterval;
      expect(interval, equals(SnakeGameController.initialStepInterval));

      // Steer greedily to the food: a snake of 3 cells cannot hit itself
      final food = controller.food!;
      var guard = 0;
      while (controller.score == 0 && guard++ < 100) {
        final head = controller.head;
        final wanted = [
          if (head.x < food.x) GameDirection.right,
          if (head.x > food.x) GameDirection.left,
          if (head.y < food.y) GameDirection.down,
          if (head.y > food.y) GameDirection.up,
          // Food straight behind the head: turn first
          GameDirection.up,
          GameDirection.down,
        ];
        for (final direction in wanted) {
          final target = head.move(direction);
          if (target != controller.snake[1] && target.y >= 0 && target.y < controller.gridSize) {
            controller.changeDirection(direction);
            break;
          }
        }
        step(controller);
      }

      expect(controller.isFinished, isFalse);
      expect(controller.score, equals(SnakeGameController.pointsPerFood));
      expect(controller.snake, hasLength(SnakeGameController.initialLength + 1));
      expect(controller.head, equals(food));
      expect(controller.removedTail, isNull);
      expect(controller.food, isNot(equals(food)));
      expect(controller.snake, isNot(contains(controller.food)));
      expect(controller.stepInterval, equals(interval - SnakeGameController.stepIntervalDecrease));
    });

    test('the step interval never drops below the minimum', () {
      final controller = SnakeGameController(gridSize: 6, random: Random(5));
      _playHamiltonianCycle(controller);

      expect(controller.snake, hasLength(36));
      expect(controller.stepInterval, equals(SnakeGameController.minStepInterval));
    });

    test('hitting a wall loses the game with the score', () {
      final controller = start(SnakeGameController(random: Random(1)));
      // The head is at x = 8, the wall is after x = 14
      for (var i = 0; i < 6; i++) {
        step(controller);
      }
      expect(controller.head, equals(const SnakeCell(14, 7)));
      expect(controller.isFinished, isFalse);

      step(controller);
      expect(controller.isFinished, isTrue);
      expect(controller.isRunning, isFalse);
      expect(controller.isLost, isTrue);
      expect(controller.head, equals(const SnakeCell(14, 7)));
      expect(controller.result?.outcome, equals(GameOutcome.lost));
      expect(controller.result?.score, equals(0));
      expect(controller.result?.gameId, equals(SnakeGameController.id));
      expect(controller.result?.moves, equals(1));

      // Input and ticks are ignored after the game is over
      controller
        ..changeDirection(GameDirection.up)
        ..tick(const Duration(seconds: 1));
      expect(controller.head, equals(const SnakeCell(14, 7)));
    });

    test('hitting itself loses the game', () {
      // Grow to 5 cells, then turn in a tight square
      final controller = SnakeGameController(gridSize: 6, random: Random(5));
      _playHamiltonianCycle(controller, untilLength: 5);
      expect(controller.isFinished, isFalse);

      final directions = [GameDirection.up, GameDirection.left, GameDirection.down, GameDirection.right];
      final start = directions.indexOf(controller.direction);
      var guard = 0;
      while (!controller.isFinished && guard++ < 20) {
        // Turn clockwise every step: a snake of 5 cells bites itself
        final next = directions[(start + guard) % 4];
        controller.changeDirection(next);
        step(controller);
      }

      expect(controller.isLost, isTrue);
      expect(controller.result?.score, equals(2 * SnakeGameController.pointsPerFood));
    });

    test('moving into the cell the tail leaves is allowed', () {
      final controller = SnakeGameController(gridSize: 6, random: Random(5));
      _playHamiltonianCycle(controller, untilLength: 4);
      expect(controller.snake, hasLength(4));

      // A snake of 4 cells turning in a 2x2 square follows its own tail
      final directions = [GameDirection.up, GameDirection.left, GameDirection.down, GameDirection.right];
      final start = directions.indexOf(controller.direction);
      var turns = 0;
      for (var i = 1; i <= 8; i++) {
        final food = controller.food;
        final next = directions[(start + i) % 4];
        final target = controller.head.move(next);
        if (target == food || target.x < 0 || target.y < 0 || target.x >= 6 || target.y >= 6) break;
        controller.changeDirection(next);
        step(controller);
        turns++;
      }
      expect(turns, greaterThan(0));
      expect(controller.isFinished, isFalse);
    });

    test('filling the whole board wins the game', () {
      final controller = SnakeGameController(gridSize: 6, random: Random(5));
      _playHamiltonianCycle(controller);

      expect(controller.isWon, isTrue);
      expect(controller.food, isNull);
      expect(controller.result?.outcome, equals(GameOutcome.won));
      expect(controller.result?.score, equals((36 - SnakeGameController.initialLength) * SnakeGameController.pointsPerFood));
    });

    test('food never spawns on the snake', () {
      for (var seed = 0; seed < 5; seed++) {
        final controller = SnakeGameController(gridSize: 6, random: Random(seed));
        final foods = <SnakeCell>[];
        _playHamiltonianCycle(
          controller,
          onStep: () {
            final food = controller.food;
            if (food == null) return;
            expect(controller.snake, isNot(contains(food)));
            foods.add(food);
          },
        );
        expect(controller.isWon, isTrue);
      }
    });

    test('the same seed gives the same food', () {
      final a = SnakeGameController(random: Random(7));
      final b = SnakeGameController(random: Random(7));

      expect(a.food, equals(b.food));
    });

    test('reset starts a new session', () {
      final controller = start(SnakeGameController(random: Random(1)));
      for (var i = 0; i < 10; i++) {
        step(controller);
      }
      expect(controller.isLost, isTrue);

      controller.resetGame();
      expect(controller.status, equals(GameStatus.ready));
      expect(controller.result, isNull);
      expect(controller.moves, equals(0));
      expect(controller.score, equals(0));
      expect(controller.head, equals(const SnakeCell(7, 7)));
      expect(controller.direction, equals(GameDirection.right));
    });
  });
}

/// Follows a Hamiltonian cycle on a 6x6 board: the snake never hits itself and eventually fills the board.
///
/// Cycle: down column 0, right along row 5, then snake up through columns 1..5 back to (0, 0).
/// The initial snake (1,3) -> (2,3) -> (3,3) lies on it.
void _playHamiltonianCycle(SnakeGameController controller, {int? untilLength, void Function()? onStep}) {
  final next = <SnakeCell, SnakeCell>{};
  final cycle = <SnakeCell>[
    for (var y = 0; y < 6; y++) SnakeCell(0, y),
    for (var x = 1; x < 6; x++) SnakeCell(x, 5),
    for (final y in [4, 3, 2, 1])
      if (y.isEven)
        for (var x = 5; x >= 1; x--) SnakeCell(x, y)
      else
        for (var x = 1; x <= 5; x++) SnakeCell(x, y),
    for (var x = 5; x >= 1; x--) SnakeCell(x, 0),
  ];
  expect(cycle.toSet(), hasLength(36));
  for (var i = 0; i < cycle.length; i++) {
    next[cycle[i]] = cycle[(i + 1) % cycle.length];
  }

  start(controller);
  onStep?.call();
  var guard = 0;
  while (!controller.isFinished && guard++ < 10000) {
    if (untilLength != null && controller.snake.length >= untilLength) return;
    controller.changeDirection(directionTo(controller.head, next[controller.head]!));
    step(controller);
    onStep?.call();
  }
}
