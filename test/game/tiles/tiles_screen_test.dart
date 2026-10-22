import 'package:flutter/material.dart';
import 'package:flutter_mini_games/flutter_mini_games.dart';
import 'package:flutter_mini_games/src/game/tiles/game/logic/tiles_game_controller.dart';
import 'package:flutter_mini_games/src/game/tiles/widget/tiles_board.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tap the start tile, tap the next tiles, miss one and play again', (tester) async {
    // Small phone
    tester.view
      ..physicalSize = const Size(320, 568)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final results = <GameResult>[];
    await tester.pumpWidget(
      FlutterMiniGames(
        onGameFinished: results.add,
        child: MaterialApp(home: Builder(builder: const TilesGameBuilder().build)),
      ),
    );
    expect(find.text('Tap the dark tiles'), findsOneWidget);
    TilesGameController controller() => tester.widget<TilesBoard>(find.byType(TilesBoard)).controller;

    final board = find.byType(TilesBoard);
    Offset tileCenter(int row, int column) {
      final rect = tester.getRect(board);
      final cellWidth = rect.width / TilesGameController.columns;
      final cellHeight = rect.height / TilesGameController.visibleRows;
      // Middle of the visible part of the row
      final top = controller().topOf(row);
      final y = (top.clamp(0.0, TilesGameController.visibleRows) + (top + 1).clamp(0.0, TilesGameController.visibleRows)) / 2;
      return rect.topLeft + Offset((column + 0.5) * cellWidth, y * cellHeight);
    }

    Future<void> tapDark(int row) => tester.tapAt(tileCenter(row, controller().rowAt(row)!.darkColumn));

    // A light tile before the start does nothing
    await tester.tapAt(tileCenter(0, (controller().rowAt(0)!.darkColumn + 1) % 4));
    await tester.pump();
    expect(controller().isReady, isTrue);

    await tapDark(0);
    await tester.pump();
    expect(find.text('Tap the dark tiles'), findsNothing);
    expect(controller().isRunning, isTrue);
    expect(controller().score, equals(1));

    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 100));
    await tapDark(1);
    await tester.pump();
    expect(controller().score, equals(2));

    // Two fingers at once
    final first = await tester.startGesture(tileCenter(2, controller().rowAt(2)!.darkColumn));
    final second = await tester.startGesture(tileCenter(3, controller().rowAt(3)!.darkColumn), pointer: 99);
    await first.up();
    await second.up();
    await tester.pump();
    expect(controller().score, equals(4));

    // Let the next tile pass
    for (var i = 0; i < 200 && !controller().isGameOver; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(controller().isGameOver, isTrue);
    expect(find.text('Missed a tile!'), findsOneWidget);
    await tester.pump();
    expect(results.single.gameId, equals('tiles'));
    expect(results.single.outcome, equals(GameOutcome.lost));
    expect(results.single.score, equals(4));

    await tester.tap(find.text('Play again'));
    await tester.pump();
    expect(find.text('Tap the dark tiles'), findsOneWidget);
    expect(controller().score, equals(0));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
  });
}
