import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';
import 'package:flutter_mini_games/src/game/boxes/game/logic/boxes_game_controller.dart';
import 'package:flutter_mini_games/src/game/boxes/game/model/boxes_edge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BoxesEdge', () {
    test('a 4x4 grid has 40 edges', () {
      final edges = BoxesEdge.all(rows: 4, cols: 4);
      expect(edges.length, 40);
      expect(edges.toSet().length, 40);
      expect(edges.where((edge) => edge.isHorizontal).length, 20);
    });

    test('adjacent boxes stay inside the grid', () {
      expect(const BoxesEdge.horizontal(0, 1).adjacentBoxes(rows: 4, cols: 4), [(0, 1)]);
      expect(const BoxesEdge.horizontal(2, 1).adjacentBoxes(rows: 4, cols: 4), [(1, 1), (2, 1)]);
      expect(const BoxesEdge.vertical(1, 4).adjacentBoxes(rows: 4, cols: 4), [(1, 3)]);
      expect(const BoxesEdge.vertical(1, 2).adjacentBoxes(rows: 4, cols: 4), [(1, 1), (1, 2)]);
    });

    test('equality by orientation and position', () {
      expect(const BoxesEdge.horizontal(1, 2), const BoxesEdge.horizontal(1, 2));
      expect(const BoxesEdge.horizontal(1, 2), isNot(const BoxesEdge.vertical(1, 2)));
      expect(const BoxesEdge.horizontal(4, 0).isInside(rows: 4, cols: 4), isTrue);
      expect(const BoxesEdge.horizontal(0, 4).isInside(rows: 4, cols: 4), isFalse);
      expect(const BoxesEdge.vertical(4, 0).isInside(rows: 4, cols: 4), isFalse);
    });
  });

  group('BoxesGameController', () {
    test('lines alternate turns when no box is claimed', () {
      final controller = BoxesGameController();
      expect(controller.currentPlayer, DuelPlayer.bottom);

      expect(controller.drawLine(const BoxesEdge.horizontal(0, 0)), isTrue);
      expect(controller.currentPlayer, DuelPlayer.top);
      expect(controller.lineOwner(const BoxesEdge.horizontal(0, 0)), DuelPlayer.bottom);

      controller.drawLine(const BoxesEdge.vertical(0, 0));
      expect(controller.currentPlayer, DuelPlayer.bottom);
      expect(controller.moves, 2);
      expect(controller.lastLine, const BoxesEdge.vertical(0, 0));
    });

    test('a drawn edge or an edge outside the grid is ignored', () {
      final controller = BoxesGameController()..drawLine(const BoxesEdge.horizontal(0, 0));

      expect(controller.drawLine(const BoxesEdge.horizontal(0, 0)), isFalse);
      expect(controller.drawLine(const BoxesEdge.vertical(4, 0)), isFalse);
      expect(controller.currentPlayer, DuelPlayer.top);
      expect(controller.moves, 1);
      expect(controller.lineOwner(const BoxesEdge.horizontal(0, 0)), DuelPlayer.bottom);
    });

    test('closing the fourth side claims the box and gives another turn', () {
      final controller = BoxesGameController()
        ..drawLine(const BoxesEdge.horizontal(0, 0)) // bottom
        ..drawLine(const BoxesEdge.horizontal(1, 0)) // top
        ..drawLine(const BoxesEdge.vertical(0, 0)); // bottom
      expect(controller.currentPlayer, DuelPlayer.top);

      controller.drawLine(const BoxesEdge.vertical(0, 1)); // top closes box (0, 0)

      expect(controller.boxOwner(0, 0), DuelPlayer.top);
      expect(controller.boxesOf(DuelPlayer.top), 1);
      expect(controller.boxesOf(DuelPlayer.bottom), 0);
      expect(controller.currentPlayer, DuelPlayer.top);
    });

    test('one line can claim two boxes', () {
      final controller = BoxesGameController();
      // Boxes (0, 0) and (0, 1) with every side except the shared vertical (0, 1)
      for (final edge in const [
        BoxesEdge.horizontal(0, 0),
        BoxesEdge.horizontal(1, 0),
        BoxesEdge.vertical(0, 0),
        BoxesEdge.horizontal(0, 1),
        BoxesEdge.horizontal(1, 1),
        BoxesEdge.vertical(0, 2),
      ]) {
        controller.drawLine(edge);
      }
      expect(controller.currentPlayer, DuelPlayer.bottom);

      controller.drawLine(const BoxesEdge.vertical(0, 1));

      expect(controller.boxOwner(0, 0), DuelPlayer.bottom);
      expect(controller.boxOwner(0, 1), DuelPlayer.bottom);
      expect(controller.boxesOf(DuelPlayer.bottom), 2);
      expect(controller.currentPlayer, DuelPlayer.bottom);
    });

    test('finishes with the winner and the box counts when every box is claimed', () {
      final controller = BoxesGameController(rows: 1, cols: 2)
        ..drawLine(const BoxesEdge.horizontal(0, 0)) // bottom
        ..drawLine(const BoxesEdge.horizontal(1, 0)) // top
        ..drawLine(const BoxesEdge.horizontal(0, 1)) // bottom
        ..drawLine(const BoxesEdge.horizontal(1, 1)) // top
        ..drawLine(const BoxesEdge.vertical(0, 0)) // bottom
        ..drawLine(const BoxesEdge.vertical(0, 2)); // top
      expect(controller.isGameOver, isFalse);

      controller.drawLine(const BoxesEdge.vertical(0, 1)); // bottom claims both

      expect(controller.isGameOver, isTrue);
      expect(controller.winner, DuelPlayer.bottom);
      expect(controller.result?.gameId, BoxesGameController.id);
      expect(controller.result?.outcome, GameOutcome.won);
      expect(controller.result?.score, isNull);
      expect(controller.result?.moves, 7);
      expect(controller.result?.data['winner'], 'bottom');
      expect(controller.result?.data['boxes'], {'bottom': 2, 'top': 0});
      expect(controller.drawLine(const BoxesEdge.vertical(0, 1)), isFalse);
    });

    test('equal boxes is a draw', () {
      final controller = BoxesGameController(rows: 1, cols: 2)
        ..drawLine(const BoxesEdge.horizontal(0, 0)) // bottom
        ..drawLine(const BoxesEdge.horizontal(1, 0)) // top
        ..drawLine(const BoxesEdge.vertical(0, 1)) // bottom
        ..drawLine(const BoxesEdge.horizontal(0, 1)) // top
        ..drawLine(const BoxesEdge.vertical(0, 0)) // bottom claims (0, 0), plays again
        ..drawLine(const BoxesEdge.horizontal(1, 1)); // bottom
      expect(controller.boxOwner(0, 0), DuelPlayer.bottom);
      expect(controller.currentPlayer, DuelPlayer.top);

      controller.drawLine(const BoxesEdge.vertical(0, 2)); // top claims (0, 1)

      expect(controller.isGameOver, isTrue);
      expect(controller.isDraw, isTrue);
      expect(controller.winner, isNull);
      expect(controller.result?.outcome, GameOutcome.draw);
      expect(controller.result?.data.containsKey('winner'), isFalse);
      expect(controller.result?.data['boxes'], {'bottom': 1, 'top': 1});
    });

    test('reset starts a new session', () {
      final controller = BoxesGameController()
        ..drawLine(const BoxesEdge.horizontal(0, 0))
        ..resetGame();

      expect(controller.moves, 0);
      expect(controller.lines, isEmpty);
      expect(controller.lastLine, isNull);
      expect(controller.currentPlayer, DuelPlayer.bottom);
      expect(controller.claimedCount, 0);
      expect(controller.result, isNull);
    });
  });
}
