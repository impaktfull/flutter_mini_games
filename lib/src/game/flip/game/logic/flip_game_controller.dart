import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';

/// A cell on the board: (row, col), row 0 is the top row
typedef FlipCell = (int row, int col);

/// Reversi for two players on one device, turn based.
///
/// [DuelPlayer.bottom] moves first. A move must outflank at least one line of opponent discs,
/// all outflanked discs flip. A player without a legal move passes automatically, the game
/// ends when neither player can move: most discs wins, equal is a draw.
class FlipGameController extends GameController {
  static const id = 'flip';
  static const size = 8;

  static const List<FlipCell> directions = [
    (-1, -1),
    (-1, 0),
    (-1, 1),
    (0, -1),
    (0, 1),
    (1, -1),
    (1, 0),
    (1, 1),
  ];

  final List<List<DuelPlayer?>>? _initialBoard;
  final DuelPlayer _startingPlayer;

  late List<List<DuelPlayer?>> _board;
  late DuelPlayer _currentPlayer;
  Set<FlipCell> _legalMoves = {};
  DuelPlayer? _passedPlayer;
  FlipCell? _lastMove;
  Set<FlipCell> _lastFlipped = {};
  bool _isGameOver = false;
  DuelPlayer? _winner;
  int _gameNumber = 0;

  /// [initialBoard] (8x8, rows top to bottom) and [startingPlayer] set up a position for tests
  FlipGameController({
    List<List<DuelPlayer?>>? initialBoard,
    DuelPlayer startingPlayer = DuelPlayer.bottom,
  }) : _initialBoard = initialBoard,
       _startingPlayer = startingPlayer,
       super(gameId: id) {
    assert(initialBoard == null || (initialBoard.length == size && initialBoard.every((row) => row.length == size)));
    _setUp();
  }

  /// Standard start: two discs of each player crossed in the center
  static List<List<DuelPlayer?>> startBoard() {
    final board = List.generate(size, (_) => List<DuelPlayer?>.filled(size, null));
    const low = size ~/ 2 - 1;
    const high = size ~/ 2;
    board[low][low] = DuelPlayer.top;
    board[high][high] = DuelPlayer.top;
    board[low][high] = DuelPlayer.bottom;
    board[high][low] = DuelPlayer.bottom;
    return board;
  }

  /// Copy of the board, rows top to bottom
  List<List<DuelPlayer?>> get board => [for (final row in _board) List.unmodifiable(row)];

  DuelPlayer? cellAt(int row, int col) => _board[row][col];

  /// Player to move, also after the game ended (the last player to move)
  DuelPlayer get currentPlayer => _currentPlayer;

  /// Legal moves of [currentPlayer], empty when the game is over
  Set<FlipCell> get legalMoves => _isGameOver ? const {} : _legalMoves;

  bool isLegalMove(int row, int col) => legalMoves.contains((row, col));

  /// The player that had to pass before the current turn, null when nobody passed
  DuelPlayer? get passedPlayer => _passedPlayer;

  FlipCell? get lastMove => _lastMove;

  /// Discs flipped by the last move
  Set<FlipCell> get lastFlipped => _lastFlipped;

  bool get isGameOver => _isGameOver;

  /// Winner of a finished game, null while playing or on a draw
  DuelPlayer? get winner => _winner;

  bool get isDraw => _isGameOver && _winner == null;

  /// Increases on every reset, so the board can start without flip animations
  int get gameNumber => _gameNumber;

  int countOf(DuelPlayer player) => _board.fold(0, (sum, row) => sum + row.where((cell) => cell == player).length);

  /// Opponent discs [player] would flip by placing a disc on ([row], [col]); empty when illegal
  Set<FlipCell> flipsFor(int row, int col, DuelPlayer player) => _flipsFor(_board, row, col, player);

  /// Legal moves of [player] on the current board
  Set<FlipCell> movesFor(DuelPlayer player) => _movesFor(_board, player);

  /// Places a disc of [currentPlayer]; illegal moves are ignored
  void play(int row, int col) {
    if (_isGameOver || row < 0 || row >= size || col < 0 || col >= size) return;
    final flips = _flipsFor(_board, row, col, _currentPlayer);
    if (flips.isEmpty) return;

    _board[row][col] = _currentPlayer;
    for (final (r, c) in flips) {
      _board[r][c] = _currentPlayer;
    }
    _lastMove = (row, col);
    _lastFlipped = flips;
    registerMove();
    _advanceTurn(_currentPlayer.opponent);
    notifyListeners();
  }

  void resetGame() {
    restartSession();
    _gameNumber++;
    _setUp();
    notifyListeners();
  }

  void _setUp() {
    final initial = _initialBoard;
    _board = initial == null ? startBoard() : [for (final row in initial) List<DuelPlayer?>.of(row)];
    _lastMove = null;
    _lastFlipped = {};
    _isGameOver = false;
    _winner = null;
    _passedPlayer = null;
    _advanceTurn(_startingPlayer);
  }

  /// Gives the turn to [next], or passes back when [next] has no move, or ends the game
  void _advanceTurn(DuelPlayer next) {
    final nextMoves = _movesFor(_board, next);
    if (nextMoves.isNotEmpty) {
      _currentPlayer = next;
      _legalMoves = nextMoves;
      _passedPlayer = null;
      return;
    }
    final otherMoves = _movesFor(_board, next.opponent);
    if (otherMoves.isNotEmpty) {
      _currentPlayer = next.opponent;
      _legalMoves = otherMoves;
      _passedPlayer = next;
      return;
    }
    _currentPlayer = next;
    _legalMoves = {};
    _passedPlayer = null;
    _endGame();
  }

  void _endGame() {
    _isGameOver = true;
    final bottom = countOf(DuelPlayer.bottom);
    final top = countOf(DuelPlayer.top);
    final winner = bottom == top ? null : (bottom > top ? DuelPlayer.bottom : DuelPlayer.top);
    _winner = winner;
    final discs = {DuelPlayer.bottom.name: bottom, DuelPlayer.top.name: top};
    // Only a played game is a result: a set up position without moves is not reported
    if (moves == 0) return;
    finish(
      winner == null ? GameOutcome.draw : GameOutcome.won,
      data: {
        if (winner != null) 'winner': winner.name,
        'discs': discs,
      },
    );
  }

  static Set<FlipCell> _movesFor(List<List<DuelPlayer?>> board, DuelPlayer player) => {
    for (var row = 0; row < size; row++)
      for (var col = 0; col < size; col++)
        if (_flipsFor(board, row, col, player).isNotEmpty) (row, col),
  };

  static Set<FlipCell> _flipsFor(List<List<DuelPlayer?>> board, int row, int col, DuelPlayer player) {
    if (board[row][col] != null) return const {};
    final flips = <FlipCell>{};
    for (final (dRow, dCol) in directions) {
      final line = <FlipCell>[];
      var r = row + dRow;
      var c = col + dCol;
      while (r >= 0 && r < size && c >= 0 && c < size && board[r][c] == player.opponent) {
        line.add((r, c));
        r += dRow;
        c += dCol;
      }
      final closed = r >= 0 && r < size && c >= 0 && c < size && board[r][c] == player;
      if (closed && line.isNotEmpty) flips.addAll(line);
    }
    return flips;
  }
}
