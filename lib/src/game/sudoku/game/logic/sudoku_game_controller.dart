import 'dart:math';

import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';
import 'package:flutter_mini_games/src/game/sudoku/game/model/sudoku_difficulty.dart';
import 'package:flutter_mini_games/src/game/sudoku/game/model/sudoku_puzzle.dart';
import 'package:flutter_mini_games/src/game/sudoku/game/model/sudoku_puzzle_generator.dart';
import 'package:flutter_mini_games/src/game/sudoku/game/model/sudoku_solver.dart';

class SudokuGameController extends GameController {
  static const id = 'sudoku';

  final List<SudokuPuzzle> _puzzles;
  final SudokuDifficulty _difficulty;
  final SudokuPuzzleGenerator _generator;
  int _currentPuzzleIndex = 0;

  SudokuPuzzle _puzzle;
  List<int> _cells = [];

  /// Pencil marks per cell, bit `n` set = note `n`
  List<int> _notes = [];
  (int row, int col)? _selected;
  bool _isNotesMode = false;
  int _mistakes = 0;

  SudokuGameController({
    List<SudokuPuzzle>? puzzles,
    SudokuDifficulty difficulty = SudokuDifficulty.medium,
    Random? random,
  }) : this._(puzzles ?? const [], difficulty, SudokuPuzzleGenerator(random: random));

  SudokuGameController._(this._puzzles, this._difficulty, this._generator)
    : _puzzle = _puzzles.isNotEmpty ? _puzzles.first : _generator.generate(difficulty: _difficulty),
      super(gameId: id) {
    _startPuzzle();
  }

  SudokuPuzzle get puzzle => _puzzle;
  SudokuDifficulty get difficulty => _puzzle.effectiveDifficulty;
  bool get isWon => result?.outcome == GameOutcome.won;
  int get mistakes => _mistakes;
  bool get isNotesMode => _isNotesMode;
  (int row, int col)? get selected => _selected;
  int get currentPuzzleIndex => _currentPuzzleIndex;
  int get totalPuzzles => _puzzles.length;
  bool get hasMorePuzzles => _puzzles.isNotEmpty && _currentPuzzleIndex < _puzzles.length - 1;
  bool get isGeneratedMode => _puzzles.isEmpty;

  /// Number of cells that are filled with the correct digit
  int get correctCells {
    var count = 0;
    for (var i = 0; i < SudokuSolver.cellCount; i++) {
      if (_cells[i] == _puzzle.solution[i]) count++;
    }
    return count;
  }

  void _startPuzzle() {
    _cells = List.of(_puzzle.givens);
    _notes = List.filled(SudokuSolver.cellCount, 0);
    _selected = null;
    _isNotesMode = false;
    _mistakes = 0;
    restartSession();
  }

  static int _index(int row, int col) => row * 9 + col;

  /// Digit in the cell, 0 when empty
  int valueAt(int row, int col) => _cells[_index(row, col)];

  bool isGiven(int row, int col) => _puzzle.givens[_index(row, col)] != 0;

  /// Filled with a digit that does not match the solution
  bool isWrong(int row, int col) {
    final index = _index(row, col);
    return _cells[index] != 0 && _cells[index] != _puzzle.solution[index];
  }

  /// Givens and correct entries can not be changed
  bool isLocked(int row, int col) {
    final index = _index(row, col);
    return _cells[index] != 0 && _cells[index] == _puzzle.solution[index];
  }

  /// Pencil marks of an empty cell
  Set<int> notesAt(int row, int col) {
    final mask = _notes[_index(row, col)];
    return {
      for (var digit = 1; digit <= 9; digit++)
        if (mask & (1 << digit) != 0) digit,
    };
  }

  bool isSelected(int row, int col) => _selected == (row, col);

  /// Same row, column or box as the selected cell (the selected cell excluded)
  bool isPeerOfSelected(int row, int col) {
    final selected = _selected;
    if (selected == null || selected == (row, col)) return false;
    final (selectedRow, selectedCol) = selected;
    return selectedRow == row || selectedCol == col || SudokuSolver.boxOf(selectedRow, selectedCol) == SudokuSolver.boxOf(row, col);
  }

