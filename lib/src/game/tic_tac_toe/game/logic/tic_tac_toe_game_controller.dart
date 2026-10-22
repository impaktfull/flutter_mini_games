import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';

class TicTacToeGameController extends GameController {
  static const id = 'tic_tac_toe';

  List<List<String?>> _board = List.generate(3, (_) => List.filled(3, null));
  bool _isXTurn = true;
  String? _winner;
  bool _isGameOver = false;

  TicTacToeGameController() : super(gameId: id);

  List<List<String?>> get board => _board;

  bool get isXTurn => _isXTurn;

  String? get winner => _winner;

  bool get isGameOver => _isGameOver;

  void makeMove(int row, int col) {
    if (_board[row][col] != null || _isGameOver) return;

    _board[row][col] = _isXTurn ? 'X' : 'O';
    registerMove();
    _isXTurn = !_isXTurn;
    _checkWinner();
    if (_isGameOver) {
      // Multiplayer: the winning player is passed in the result data
      finish(
        _winner == null ? GameOutcome.draw : GameOutcome.won,
        data: {if (_winner != null) 'winner': _winner},
      );
    }
    notifyListeners();
  }

  void resetGame() {
    _board = List.generate(3, (_) => List.filled(3, null));
    _isXTurn = true;
    _winner = null;
    _isGameOver = false;
    restartSession();
    notifyListeners();
  }

  bool isWinningCell(int row, int col) {
    if (_winner == null) return false;

    // Check if this cell is part of the winning line
    // Check row
    if (_board[row][0] == _winner && _board[row][1] == _winner && _board[row][2] == _winner) {
      return true;
    }

    // Check column
    if (_board[0][col] == _winner && _board[1][col] == _winner && _board[2][col] == _winner) {
      return true;
    }

    // Check main diagonal
    if (row == col && _board[0][0] == _winner && _board[1][1] == _winner && _board[2][2] == _winner) {
      return true;
    }

    // Check anti-diagonal
    if (row + col == 2 && _board[0][2] == _winner && _board[1][1] == _winner && _board[2][0] == _winner) {
      return true;
    }

    return false;
  }

  void _checkWinner() {
    // Check rows
    for (int i = 0; i < 3; i++) {
      if (_board[i][0] != null && _board[i][0] == _board[i][1] && _board[i][1] == _board[i][2]) {
        _winner = _board[i][0];
        _isGameOver = true;
        return;
      }
    }

    // Check columns
    for (int i = 0; i < 3; i++) {
      if (_board[0][i] != null && _board[0][i] == _board[1][i] && _board[1][i] == _board[2][i]) {
        _winner = _board[0][i];
        _isGameOver = true;
        return;
      }
    }

    // Check diagonals
    if (_board[0][0] != null && _board[0][0] == _board[1][1] && _board[1][1] == _board[2][2]) {
      _winner = _board[0][0];
      _isGameOver = true;
      return;
    }

    if (_board[0][2] != null && _board[0][2] == _board[1][1] && _board[1][1] == _board[2][0]) {
      _winner = _board[0][2];
      _isGameOver = true;
      return;
    }

    // Check for draw
    if (moves == 9) {
      _isGameOver = true;
    }
  }
}
