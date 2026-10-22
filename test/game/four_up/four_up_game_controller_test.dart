import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';
import 'package:flutter_mini_games/src/game/four_up/game/logic/four_up_game_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const bottomRow = FourUpGameController.rows - 1;

  FourUpGameController play(List<int> columns) {
    final controller = FourUpGameController();
    for (final col in columns) {
      expect(controller.dropDisc(col), isNotNull, reason: 'column $col');
    }
    return controller;
  }

  group('FourUpGameController', () {
    test('discs fall to the lowest free row and the players alternate', () {
      final controller = FourUpGameController();
      expect(controller.currentPlayer, DuelPlayer.bottom);

      expect(controller.dropDisc(3), bottomRow);
      expect(controller.cellAt(3, bottomRow), DuelPlayer.bottom);
      expect(controller.currentPlayer, DuelPlayer.top);

      expect(controller.dropDisc(3), bottomRow - 1);
      expect(controller.cellAt(3, bottomRow - 1), DuelPlayer.top);
      expect(controller.lastMove, (col: 3, row: bottomRow - 1));
      expect(controller.moves, 2);
      expect(controller.status, GameStatus.playing);
    });

    test('a full column takes no more discs', () {
      final controller = play([0, 0, 0, 0, 0, 0]);
      expect(controller.canDrop(0), isFalse);

      expect(controller.dropDisc(0), isNull);
      expect(controller.moves, 6);
      expect(controller.currentPlayer, DuelPlayer.bottom);
      expect(controller.dropDisc(-1), isNull);
      expect(controller.dropDisc(FourUpGameController.columns), isNull);
    });

    test('wins horizontally', () {
      // Bottom: 0 1 2 3 on the bottom row, top stacks on 0 1 2
      final controller = play([0, 0, 1, 1, 2, 2, 3]);

      expect(controller.winner, DuelPlayer.bottom);
      expect(controller.winningCells, {for (var col = 0; col < 4; col++) (col: col, row: bottomRow)});
    });

    test('wins vertically', () {
      final controller = play([0, 1, 0, 1, 0, 1, 0]);

      expect(controller.winner, DuelPlayer.bottom);
      expect(controller.winningCells, {for (var row = bottomRow - 3; row <= bottomRow; row++) (col: 0, row: row)});
    });

    test('wins on the rising diagonal', () {
      // Bottom: (0,5) (1,4) (2,3) (3,2)
      final controller = play([0, 1, 1, 2, 2, 3, 2, 3, 3, 6, 3]);

      expect(controller.winner, DuelPlayer.bottom);
      expect(controller.winningCells, {
        (col: 0, row: bottomRow),
        (col: 1, row: bottomRow - 1),
        (col: 2, row: bottomRow - 2),
        (col: 3, row: bottomRow - 3),
      });
    });

    test('wins on the falling diagonal', () {
      // Mirror of the rising diagonal: bottom: (6,5) (5,4) (4,3) (3,2)
      final controller = play([6, 5, 5, 4, 4, 3, 4, 3, 3, 0, 3]);

      expect(controller.winner, DuelPlayer.bottom);
      expect(controller.winningCells, {
        (col: 6, row: bottomRow),
        (col: 5, row: bottomRow - 1),
        (col: 4, row: bottomRow - 2),
        (col: 3, row: bottomRow - 3),
      });
    });

    test('the top player can win and the winning line holds every disc of a line of five', () {
      // Bottom on the bottom row: 0 1 3 4, then 2 connects five
      final controller = play([0, 0, 1, 1, 3, 3, 4, 4, 6, 6, 2]);
      expect(controller.winner, DuelPlayer.bottom);
      expect(controller.winningCells.length, 5);

      final top = play([6, 0, 6, 1, 5, 2, 5, 3]);
      expect(top.winner, DuelPlayer.top);
      expect(top.result?.data['winner'], 'top');
    });

    test('finishes with the winner in the result data and ignores further moves', () {
      final controller = play([0, 1, 0, 1, 0, 1, 0]);

      expect(controller.isGameOver, isTrue);
      expect(controller.result?.gameId, FourUpGameController.id);
      expect(controller.result?.outcome, GameOutcome.won);
      expect(controller.result?.data['winner'], 'bottom');
      expect(controller.result?.score, isNull);
      expect(controller.result?.moves, 7);

      expect(controller.dropDisc(5), isNull);
      expect(controller.moves, 7);
    });

    test('a full grid without four in a row is a draw', () {
      // Pairs of columns alternate, rows alternate: no line of four anywhere
      //   t t b b t t b
      //   b b t t b b t
      //   ...
      //   b b t t b b t  (bottom row)
      DuelPlayer target(int col, int heightFromBottom) => (col ~/ 2 + heightFromBottom).isEven ? DuelPlayer.bottom : DuelPlayer.top;
      final columns = _findMoveOrder(target);
      final controller = FourUpGameController();
      for (final col in columns) {
        controller.dropDisc(col);
      }

      expect(controller.winner, isNull, reason: _render(controller));
      expect(controller.isDraw, isTrue);
      expect(controller.moves, FourUpGameController.columns * FourUpGameController.rows);
      expect(controller.result?.outcome, GameOutcome.draw);
      expect(controller.result?.data.containsKey('winner'), isFalse);
    });

    test('selects a column with the keyboard and drops in it', () {
      final controller = FourUpGameController()..moveSelection(1);
      expect(controller.selectedColumn, 3);

      controller
        ..moveSelection(-1)
        ..moveSelection(-1)
        ..moveSelection(-1)
        ..moveSelection(-1);
      expect(controller.selectedColumn, 6);

      expect(controller.dropSelected(), bottomRow);
      expect(controller.cellAt(6, bottomRow), DuelPlayer.bottom);

      controller.clearSelection();
      expect(controller.dropSelected(), isNull);
    });

    test('reset starts a new session with the other player', () {
      final controller = play([0, 1, 0, 1, 0, 1, 0])..resetGame();

      expect(controller.moves, 0);
      expect(controller.status, GameStatus.ready);
      expect(controller.result, isNull);
      expect(controller.winner, isNull);
      expect(controller.winningCells, isEmpty);
      expect(controller.lastMove, isNull);
      expect(controller.currentPlayer, DuelPlayer.top);
      for (var row = 0; row < FourUpGameController.rows; row++) {
        for (var col = 0; col < FourUpGameController.columns; col++) {
          expect(controller.cellAt(col, row), isNull);
        }
      }

      controller.resetGame();
      expect(controller.currentPlayer, DuelPlayer.bottom);
    });
  });
}

String _render(FourUpGameController controller) {
  final buffer = StringBuffer('\n');
  for (var row = 0; row < FourUpGameController.rows; row++) {
    for (var col = 0; col < FourUpGameController.columns; col++) {
      buffer.write(switch (controller.cellAt(col, row)) {
        DuelPlayer.bottom => 'b',
        DuelPlayer.top => 't',
        null => '.',
      });
    }
    buffer.writeln();
  }
  return buffer.toString();
}

/// Order of columns that builds the grid of [target] with alternating players, starting with bottom
List<int> _findMoveOrder(DuelPlayer Function(int col, int heightFromBottom) target) {
  final heights = List.filled(FourUpGameController.columns, 0);
  final order = <int>[];
  bool search(DuelPlayer player) {
    if (order.length == FourUpGameController.columns * FourUpGameController.rows) return true;
    for (var col = 0; col < FourUpGameController.columns; col++) {
      final height = heights[col];
      if (height == FourUpGameController.rows || target(col, height) != player) continue;
      heights[col]++;
      order.add(col);
      if (search(player.opponent)) return true;
      heights[col]--;
      order.removeLast();
    }
    return false;
  }

  if (!search(DuelPlayer.bottom)) throw StateError('No move order');
  return order;
}
