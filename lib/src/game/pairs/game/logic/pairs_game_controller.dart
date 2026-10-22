import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';
import 'package:flutter_mini_games/src/game/pairs/game/model/pairs_card.dart';
import 'package:flutter_mini_games/src/game/pairs/game/model/pairs_difficulty.dart';

/// Memory game: flip two cards at a time, matching pairs stay open.
///
/// A move is one attempt of two cards. Two cards that don't match turn back after
/// [mismatchDelay]; flips are ignored until then.
class PairsGameController extends GameController {
  static const id = 'pairs';

  static const defaultMismatchDelay = Duration(milliseconds: 800);

  final Random _random;

  /// How long two cards that don't match stay open
  final Duration mismatchDelay;
  PairsDifficulty _difficulty;

  /// Value of the card at every position, both cards of a pair share a value
  List<int> _values = [];
  List<bool> _matched = [];

  /// Cards flipped in the current attempt (0, 1 or 2)
  final List<int> _flipped = [];
  Timer? _mismatchTimer;
  int _pairsFound = 0;

  PairsGameController({
    PairsDifficulty difficulty = PairsDifficulty.easy,
    Random? random,
    this.mismatchDelay = defaultMismatchDelay,
  }) : _difficulty = difficulty,
       _random = random ?? Random(),
       super(gameId: id) {
    _startBoard();
  }

  PairsDifficulty get difficulty => _difficulty;
  int get rows => _difficulty.rows;
  int get cols => _difficulty.cols;
  int get cardCount => _difficulty.cards;
  int get totalPairs => _difficulty.pairs;
  int get pairsFound => _pairsFound;
  bool get isWon => result?.outcome == GameOutcome.won;

  /// Two cards that don't match are open: flips are ignored until they turn back
  bool get isShowingMismatch => _mismatchTimer != null;

  /// Indexes of the cards flipped in the current attempt
  List<int> get flipped => List.unmodifiable(_flipped);

  /// Score of a won game: `1000 - moves * 10 - seconds`, never below 100
  static int calculateScore(int moves, Duration elapsed) {
    return max(100, 1000 - moves * 10 - elapsed.inSeconds);
  }

  /// Value of the card at [index], both cards of a pair share it
  int valueAt(int index) => _values[_checkIndex(index)];

  PairsCard cardAt(int index) {
    _checkIndex(index);
    final isFlipped = _flipped.contains(index);
    return PairsCard(
      index: index,
      value: _values[index],
      isFaceUp: isFlipped || _matched[index],
      isMatched: _matched[index],
      isMismatch: isFlipped && isShowingMismatch,
    );
  }

  bool canFlip(int index) {
    _checkIndex(index);
    return !isFinished && !isShowingMismatch && !_matched[index] && !_flipped.contains(index);
  }

  /// Flips the card at [index]. The second card of an attempt counts as a move and
  /// either keeps the pair open or turns both cards back after [mismatchDelay].
  void flip(int index) {
    if (!canFlip(index)) return;
    _flipped.add(index);
    if (_flipped.length == 1) {
      // The timer starts with the first card, the move counts with the second
      startSession();
      notifyListeners();
      return;
    }
    registerMove();
    final first = _flipped[0];
    if (_values[first] == _values[index]) {
      _matched[first] = true;
      _matched[index] = true;
      _pairsFound++;
      _flipped.clear();
      if (_pairsFound == totalPairs) {
        finish(GameOutcome.won, score: calculateScore(moves, elapsed), data: _resultData());
      }
    } else {
      _mismatchTimer = Timer(mismatchDelay, hideMismatch);
    }
    notifyListeners();
  }

  /// Turns the two cards that don't match back, called by the timer after [mismatchDelay]
  void hideMismatch() {
    if (!isShowingMismatch) return;
    _mismatchTimer?.cancel();
    _mismatchTimer = null;
    _flipped.clear();
    notifyListeners();
  }

  /// Starts a new shuffled board
  void resetGame() {
    _startBoard();
    notifyListeners();
  }

  /// Starts a new board, optionally with another difficulty
  void newGame({PairsDifficulty? difficulty}) {
    if (difficulty != null) _difficulty = difficulty;
    resetGame();
  }

  /// Places the cards in the given order instead of shuffling them
  @visibleForTesting
  void setValues(List<int> values) {
    if (values.length != cardCount) throw ArgumentError.value(values, 'values', 'needs $cardCount cards');
    _values = List.of(values);
  }

  void _startBoard() {
    _mismatchTimer?.cancel();
    _mismatchTimer = null;
    _values = [
      for (var value = 0; value < _difficulty.pairs; value++) ...[value, value],
    ]..shuffle(_random);
    _matched = List.filled(_difficulty.cards, false);
    _flipped.clear();
    _pairsFound = 0;
    restartSession();
  }

  Map<String, Object?> _resultData() => {
    'difficulty': _difficulty.name,
    'rows': rows,
    'cols': cols,
    'pairs': totalPairs,
  };

  int _checkIndex(int index) {
    RangeError.checkValueInInterval(index, 0, cardCount - 1, 'index');
    return index;
  }

  @override
  void dispose() {
    _mismatchTimer?.cancel();
    super.dispose();
  }
}
