import 'dart:math';

import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';
import 'package:flutter_mini_games/src/core/widget/input/game_input_detector.dart';
import 'package:flutter_mini_games/src/game/twenty_forty_eight/game/logic/twenty_forty_eight_game_controller.dart';
import 'package:flutter_test/flutter_test.dart';

/// Always picks the first empty cell and spawns a 2, or a 4 when [nextDoubleValue] < 0.1
class _FixedRandom implements Random {
  final double nextDoubleValue;

  _FixedRandom({this.nextDoubleValue = 0.5});

  @override
  int nextInt(int max) => 0;

  @override
  double nextDouble() => nextDoubleValue;

  @override
  bool nextBool() => false;
}

TwentyFortyEightGameController _controller(List<List<int>> board, {Random? random}) => TwentyFortyEightGameController(initialBoard: board, random: random ?? _FixedRandom());

int _tileCount(List<List<int>> board) => board.expand((row) => row).where((value) => value != 0).length;

void main() {
  group('TwentyFortyEightGameController', () {
    group('slides and merges', () {
      test('left: [2,2,2,2] becomes [4,4]', () {
        final controller = _controller([
          [2, 2, 2, 2],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ]);

        expect(controller.move(GameDirection.left), isTrue);

        expect(controller.board[0], equals([4, 4, 2, 0])); // 2 spawned on the first empty cell
        expect(controller.score, equals(8));
      });

      test('left: [2,2,4] becomes [4,4], not 8 (a tile merges once per move)', () {
        final controller = _controller([
          [2, 2, 4, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ]);

        controller.move(GameDirection.left);

        expect(controller.board[0].sublist(0, 2), equals([4, 4]));
        expect(controller.score, equals(4));
      });

      test('right: [4,0,4,4] becomes [0,0,4,8], the tiles closest to the wall merge first', () {
        final controller = _controller([
          [0, 0, 0, 0],
          [4, 0, 4, 4],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ]);

        controller.move(GameDirection.right);

        expect(controller.board[1].sublist(2), equals([4, 8]));
        expect(controller.board[1][1], equals(0));
        expect(controller.score, equals(8));
      });

      test('up: a column of [2,2,2,2] becomes [4,4,0,0]', () {
        final controller = _controller([
          [0, 0, 2, 0],
          [0, 0, 2, 0],
          [0, 0, 2, 0],
          [0, 0, 2, 0],
        ]);

        controller.move(GameDirection.up);

        final column = [for (final row in controller.board) row[2]];
        expect(column, equals([4, 4, 0, 0]));
        expect(controller.score, equals(8));
      });

      test('down: a column of [8,0,8,2] becomes [0,0,16,2]', () {
        final controller = _controller([
          [8, 0, 0, 0],
          [0, 0, 0, 0],
          [8, 0, 0, 0],
          [2, 0, 0, 0],
        ]);

        controller.move(GameDirection.down);

        final column = [for (final row in controller.board) row[0]];
        expect(column.sublist(1), equals([0, 16, 2]));
        expect(controller.score, equals(16));
      });

      test('merged tiles keep the id of the tile closest to the wall and are marked as merged', () {
        final controller = _controller([
          [2, 2, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ]);
        final firstId = controller.tiles.firstWhere((tile) => tile.row == 0 && tile.col == 0).id;

        controller.move(GameDirection.left);

        final merged = controller.tiles.firstWhere((tile) => tile.row == 0 && tile.col == 0);
        expect(merged.id, equals(firstId));
        expect(merged.value, equals(4));
        expect(merged.isMerged, isTrue);
        expect(controller.tiles.where((tile) => tile.isNew), hasLength(1));
      });
    });

    group('spawning', () {
      test('starts with two random tiles of 2 or 4', () {
        final controller = TwentyFortyEightGameController(random: Random(42));

        expect(controller.tiles, hasLength(2));
        expect(controller.tiles.every((tile) => tile.value == 2 || tile.value == 4), isTrue);
      });

      test('the same seed creates the same game', () {
        final a = TwentyFortyEightGameController(random: Random(7));
        final b = TwentyFortyEightGameController(random: Random(7));
        for (final direction in [GameDirection.left, GameDirection.up, GameDirection.right, GameDirection.down]) {
          a.move(direction);
          b.move(direction);
        }

        expect(a.board, equals(b.board));
        expect(a.score, equals(b.score));
      });

      test('spawns exactly one tile after a move that changed the board', () {
        final controller = _controller([
          [0, 0, 0, 2],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ]);

        controller.move(GameDirection.left);

        expect(_tileCount(controller.board), equals(2));
        expect(controller.moves, equals(1));
      });

      test('does not spawn or count a move that did not change the board', () {
        final controller = _controller([
          [2, 4, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ]);
        final before = controller.board;

        expect(controller.move(GameDirection.left), isFalse);
        expect(controller.move(GameDirection.up), isFalse);

        expect(controller.board, equals(before));
        expect(controller.moves, equals(0));
        expect(controller.status, equals(GameStatus.ready));
      });

      test('spawns a 2 with 90% and a 4 with 10% chance', () {
        final two = _controller([
          [0, 0, 0, 2],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ], random: _FixedRandom(nextDoubleValue: 0.1))..move(GameDirection.left);
        final four = _controller([
          [0, 0, 0, 2],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ], random: _FixedRandom(nextDoubleValue: 0.09))..move(GameDirection.left);

        expect(two.board[0], equals([2, 2, 0, 0]));
        expect(four.board[0], equals([2, 4, 0, 0]));
      });
    });

    group('end of the game', () {
      test('reaching 2048 wins with the score', () {
        final controller = _controller([
          [1024, 1024, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ]);

        controller.move(GameDirection.left);

        expect(controller.isWon, isTrue);
        expect(controller.highestTile, equals(2048));
        final result = controller.result!;
        expect(result.gameId, equals(TwentyFortyEightGameController.id));
        expect(result.outcome, equals(GameOutcome.won));
        expect(result.score, equals(2048));
        expect(result.moves, equals(1));
        // Finished games ignore input
        expect(controller.move(GameDirection.right), isFalse);
      });

      test('no moves left finishes as lost with the score', () {
        final controller = _controller([
          [2, 4, 2, 4],
          [4, 2, 4, 2],
          [8, 4, 2, 4],
          [16, 32, 64, 64],
        ]);
        expect(controller.canMove, isTrue);

        // 64 + 64 merge, the spawned tile (3, 0) has no equal neighbour
        controller.move(GameDirection.right);

        expect(controller.board[3], equals([2, 16, 32, 128]));
        expect(controller.canMove, isFalse);
        expect(controller.isGameOver, isTrue);
        final result = controller.result!;
        expect(result.outcome, equals(GameOutcome.lost));
        expect(result.score, equals(128));
        expect(result.moves, equals(1));
      });

      test('a full board with an equal neighbour is not game over', () {
        final controller = _controller([
          [2, 4, 2, 4],
          [4, 2, 4, 2],
          [2, 4, 2, 4],
          [4, 2, 4, 4],
        ]);

        expect(controller.canMove, isTrue);
        expect(controller.isGameOver, isFalse);
      });

      test('reset starts a new session with two tiles', () {
        final controller = TwentyFortyEightGameController(random: Random(1))..move(GameDirection.left);
        controller
          ..move(GameDirection.up)
          ..resetGame();

        expect(controller.moves, equals(0));
        expect(controller.score, equals(0));
        expect(controller.result, isNull);
        expect(controller.tiles, hasLength(2));
        expect(controller.status, equals(GameStatus.ready));
      });
    });
  });
}
