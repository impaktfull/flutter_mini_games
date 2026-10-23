import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';

/// Turn-based tic tac toe for two players on one device.
/// [DuelPlayer.bottom] (Player 1, X) starts, [DuelPlayer.top] (Player 2, O) follows.
class TicTacToeGameController extends GameController {
  static const id = 'tic_tac_toe';
  static const size = 3;

  static const _lines = [
    [(0, 0), (0, 1), (0, 2)],
    [(1, 0), (1, 1), (1, 2)],
    [(2, 0), (2, 1), (2, 2)],
    [(0, 0), (1, 0), (2, 0)],
    [(0, 1), (1, 1), (2, 1)],
    [(0, 2), (1, 2), (2, 2)],
    [(0, 0), (1, 1), (2, 2)],
    [(0, 2), (1, 1), (2, 0)],
  ];

  /// `_board[row][col]`
  List<List<DuelPlayer?>> _board = _emptyBoard();
  DuelPlayer _currentPlayer = DuelPlayer.bottom;
  DuelPlayer? _winner;
  bool _isDraw = false;
  Set<(int, int)> _winningCells = const {};

  TicTacToeGameController() : super(gameId: id);

  static List<List<DuelPlayer?>> _emptyBoard() => List.generate(size, (_) => List<DuelPlayer?>.filled(size, null));

  /// The mark of [player] on the board: X for Player 1, O for Player 2
  static String markOf(DuelPlayer player) => player == DuelPlayer.bottom ? 'X' : 'O';

  /// Read-only view of the board, `board[row][col]`
  List<List<DuelPlayer?>> get board => List.unmodifiable([for (final row in _board) List<DuelPlayer?>.unmodifiable(row)]);

  DuelPlayer? cellAt(int row, int col) => _board[row][col];

  /// The player whose turn it is
  DuelPlayer get currentPlayer => _currentPlayer;

  DuelPlayer? get winner => _winner;

  bool get isDraw => _isDraw;

  bool get isGameOver => _winner != null || _isDraw;

  void makeMove(int row, int col) {
    if (isGameOver || row < 0 || row >= size || col < 0 || col >= size || _board[row][col] != null) return;

    final player = _currentPlayer;
    _board[row][col] = player;
    registerMove();

    final winningCells = {
      for (final line in _lines)
        if (line.every((cell) => _board[cell.$1][cell.$2] == player)) ...line,
    };
    if (winningCells.isNotEmpty) {
      _winner = player;
      _winningCells = winningCells;
      // Multiplayer: the winning player is passed in the result data
      finish(GameOutcome.won, data: {'winner': player.name});
    } else if (moves == size * size) {
      _isDraw = true;
      finish(GameOutcome.draw);
    } else {
      _currentPlayer = player.opponent;
    }
    notifyListeners();
  }

  void resetGame() {
    _board = _emptyBoard();
    _currentPlayer = DuelPlayer.bottom;
    _winner = null;
    _isDraw = false;
    _winningCells = const {};
    restartSession();
    notifyListeners();
  }

  bool isWinningCell(int row, int col) => _winningCells.contains((row, col));
}
