import 'dart:collection';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';
import 'package:flutter_mini_games/src/game/minesweeper/game/model/minesweeper_cell.dart';
import 'package:flutter_mini_games/src/game/minesweeper/game/model/minesweeper_difficulty.dart';

class MinesweeperGameController extends GameController {
  static const id = 'minesweeper';

  final Random _random;
  MinesweeperDifficulty _difficulty;

  List<bool> _mines = [];
  List<bool> _revealed = [];
  List<bool> _flagged = [];
  List<int> _adjacent = [];
  bool _minesPlaced = false;
  int _mineCount = 0;
  int _revealedCount = 0;
  int _flagCount = 0;
  int? _exploded;
  bool _isFlagMode = false;

  MinesweeperGameController({
    MinesweeperDifficulty difficulty = MinesweeperDifficulty.medium,
    Random? random,
  }) : _difficulty = difficulty,
       _random = random ?? Random(),
       super(gameId: id) {
    _startBoard();
  }

  MinesweeperDifficulty get difficulty => _difficulty;
  int get rows => _difficulty.rows;
  int get cols => _difficulty.cols;
  int get mineCount => _mineCount;
  int get flagCount => _flagCount;
  int get revealedCount => _revealedCount;

  /// Mines minus flags, negative when more cells are flagged than there are mines
  int get remainingMines => _mineCount - _flagCount;

  /// The mines are placed on the first reveal, so the first tap is always safe
  bool get minesPlaced => _minesPlaced;

  /// When on, a tap flags a cell instead of revealing it (alternative for long press)
  bool get isFlagMode => _isFlagMode;
  bool get isWon => result?.outcome == GameOutcome.won;
  bool get isLost => result?.outcome == GameOutcome.lost;

  /// Score of a won game: rewards the difficulty (number of mines) and speed.
  ///
  /// `mines * 100 - seconds * 5`, never lower than `mines * 10`.
  static int calculateScore(MinesweeperDifficulty difficulty, Duration elapsed) {
    return max(difficulty.mines * 10, difficulty.mines * 100 - elapsed.inSeconds * 5);
  }

  MinesweeperCell cellAt(int row, int col) {
    final index = _index(row, col);
    return MinesweeperCell(
      row: row,
      col: col,
      isMine: _mines[index],
      isRevealed: _revealed[index],
      isFlagged: _flagged[index],
      isExploded: _exploded == index,
      adjacentMines: _adjacent[index],
    );
  }

  /// Handles a tap on a cell: flags in flag mode, chords on a revealed number, reveals otherwise
  void tap(int row, int col) {
    if (isFinished) return;
    if (_revealed[_index(row, col)]) {
      chord(row, col);
    } else if (_isFlagMode) {
      toggleFlag(row, col);
    } else {
      reveal(row, col);
    }
  }

  void toggleFlagMode() {
    _isFlagMode = !_isFlagMode;
    notifyListeners();
  }

  /// Reveals a hidden, unflagged cell. Cells without adjacent mines open their neighbours.
  void reveal(int row, int col) {
    if (isFinished) return;
    final index = _index(row, col);
    if (_revealed[index] || _flagged[index]) return;
    if (!_minesPlaced) _placeMines(index);
    registerMove();
    if (_revealCell(index)) {
      _lose(index);
    } else {
      _checkWin();
    }
    notifyListeners();
  }

  /// Flags or unflags a hidden cell
  void toggleFlag(int row, int col) {
    if (isFinished) return;
    final index = _index(row, col);
    if (_revealed[index]) return;
    registerMove();
    _flagged[index] = !_flagged[index];
    _flagCount += _flagged[index] ? 1 : -1;
    notifyListeners();
  }

  /// Reveals all unflagged neighbours of a revealed number when its flags match the number
  void chord(int row, int col) {
    if (isFinished) return;
    final index = _index(row, col);
    if (!_revealed[index] || _adjacent[index] == 0) return;
    final neighbours = _neighbours(index);
    final flags = neighbours.where((n) => _flagged[n]).length;
    if (flags != _adjacent[index]) return;
    final toReveal = neighbours.where((n) => !_revealed[n] && !_flagged[n]).toList();
    if (toReveal.isEmpty) return;
    registerMove();
    int? hitMine;
    for (final neighbour in toReveal) {
      if (_revealCell(neighbour)) hitMine ??= neighbour;
    }
    if (hitMine != null) {
      _lose(hitMine);
    } else {
      _checkWin();
    }
    notifyListeners();
  }

