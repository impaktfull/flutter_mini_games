import 'dart:math';

import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';
import 'package:flutter_mini_games/src/game/tiles/game/logic/tiles_game_controller.dart';
import 'package:flutter_mini_games/src/game/tiles/game/model/tiles_row.dart';
import 'package:flutter_test/flutter_test.dart';

Duration _seconds(double seconds) => Duration(microseconds: (seconds * Duration.microsecondsPerSecond).round());

/// Ticks in frames of [frame] for [seconds]
void _run(TilesGameController controller, double seconds, {Duration frame = const Duration(milliseconds: 16)}) {
  var left = _seconds(seconds);
  while (left > Duration.zero && controller.isRunning) {
    final step = left < frame ? left : frame;
    controller.tick(step);
    left -= step;
  }
}

/// Middle of row [index] in rows from the top of the board
double _middleOf(TilesGameController controller, int index) => controller.topOf(index) + 0.5;

/// Taps the dark tile of row [index]
void _tapDark(TilesGameController controller, int index) {
  final row = controller.rowAt(index)!;
  controller.tap(row.darkColumn, _middleOf(controller, index));
}

/// Taps a light tile of row [index]
void _tapLight(TilesGameController controller, int index) {
  final row = controller.rowAt(index)!;
  controller.tap((row.darkColumn + 1) % TilesGameController.columns, _middleOf(controller, index));
}

TilesGameController _started({int seed = 42}) {
  final controller = TilesGameController(random: Random(seed));
  _tapDark(controller, 0);
  return controller;
}

