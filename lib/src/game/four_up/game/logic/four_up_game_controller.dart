import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';

/// A cell of the grid: [col] from left to right, [row] from top (0) to bottom ([FourUpGameController.rows] - 1)
typedef FourUpCell = ({int col, int row});

/// Turn-based four in a row for two players on one device
class FourUpGameController extends GameController {
  static const id = 'four_up';
  static const columns = 7;
  static const rows = 6;
  static const winLength = 4;

  static const _directions = [(1, 0), (0, 1), (1, 1), (1, -1)];

  /// `_grid[row][col]`, row 0 is the top row
  List<List<DuelPlayer?>> _grid = _emptyGrid();
  DuelPlayer _startingPlayer;
  DuelPlayer _currentPlayer;
  DuelPlayer? _winner;
  bool _isDraw = false;
  Set<FourUpCell> _winningCells = const {};
  FourUpCell? _lastMove;
  int? _selectedColumn;

  FourUpGameController({DuelPlayer startingPlayer = DuelPlayer.bottom}) : _startingPlayer = startingPlayer, _currentPlayer = startingPlayer, super(gameId: id);

  static List<List<DuelPlayer?>> _emptyGrid() => List.generate(rows, (_) => List<DuelPlayer?>.filled(columns, null));

  /// The player whose turn it is
  DuelPlayer get currentPlayer => _currentPlayer;

  /// The player that started the current game; alternates on every new game
  DuelPlayer get startingPlayer => _startingPlayer;

  DuelPlayer? get winner => _winner;

  bool get isDraw => _isDraw;

  bool get isGameOver => _winner != null || _isDraw;

  /// Every disc of the winning line(s), empty while nobody has won
  Set<FourUpCell> get winningCells => _winningCells;

  /// The disc that was dropped last, null at the start of a game
  FourUpCell? get lastMove => _lastMove;

  /// Column selected with the keyboard (or swipes), null when nothing is selected
  int? get selectedColumn => _selectedColumn;

  DuelPlayer? cellAt(int col, int row) => _grid[row][col];

  bool canDrop(int col) => !isGameOver && col >= 0 && col < columns && _grid[0][col] == null;

  /// Drops a disc of the current player in [col]. Returns the row it landed in, or null
  /// when the move is not possible (full column, game over).
  int? dropDisc(int col) {
    if (!canDrop(col)) return null;
    final row = _lowestFreeRow(col);
    final player = _currentPlayer;
    _grid[row][col] = player;
    _lastMove = (col: col, row: row);
    registerMove();

    final line = _winningLinesThrough(col, row, player);
    if (line.isNotEmpty) {
      _winner = player;
      _winningCells = line;
      _selectedColumn = null;
      finish(GameOutcome.won, data: {'winner': player.name});
    } else if (moves == columns * rows) {
      _isDraw = true;
      _selectedColumn = null;
      finish(GameOutcome.draw);
    } else {
      _currentPlayer = player.opponent;
    }
    notifyListeners();
    return row;
  }

  /// Drops a disc in the [selectedColumn], if any
  int? dropSelected() {
    final col = _selectedColumn;
    if (col == null) return null;
    return dropDisc(col);
  }

  /// Moves the selection [delta] columns (wraps around). Selects the middle column first.
  void moveSelection(int delta) {
    if (isGameOver) return;
    final current = _selectedColumn;
    _selectedColumn = current == null ? columns ~/ 2 : (current + delta) % columns;
    notifyListeners();
  }

  void clearSelection() {
    if (_selectedColumn == null) return;
    _selectedColumn = null;
    notifyListeners();
  }

  /// Starts a new game; the other player starts
  void resetGame() {
    _grid = _emptyGrid();
    _startingPlayer = _startingPlayer.opponent;
    _currentPlayer = _startingPlayer;
    _winner = null;
    _isDraw = false;
    _winningCells = const {};
    _lastMove = null;
    _selectedColumn = null;
    restartSession();
    notifyListeners();
  }

  int _lowestFreeRow(int col) {
    for (var row = rows - 1; row >= 0; row--) {
      if (_grid[row][col] == null) return row;
    }
    throw StateError('Column $col is full');
  }

  /// Cells of every line of at least [winLength] discs of [player] through ([col], [row])
  Set<FourUpCell> _winningLinesThrough(int col, int row, DuelPlayer player) {
    final cells = <FourUpCell>{};
    for (final (dc, dr) in _directions) {
      final line = <FourUpCell>[(col: col, row: row)];
      for (final sign in const [1, -1]) {
        var c = col + dc * sign;
        var r = row + dr * sign;
        while (c >= 0 && c < columns && r >= 0 && r < rows && _grid[r][c] == player) {
          line.add((col: c, row: r));
          c += dc * sign;
          r += dr * sign;
        }
      }
      if (line.length >= winLength) cells.addAll(line);
    }
    return cells;
  }
}