  /// Contains the same digit as the selected cell (the selected cell excluded)
  bool hasSameValueAsSelected(int row, int col) {
    final selected = _selected;
    if (selected == null || selected == (row, col)) return false;
    final value = valueAt(selected.$1, selected.$2);
    return value != 0 && valueAt(row, col) == value;
  }

  /// True when every [digit] is placed correctly, used to dim the number pad
  bool isDigitComplete(int digit) {
    var count = 0;
    for (var i = 0; i < SudokuSolver.cellCount; i++) {
      if (_cells[i] == digit && _puzzle.solution[i] == digit) count++;
    }
    return count == 9;
  }

  void select(int row, int col) {
    if (isFinished) return;
    _selected = (row, col);
    notifyListeners();
  }

  void toggleNotesMode() {
    if (isFinished) return;
    _isNotesMode = !_isNotesMode;
    notifyListeners();
  }

  /// Places [digit] in the selected cell, or toggles it as a note in notes mode
  void enterDigit(int digit) {
    assert(digit >= 1 && digit <= 9, 'Digit must be between 1 and 9');
    final selected = _selected;
    if (isFinished || selected == null) return;
    final (row, col) = selected;
    if (isLocked(row, col)) return;
    final index = _index(row, col);

    if (_isNotesMode) {
      if (_cells[index] != 0) return;
      _notes[index] ^= 1 << digit;
      registerMove();
      notifyListeners();
      return;
    }

    if (_cells[index] == digit) return;
    _cells[index] = digit;
    _notes[index] = 0;
    registerMove();

    if (digit != _puzzle.solution[index]) {
      _mistakes++;
    } else {
      _removeNoteFromPeers(row, col, digit);
      _checkWinCondition();
    }
    notifyListeners();
  }

  /// Clears the entry or the notes of the selected cell
  void erase() {
    final selected = _selected;
    if (isFinished || selected == null) return;
    final (row, col) = selected;
    if (isLocked(row, col)) return;
    final index = _index(row, col);
    if (_cells[index] == 0 && _notes[index] == 0) return;
    _cells[index] = 0;
    _notes[index] = 0;
    registerMove();
    notifyListeners();
  }

  void _removeNoteFromPeers(int row, int col, int digit) {
    final box = SudokuSolver.boxOf(row, col);
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        if (r == row || c == col || SudokuSolver.boxOf(r, c) == box) {
          _notes[_index(r, c)] &= ~(1 << digit);
        }
      }
    }
  }

  void _checkWinCondition() {
    for (var i = 0; i < SudokuSolver.cellCount; i++) {
      if (_cells[i] != _puzzle.solution[i]) return;
    }
    _selected = null;
    _isNotesMode = false;
    finish(
      GameOutcome.won,
      score: calculateScore(difficulty: difficulty, elapsed: elapsed, mistakes: _mistakes),
      data: {
        'puzzle': _puzzle.name,
        'difficulty': difficulty.name,
        'mistakes': _mistakes,
      },
    );
  }

  /// `basePoints - seconds - mistakes * 50`, never lower than `basePoints / 10`.
  ///
  /// Base points per difficulty: easy 1000, medium 1500, hard 2000, expert 2500.
  static int calculateScore({
    required SudokuDifficulty difficulty,
    required Duration elapsed,
    required int mistakes,
  }) {
    final penalty = elapsed.inSeconds + mistakes * 50;
    return max(difficulty.basePoints ~/ 10, difficulty.basePoints - penalty);
  }

  void resetGame() {
    _startPuzzle();
    notifyListeners();
  }

  /// Load the next puzzle in the list, or generate a new one if in generated mode
  void nextPuzzle() {
    if (hasMorePuzzles) {
      _currentPuzzleIndex++;
      _puzzle = _puzzles[_currentPuzzleIndex];
    } else {
      _puzzle = _generator.generate(difficulty: _difficulty);
    }
    resetGame();
  }
}
