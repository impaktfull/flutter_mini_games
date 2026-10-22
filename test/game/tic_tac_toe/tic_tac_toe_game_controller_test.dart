import 'package:flutter_mini_games/src/core/model/data/game_result.dart';
import 'package:flutter_mini_games/src/game/tic_tac_toe/game/logic/tic_tac_toe_game_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TicTacToeGameController', () {
    test('finishes with the winner in the result data', () {
      final controller = TicTacToeGameController();
      // X: top row, O: middle row
      for (final (row, col) in [(0, 0), (1, 0), (0, 1), (1, 1), (0, 2)]) {
        controller.makeMove(row, col);
      }

      expect(controller.winner, equals('X'));
      expect(controller.result?.gameId, equals(TicTacToeGameController.id));
      expect(controller.result?.outcome, equals(GameOutcome.won));
      expect(controller.result?.data['winner'], equals('X'));
      expect(controller.result?.moves, equals(5));
    });

    test('finishes as a draw when the board is full', () {
      final controller = TicTacToeGameController();
      // X O X / X O O / O X X
      for (final (row, col) in [(0, 0), (0, 1), (0, 2), (1, 1), (1, 0), (1, 2), (2, 1), (2, 0), (2, 2)]) {
        controller.makeMove(row, col);
      }

      expect(controller.winner, isNull);
      expect(controller.result?.outcome, equals(GameOutcome.draw));
    });

    test('reset starts a new session', () {
      final controller = TicTacToeGameController()..makeMove(0, 0);

      controller.resetGame();

      expect(controller.moves, equals(0));
      expect(controller.board.expand((row) => row).every((cell) => cell == null), isTrue);
    });
  });
}