void main() {
  group('TilesGameController', () {
    test('creates rows with exactly one dark tile, covering the board', () {
      final controller = TilesGameController(random: Random(42));
      expect(controller.isReady, isTrue);
      expect(controller.isRunning, isFalse);
      final rows = controller.rows;
      expect(rows.map((row) => row.index), equals([0, 1, 2, 3]));
      for (final row in rows) {
        expect(row.darkColumn, inInclusiveRange(0, TilesGameController.columns - 1));
        expect(row.isTapped, isFalse);
      }
      // The start row is the second one from the bottom, the next rows fill the board up to the top
      expect(controller.topOf(0), equals(TilesGameController.firstRowTop));
      expect(controller.topOf(2), equals(0));
      expect(controller.topOf(3), lessThan(0));
    });

    test('the same seed gives the same rows', () {
      List<int> columns(int seed) {
        final controller = _started(seed: seed);
        _run(controller, 1.5);
        return [for (final row in controller.rows) row.darkColumn];
      }

      expect(columns(7), equals(columns(7)));
      final a = TilesGameController(random: Random(1));
      final b = TilesGameController(random: Random(2));
      final c = TilesGameController(random: Random(3));
      final layouts = {
        for (final controller in [a, b, c]) controller.rows.map((row) => row.darkColumn).join(),
      };
      expect(layouts.length, greaterThan(1));
    });

    test('uses every column for the dark tiles', () {
      final controller = _started();
      final seen = <int>{};
      for (var i = 1; i < 60; i++) {
        _run(controller, 0.3);
        if (controller.rowAt(i) == null) break;
        seen.add(controller.rowAt(i)!.darkColumn);
        _tapDark(controller, i);
      }
      expect(seen, equals({0, 1, 2, 3}));
    });

    test('nothing moves and only the start tile reacts before the start', () {
      final controller = TilesGameController(random: Random(42));
      controller.tick(const Duration(seconds: 1));
      expect(controller.scroll, equals(0));

      // Light tile of the start row, dark tile of a later row, the empty strip below the start row
      _tapLight(controller, 0);
      _tapDark(controller, 1);
      controller.tap(0, 3.5);
      expect(controller.isReady, isTrue);
      expect(controller.moves, equals(0));
      expect(controller.score, equals(0));
    });

    test('the start tile starts the game and scores', () {
      final controller = _started();
      expect(controller.status, equals(GameStatus.playing));
      expect(controller.isRunning, isTrue);
      expect(controller.score, equals(1));
      expect(controller.moves, equals(1));
      expect(controller.nextRow, equals(1));
      expect(controller.rowAt(0)!.isTapped, isTrue);
    });

    test('rows scroll down and speed up over time', () {
      final controller = _started();
      expect(controller.speed, equals(TilesGameController.startSpeed));

      _run(controller, 0.4);
      expect(controller.scroll, closeTo(TilesGameController.scrollAt(0.4), 1e-9));
      expect(controller.topOf(1), closeTo(TilesGameController.firstRowTop - 1 + TilesGameController.scrollAt(0.4), 1e-9));
      expect(controller.speed, greaterThan(TilesGameController.startSpeed));

      expect(TilesGameController.speedAt(10), closeTo(TilesGameController.startSpeed + 10 * TilesGameController.acceleration, 1e-9));
      expect(TilesGameController.speedAt(10000), equals(TilesGameController.maxSpeed));
      // The scroll is the integral of the speed
      for (final t in [1.0, 50.0, 99.0, 100.0, 101.0, 300.0]) {
        const h = 1e-4;
        final derivative = (TilesGameController.scrollAt(t + h) - TilesGameController.scrollAt(t - h)) / (2 * h);
        expect(derivative, closeTo(TilesGameController.speedAt(t), 1e-3));
      }
    });

    test('the scroll does not depend on the frame rate', () {
      final a = _started();
      final b = _started();
      _run(a, 1.2, frame: const Duration(milliseconds: 8));
      _run(b, 1.2, frame: const Duration(milliseconds: 33));
      expect(a.scroll, closeTo(b.scroll, 1e-9));
      expect(a.rows.map((row) => row.index), equals(b.rows.map((row) => row.index)));
    });

    test('new rows appear at the top, tapped rows are dropped below the board', () {
      final controller = _started();
      for (var i = 1; i <= 6; i++) {
        _run(controller, 0.4);
        _tapDark(controller, i);
      }
      expect(controller.isRunning, isTrue);
      expect(controller.score, equals(7));
      final indexes = controller.rows.map((row) => row.index).toList();
      expect(indexes.first, greaterThan(0));
      for (final row in controller.rows) {
        expect(controller.topOf(row.index), lessThan(TilesGameController.visibleRows));
        expect(controller.topOf(row.index), greaterThan(-2));
      }
      // The board is always covered up to the top
      expect(controller.topOf(indexes.last), lessThanOrEqualTo(-1));
    });

    test('correct taps score in order and flash', () {
      final controller = _started();
      _run(controller, 0.1);
      _tapDark(controller, 1);
      expect(controller.score, equals(2));
      expect(controller.moves, equals(2));
      final row = controller.rowAt(1)!;
      expect(controller.flashOf(row), equals(0));
      _run(controller, TilesGameController.flashDuration / 2);
      expect(controller.flashOf(controller.rowAt(1)!), closeTo(0.5, 0.05));
      _run(controller, TilesGameController.flashDuration);
      expect(controller.flashOf(controller.rowAt(1)!), equals(1));
      expect(controller.flashOf(controller.rowAt(2)!), isNull);
    });

    test('a dark tile that is tapped again or out of order is ignored', () {
      final controller = _started();
      _tapDark(controller, 0);
      _tapDark(controller, 2);
      expect(controller.isRunning, isTrue);
      expect(controller.score, equals(1));
      expect(controller.moves, equals(1));

      // Two fingers at once: both rows count
      _tapDark(controller, 1);
      _tapDark(controller, 2);
      expect(controller.score, equals(3));
    });

    test('tapping a light tile ends the game', () {
      final results = <GameResult>[];
      final controller = _started()..resultListener = results.add;
      _run(controller, 0.2);
      _tapDark(controller, 1);
      _tapLight(controller, 2);

      expect(controller.isGameOver, isTrue);
      expect(controller.isRunning, isFalse);
      final mistake = controller.mistake!;
      expect(mistake.kind, equals(TilesMistakeKind.wrongTile));
      expect(mistake.row, equals(2));
      expect(mistake.column, isNot(controller.rowAt(2)!.darkColumn));

      final result = results.single;
      expect(result.gameId, equals('tiles'));
      expect(result.outcome, equals(GameOutcome.lost));
      expect(result.score, equals(2));
      expect(result.moves, equals(3));
      expect(result.data['reason'], equals('wrongTile'));

      // Nothing happens after the game is over
      final scroll = controller.scroll;
      controller.tick(const Duration(milliseconds: 16));
      _tapDark(controller, 2);
      expect(controller.scroll, equals(scroll));
      expect(controller.score, equals(2));
    });

    test('a wrong tap on a row that is partly above the board scrolls it into view', () {
      final controller = _started();
      _run(controller, 0.25);
      final row = controller.rowAt(3)!;
      expect(controller.topOf(3), lessThan(0));
      controller.tap((row.darkColumn + 1) % TilesGameController.columns, 0.1);
      expect(controller.isGameOver, isTrue);
      expect(controller.mistake!.row, equals(3));
      expect(controller.topOf(3), equals(0));
    });

    test('a light tile in a tapped row also ends the game', () {
      final controller = _started();
      _tapLight(controller, 0);
      expect(controller.isGameOver, isTrue);
      expect(controller.mistake!.row, equals(0));
    });

    test('a dark tile that leaves the bottom ends the game and scrolls back into view', () {
      final results = <GameResult>[];
      final controller = _started()..resultListener = results.add;
      // Row 1 starts at top 1.0 and leaves the board after scrolling 3 rows
      _run(controller, 1.3);
      expect(controller.isRunning, isTrue);
      _run(controller, 1.0);

      expect(controller.isGameOver, isTrue);
      final mistake = controller.mistake!;
      expect(mistake.kind, equals(TilesMistakeKind.missedTile));
      expect(mistake.row, equals(1));
      expect(mistake.column, equals(controller.rowAt(1)!.darkColumn));
      expect(controller.topOf(1), closeTo(TilesGameController.visibleRows - 1, 1e-9));
      // The miss happened once the tile was fully below the board
      expect(TilesGameController.scrollAt(controller.time), greaterThanOrEqualTo(3));

      final result = results.single;
      expect(result.outcome, equals(GameOutcome.lost));
      expect(result.score, equals(1));
      expect(result.data['reason'], equals('missedTile'));
    });

    test('a long run with a perfect player reaches the top speed', () {
      final controller = _started();
      for (var i = 0; i < 20000 && controller.isRunning; i++) {
        controller.tick(const Duration(milliseconds: 16));
        // Taps the next tile once it is in the lower half of the board
        if (controller.topOf(controller.nextRow) > 2) _tapDark(controller, controller.nextRow);
      }
      expect(controller.isRunning, isTrue);
      expect(controller.speed, equals(TilesGameController.maxSpeed));
      expect(controller.score, greaterThan(500));
      expect(controller.rows.length, lessThan(10));
    });

    test('reset starts a new game', () {
      final controller = _started();
      _run(controller, 0.5);
      _tapLight(controller, 1);
      expect(controller.isGameOver, isTrue);

      controller.resetGame();
      expect(controller.isReady, isTrue);
      expect(controller.score, equals(0));
      expect(controller.moves, equals(0));
      expect(controller.scroll, equals(0));
      expect(controller.mistake, isNull);
      expect(controller.result, isNull);
      expect(controller.rows.map((row) => row.index), equals([0, 1, 2, 3]));
    });
  });
}
