import 'dart:math';

import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';
import 'package:flutter_mini_games/src/game/flip/game/logic/flip_game_controller.dart';
import 'package:flutter_test/flutter_test.dart';

/// Board from 8 rows: 'B' = bottom, 'T' = top, '.' = empty; missing rows are empty
List<List<DuelPlayer?>> board(List<String> rows) => [
  for (var row = 0; row < 8; row++)
    [
      for (var col = 0; col < 8; col++)
        switch (row < rows.length ? rows[row][col] : '.') {
          'B' => DuelPlayer.bottom,
          'T' => DuelPlayer.top,
          _ => null,
        },
    ],
];

void main() {
  group('FlipGameController', () {
    test('starts with the standard 4-disc position and Player 1 to move', () {
      final controller = FlipGameController();

      expect(controller.cellAt(3, 3), DuelPlayer.top);
      expect(controller.cellAt(4, 4), DuelPlayer.top);
      expect(controller.cellAt(3, 4), DuelPlayer.bottom);
      expect(controller.cellAt(4, 3), DuelPlayer.bottom);
      expect(controller.countOf(DuelPlayer.bottom), 2);
      expect(controller.countOf(DuelPlayer.top), 2);
      expect(controller.currentPlayer, DuelPlayer.bottom);
      expect(controller.legalMoves, {(2, 3), (3, 2), (4, 5), (5, 4)});
      expect(controller.status, GameStatus.ready);
      expect(controller.isGameOver, isFalse);
    });

    test('a move flips the outflanked disc and passes the turn', () {
      final controller = FlipGameController()..play(2, 3);

      expect(controller.cellAt(2, 3), DuelPlayer.bottom);
      expect(controller.cellAt(3, 3), DuelPlayer.bottom);
      expect(controller.countOf(DuelPlayer.bottom), 4);
      expect(controller.countOf(DuelPlayer.top), 1);
      expect(controller.currentPlayer, DuelPlayer.top);
      expect(controller.legalMoves, {(2, 2), (2, 4), (4, 2)});
      expect(controller.lastMove, (2, 3));
      expect(controller.lastFlipped, {(3, 3)});
      expect(controller.moves, 1);
      expect(controller.status, GameStatus.playing);
    });

    test('flips the lines in all 8 directions at once', () {
      final controller = FlipGameController(
        initialBoard: board([
          '........',
          '.B.B.B..',
          '..TTT...',
          '.BT.TB..',
          '..TTT...',
          '.B.B.B..',
        ]),
      );
      expect(controller.flipsFor(3, 3, DuelPlayer.bottom), hasLength(8));

      controller.play(3, 3);

      expect(controller.countOf(DuelPlayer.top), 0);
      expect(controller.countOf(DuelPlayer.bottom), 17);
    });

    test('flips every disc of a long line and only closed lines', () {
      final controller = FlipGameController(
        initialBoard: board([
          'BTTT.TT.',
          '....T...',
        ]),
      );

      controller.play(0, 4);

      // The 3 discs on the left are closed by B, the 2 on the right are not
      expect(controller.board[0], [for (var col = 0; col < 5; col++) DuelPlayer.bottom, DuelPlayer.top, DuelPlayer.top, null]);
      expect(controller.cellAt(1, 4), DuelPlayer.top);
      expect(controller.lastFlipped, {(0, 1), (0, 2), (0, 3)});
    });

    test('ignores illegal moves', () {
      final controller = FlipGameController();

      controller
        ..play(3, 3) // occupied
        ..play(0, 0) // outflanks nothing
        ..play(2, 2) // diagonal neighbour of an own disc
        ..play(-1, 4) // off the board
        ..play(8, 0);

      expect(controller.moves, 0);
      expect(controller.currentPlayer, DuelPlayer.bottom);
      expect(controller.board, FlipGameController.startBoard());
    });

    test('a player without a legal move passes, the game ends when nobody can move', () {
      final results = <GameResult>[];
      final controller = FlipGameController(
        initialBoard: board([
          'BT......',
          '........',
          '........',
          '........',
          '........',
          '........',
          '........',
          'BT......',
        ]),
      )..resultListener = results.add;

      controller.play(0, 2);
      // Top has no disc that can outflank anything: passes back to bottom
      expect(controller.passedPlayer, DuelPlayer.top);
      expect(controller.currentPlayer, DuelPlayer.bottom);
      expect(controller.legalMoves, {(7, 2)});
      expect(controller.isGameOver, isFalse);

      controller.play(7, 2);
      expect(controller.isGameOver, isTrue);
      expect(controller.legalMoves, isEmpty);
      expect(controller.winner, DuelPlayer.bottom);
      expect(results, hasLength(1));
      expect(results.single.gameId, FlipGameController.id);
      expect(results.single.outcome, GameOutcome.won);
      expect(results.single.score, isNull);
      expect(results.single.moves, 2);
      expect(results.single.data['winner'], 'bottom');
      expect(results.single.data['discs'], {'bottom': 6, 'top': 0});

      // Moves after the end are ignored
      controller.play(1, 1);
      expect(controller.moves, 2);
    });

    test('the starting player passes when they have no move', () {
      final controller = FlipGameController(initialBoard: board(['TB......']));

      expect(controller.currentPlayer, DuelPlayer.top);
      expect(controller.passedPlayer, DuelPlayer.bottom);
      expect(controller.legalMoves, {(0, 2)});
    });

    test('finishes as a draw with equal disc counts', () {
      final controller = FlipGameController(
        initialBoard: board([
          'BT......',
          '........',
          '........',
          '........',
          '........',
          '........',
          '........',
          '.....TTT',
        ]),
      );

      controller.play(0, 2);

      expect(controller.isGameOver, isTrue);
      expect(controller.isDraw, isTrue);
      expect(controller.winner, isNull);
      expect(controller.result?.outcome, GameOutcome.draw);
      expect(controller.result?.data.containsKey('winner'), isFalse);
      expect(controller.result?.data['discs'], {'bottom': 3, 'top': 3});
    });

    test('top wins with more discs', () {
      final controller = FlipGameController(
        initialBoard: board(['TB......', '........', 'TTTT....']),
        startingPlayer: DuelPlayer.top,
      );

      controller.play(0, 2);

      expect(controller.winner, DuelPlayer.top);
      expect(controller.result?.outcome, GameOutcome.won);
      expect(controller.result?.data['winner'], 'top');
      expect(controller.result?.data['discs'], {'bottom': 0, 'top': 7});
    });

    test('random games always end with a consistent result', () {
      final random = Random(42);
      for (var game = 0; game < 20; game++) {
        final controller = FlipGameController();
        while (!controller.isGameOver) {
          final moves = controller.legalMoves.toList();
          expect(moves, isNotEmpty);
          final (row, col) = moves[random.nextInt(moves.length)];
          final player = controller.currentPlayer;
          final flips = controller.flipsFor(row, col, player);
          final before = controller.countOf(player);
          controller.play(row, col);
          expect(controller.countOf(player), before + 1 + flips.length);
        }
        final bottom = controller.countOf(DuelPlayer.bottom);
        final top = controller.countOf(DuelPlayer.top);
        expect(bottom + top, controller.moves + 4);
        expect(controller.movesFor(DuelPlayer.bottom), isEmpty);
        expect(controller.movesFor(DuelPlayer.top), isEmpty);
        expect(controller.result?.data['discs'], {'bottom': bottom, 'top': top});
        if (bottom == top) {
          expect(controller.result?.outcome, GameOutcome.draw);
        } else {
          expect(controller.result?.data['winner'], (bottom > top ? DuelPlayer.bottom : DuelPlayer.top).name);
        }
      }
    });

    test('reset starts a new game', () {
      final controller = FlipGameController()
        ..play(2, 3)
        ..play(2, 2);
      final gameNumber = controller.gameNumber;

      controller.resetGame();

      expect(controller.moves, 0);
      expect(controller.status, GameStatus.ready);
      expect(controller.board, FlipGameController.startBoard());
      expect(controller.currentPlayer, DuelPlayer.bottom);
      expect(controller.lastMove, isNull);
      expect(controller.gameNumber, gameNumber + 1);
    });
  });
}
