import 'dart:collection';
import 'dart:math';

import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/controller/realtime_game_controller.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';
import 'package:flutter_mini_games/src/game/tiles/game/model/tiles_row.dart';

/// Tiles: rows of four tiles scroll down, tap the dark tile in every row, lowest row first.
///
/// Positions are in rows: the board is [columns] wide and [visibleRows] high, y grows downwards
/// from the top of the board. Row `n` covers y `topOf(n)` to `topOf(n) + 1`.
///
/// The scroll distance is a closed-form function of the game time ([scrollAt]), so the game does
/// not depend on how [tick] is split into frames.
class TilesGameController extends GameController with RealtimeGameController {
  static const id = 'tiles';

  static const columns = 4;

  /// Height of the board in rows; a tile is a quarter of the board wide and high (3:4 board)
  static const visibleRows = 4.0;

  /// Width / height of the board
  static const boardAspectRatio = 3 / 4;

  /// Top of row 0 before the game starts: the start row is the second row from the bottom
  static const firstRowTop = 2.0;

  /// Scroll speed in rows per second at the start, it grows by [acceleration] per second up to [maxSpeed]
  static const startSpeed = 2.0;
  static const acceleration = 0.05;
  static const maxSpeed = 7.0;

  /// How long a tapped tile flashes, in seconds
  static const flashDuration = 0.25;

  final Random _random;
  final List<TilesRow> _rows = [];
  int _createdRows = 0;
  int _nextRow = 0;
  int _timeMicros = 0;
  double _scroll = 0;
  TilesMistake? _mistake;

  TilesGameController({Random? random}) : _random = random ?? Random(), super(gameId: id) {
    _fillRows();
  }

  /// Rows on (or just above) the board, lowest first
  List<TilesRow> get rows => UnmodifiableListView(_rows);

  /// Index of the lowest row that is not tapped yet
  int get nextRow => _nextRow;

  /// Tiles tapped
  int get score => _nextRow;

  /// Seconds since the first tap
  double get time => _timeMicros / Duration.microsecondsPerSecond;

  /// Rows scrolled since the first tap
  double get scroll => _scroll;

  /// Current scroll speed in rows per second
  double get speed => speedAt(time);

  /// The tile that ended the game, null while playing
  TilesMistake? get mistake => _mistake;

  bool get isReady => status == GameStatus.ready;
  bool get isGameOver => isFinished;

  @override
  bool get isRunning => status == GameStatus.playing;

  /// Scroll speed in rows per second at game time [seconds]
  static double speedAt(double seconds) => min(maxSpeed, startSpeed + acceleration * max(0, seconds));

  /// Rows scrolled after [seconds] of game time (the integral of [speedAt])
  static double scrollAt(double seconds) {
    final t = max(0.0, seconds);
    const rampTime = (maxSpeed - startSpeed) / acceleration;
    if (t <= rampTime) return startSpeed * t + acceleration * t * t / 2;
    const rampScroll = startSpeed * rampTime + acceleration * rampTime * rampTime / 2;
    return rampScroll + maxSpeed * (t - rampTime);
  }

  /// Top of row [index] in rows from the top of the board
  double topOf(int index) => firstRowTop + _scroll - index;

  /// Index of the row at [y] (rows from the top of the board), may be a row that does not exist
  int rowIndexAt(double y) => (firstRowTop + _scroll - y).ceil();

  /// The row with [index], null when it is not on the board
  TilesRow? rowAt(int index) {
    for (final row in _rows) {
      if (row.index == index) return row;
    }
    return null;
  }

  /// How far the flash of a tapped tile is: 0 just tapped, 1 done; null when not tapped
  double? flashOf(TilesRow row) {
    final tappedAt = row.tappedAt;
    if (tappedAt == null) return null;
    return ((time - tappedAt) / flashDuration).clamp(0.0, 1.0);
  }

  /// Tap in [column] at [y] rows from the top of the board.
  ///
  /// The dark tile of the lowest unplayed row scores, a light tile ends the game. Dark tiles
  /// that are already tapped or not next yet are ignored. Before the start only the dark tile
  /// of the first row reacts: it starts the game.
  void tap(int column, double y) {
    if (isFinished || column < 0 || column >= columns) return;
    final row = rowAt(rowIndexAt(y));
    if (row == null) return;
    if (isReady && (row.index != 0 || column != row.darkColumn)) return;

    if (column == row.darkColumn) {
      if (row.index != _nextRow) return;
      registerMove();
      _rows[_rows.indexOf(row)] = row.copyWith(tappedAt: time);
      _nextRow++;
    } else {
      registerMove();
      // Scrolls a row that is partly above the board into view, so the mistake is visible
      if (topOf(row.index) < 0) _scroll -= topOf(row.index);
      _gameOver(TilesMistake(kind: TilesMistakeKind.wrongTile, row: row.index, column: column));
    }
    notifyListeners();
  }

  @override
  void tick(Duration delta) {
    if (!isRunning) return;
    _timeMicros += delta.inMicroseconds;
    _scroll = scrollAt(time);

    if (topOf(_nextRow) >= visibleRows) {
      // Rows are created above the board before they can scroll in, so the next row always exists
      final missed = rowAt(_nextRow) ?? (throw StateError('Row $_nextRow was never created'));
      // Scroll back so the missed tile is visible at the bottom of the board
      _scroll = visibleRows - 1 - firstRowTop + _nextRow;
      _gameOver(TilesMistake(kind: TilesMistakeKind.missedTile, row: missed.index, column: missed.darkColumn));
      notifyListeners();
    } else {
      // Only tapped rows can be below the board here
      _rows.removeWhere((row) => topOf(row.index) >= visibleRows);
      _fillRows();
      // Only the board and the speed change, the score changes on a tap
      notifyFrame();
    }
  }

  void _gameOver(TilesMistake mistake) {
    _mistake = mistake;
    finish(
      GameOutcome.lost,
      score: score,
      data: {'reason': mistake.kind.name, 'speed': double.parse(speed.toStringAsFixed(2))},
    );
  }

  /// Adds rows until the next one would start more than a row above the board
  void _fillRows() {
    while (topOf(_createdRows) > -2) {
      _rows.add(TilesRow(index: _createdRows, darkColumn: _random.nextInt(columns)));
      _createdRows++;
    }
  }

  /// Starts a new game
  void resetGame() {
    restartSession();
    _rows.clear();
    _createdRows = 0;
    _nextRow = 0;
    _timeMicros = 0;
    _scroll = 0;
    _mistake = null;
    _fillRows();
    notifyListeners();
  }
}
