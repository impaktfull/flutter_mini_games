import 'package:flutter/material.dart';
import 'package:flutter_mini_games/flutter_mini_games.dart';
import 'package:flutter_mini_games/src/game/trail/game/logic/trail_game_controller.dart';
import 'package:flutter_mini_games/src/game/trail/widget/trail_grid.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  Future<TrailGameController> pump(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
    Size size = const Size(360, 640),
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: brightness),
        home: Builder(builder: const TrailGameBuilder(puzzles: [TrailPuzzles.tutorial]).build),
      ),
    );
    return Provider.of<TrailGameController>(tester.element(find.byType(TrailGrid)), listen: false);
  }

  Offset cellCenter(WidgetTester tester, int row, int col) => tester.getCenter(find.byKey(ValueKey('trail_cell_${row}_$col')));

  testWidgets('dragging over the cells draws the trail and solves the puzzle', (tester) async {
    final controller = await pump(tester);

    final gesture = await tester.startGesture(cellCenter(tester, 0, 0));
    for (final (row, col) in [(0, 1), (0, 2), (1, 2), (1, 1), (1, 0), (2, 0), (2, 1), (2, 2)]) {
      await gesture.moveTo(cellCenter(tester, row, col));
      await tester.pump();
    }
    await gesture.up();
    await tester.pump();

    expect(controller.isWon, isTrue);
    expect(find.text('Next Puzzle'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping the next cell extends the trail, without overflow on a small dark phone', (tester) async {
    final controller = await pump(tester, brightness: Brightness.dark, size: const Size(320, 568));

    await tester.tapAt(cellCenter(tester, 1, 0));
    await tester.pump();
    expect(controller.path, [(0, 0), (1, 0)]);

    // Not adjacent: ignored
    await tester.tapAt(cellCenter(tester, 2, 2));
    await tester.pump();
    expect(controller.path, [(0, 0), (1, 0)]);
    expect(tester.takeException(), isNull);
  });
}
