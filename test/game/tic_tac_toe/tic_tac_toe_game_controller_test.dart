import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';
import 'package:flutter_mini_games/src/game/tic_tac_toe/game/logic/tic_tac_toe_game_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TicTacToeGameController', () {
    test('Player 1 (bottom) starts and the players alternate', () {
      final controller = TicTacToeGameController();
      expect(controller.currentPlayer, equals(DuelPlayer.bottom));

      controller.makeMove(0, 0);
      expect(controller.cellAt(0, 0), equals(DuelPlayer.bottom));
      expect(controller.currentPlayer, equals(DuelPlayer.top));

      controller.makeMove(1, 1);
      expect(controller.cellAt(1, 1), equals(DuelPlayer.top));
      expect(controller.currentPlayer, equals(DuelPlayer.bottom));
    });

    test('ignores taken cells and moves outside the board', () {
      final controller = TicTacToeGameController()
        ..makeMove(0, 0)
        ..makeMove(0, 0)
        ..makeMove(3, 0)
        ..makeMove(0, -1);

      expect(controller.moves, equals(1));
      expect(controller.cellAt(0, 0), equals(DuelPlayer.bottom));
      expect(controller.currentPlayer, equals(DuelPlayer.top));
    });

    test('the board getter is read-only', () {
      final controller = TicTacToeGameController();

      expect(() => controller.board[0][0] = DuelPlayer.top, throwsUnsupportedError);
      expect(() => controller.board[0] = [null, null, null], throwsUnsupportedError);
    });

    test('marks: X for Player 1, O for Player 2', () {
      expect(TicTacToeGameController.markOf(DuelPlayer.bottom), equals('X'));
      expect(TicTacToeGameController.markOf(DuelPlayer.top), equals('O'));
    });

    test('finishes with the bottom player as winner in the result data', () {
      final controller = TicTacToeGameController();
      // Bottom: top row, top: middle row
      for (final (row, col) in [(0, 0), (1, 0), (0, 1), (1, 1), (0, 2)]) {
        controller.makeMove(row, col);
      }

      expect(controller.winner, equals(DuelPlayer.bottom));
      expect(controller.isGameOver, isTrue);
      expect(controller.result?.gameId, equals(TicTacToeGameController.id));
      expect(controller.result?.outcome, equals(GameOutcome.won));
      expect(controller.result?.data['winner'], equals('bottom'));
      expect(controller.result?.score, isNull);
      expect(controller.result?.moves, equals(5));
      expect([for (var col = 0; col < 3; col++) controller.isWinningCell(0, col)], everyElement(isTrue));
      expect(controller.isWinningCell(1, 0), isFalse);
    });

    test('finishes with the top player as winner in the result data', () {
      final controller = TicTacToeGameController();
      // Top: the anti-diagonal
      for (final (row, col) in [(0, 0), (0, 2), (0, 1), (1, 1), (2, 2), (2, 0)]) {
        controller.makeMove(row, col);
      }

      expect(controller.winner, equals(DuelPlayer.top));
      expect(controller.result?.data['winner'], equals('top'));
      expect(controller.isWinningCell(1, 1), isTrue);
      expect(controller.isWinningCell(0, 0), isFalse);
    });

    test('no moves after the game is over', () {
      final controller = TicTacToeGameController();
      for (final (row, col) in [(0, 0), (1, 0), (0, 1), (1, 1), (0, 2)]) {
        controller.makeMove(row, col);
      }

      controller.makeMove(2, 2);

      expect(controller.cellAt(2, 2), isNull);
      expect(controller.moves, equals(5));
    });

    test('finishes as a draw when the board is full', () {
      final controller = TicTacToeGameController();
      // X O X / X O O / O X X
      for (final (row, col) in [(0, 0), (0, 1), (0, 2), (1, 1), (1, 0), (1, 2), (2, 1), (2, 0), (2, 2)]) {
        controller.makeMove(row, col);
      }

      expect(controller.winner, isNull);
      expect(controller.isDraw, isTrue);
      expect(controller.result?.outcome, equals(GameOutcome.draw));
      expect(controller.result?.data.containsKey('winner'), isFalse);
    });

    test('reset starts a new session with Player 1', () {
      final controller = TicTacToeGameController()..makeMove(0, 0);

      controller.resetGame();

      expect(controller.moves, equals(0));
      expect(controller.currentPlayer, equals(DuelPlayer.bottom));
      expect(controller.board.expand((row) => row).every((cell) => cell == null), isTrue);
    });
  });
}