  /// Starts a new board with new mines
  void resetGame() {
    _startBoard();
    notifyListeners();
  }

  /// Starts a new board, optionally with another difficulty
  void newGame({MinesweeperDifficulty? difficulty}) {
    if (difficulty != null) _difficulty = difficulty;
    resetGame();
  }

  /// Places the mines on the given cells instead of randomly on the first reveal
  @visibleForTesting
  void setMines(Iterable<(int row, int col)> mines) {
    _mines = List.filled(_difficulty.cells, false);
    for (final (row, col) in mines) {
      _mines[_index(row, col)] = true;
    }
    _mineCount = _mines.where((mine) => mine).length;
    _computeAdjacent();
    _minesPlaced = true;
  }

  void _startBoard() {
    final cells = _difficulty.cells;
    _mines = List.filled(cells, false);
    _revealed = List.filled(cells, false);
    _flagged = List.filled(cells, false);
    _adjacent = List.filled(cells, 0);
    _minesPlaced = false;
    _mineCount = _difficulty.mines;
    _revealedCount = 0;
    _flagCount = 0;
    _exploded = null;
    restartSession();
  }

  /// Places the mines away from the first revealed cell and its neighbours
  void _placeMines(int firstIndex) {
    var excluded = {firstIndex, ..._neighbours(firstIndex)};
    if (_difficulty.cells - excluded.length < _difficulty.mines) excluded = {firstIndex};
    final candidates = [
      for (var i = 0; i < _difficulty.cells; i++)
        if (!excluded.contains(i)) i,
    ]..shuffle(_random);
    _mines = List.filled(_difficulty.cells, false);
    for (final index in candidates.take(_difficulty.mines)) {
      _mines[index] = true;
    }
    _computeAdjacent();
    _minesPlaced = true;
  }

  void _computeAdjacent() {
    _adjacent = [
      for (var i = 0; i < _difficulty.cells; i++) _neighbours(i).where((n) => _mines[n]).length,
    ];
  }

  /// Reveals a cell and flood fills cells without adjacent mines. Returns true when it is a mine.
  bool _revealCell(int start) {
    if (_mines[start]) return true;
    final queue = Queue<int>()..add(start);
    while (queue.isNotEmpty) {
      final index = queue.removeFirst();
      if (_revealed[index] || _flagged[index]) continue;
      _revealed[index] = true;
      _revealedCount++;
      if (_adjacent[index] == 0) {
        queue.addAll(_neighbours(index).where((n) => !_revealed[n] && !_flagged[n] && !_mines[n]));
      }
    }
    return false;
  }

  void _lose(int index) {
    _exploded = index;
    _revealed[index] = true;
    finish(GameOutcome.lost, data: _resultData());
  }

  void _checkWin() {
    if (_revealedCount < _difficulty.cells - _mineCount) return;
    // Flag the remaining mines, like the classic game
    for (var i = 0; i < _difficulty.cells; i++) {
      if (_mines[i] && !_flagged[i]) {
        _flagged[i] = true;
        _flagCount++;
      }
    }
    finish(GameOutcome.won, score: calculateScore(_difficulty, elapsed), data: _resultData());
  }

  Map<String, Object?> _resultData() => {
    'difficulty': _difficulty.name,
    'rows': rows,
    'cols': cols,
    'mines': mineCount,
    'revealed': _revealedCount,
  };

  int _index(int row, int col) {
    RangeError.checkValueInInterval(row, 0, rows - 1, 'row');
    RangeError.checkValueInInterval(col, 0, cols - 1, 'col');
    return row * cols + col;
  }

  List<int> _neighbours(int index) {
    final row = index ~/ cols;
    final col = index % cols;
    return [
      for (var dr = -1; dr <= 1; dr++)
        for (var dc = -1; dc <= 1; dc++)
          if ((dr != 0 || dc != 0) && row + dr >= 0 && row + dr < rows && col + dc >= 0 && col + dc < cols) (row + dr) * cols + col + dc,
    ];
  }
}
