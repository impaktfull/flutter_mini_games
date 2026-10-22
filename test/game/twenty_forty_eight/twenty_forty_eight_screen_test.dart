import 'package:flutter/material.dart';
import 'package:flutter_mini_games/flutter_mini_games.dart';
import 'package:flutter_mini_games/src/game/twenty_forty_eight/game/logic/twenty_forty_eight_game_controller.dart';
import 'package:flutter_mini_games/src/game/twenty_forty_eight/widget/twenty_forty_eight_board.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('vertical swipes on the board move the tiles instead of scrolling the page', (tester) async {
    tester.view
      ..physicalSize = const Size(360, 640)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: Builder(builder: const TwentyFortyEightGameBuilder().build)));

    TwentyFortyEightGameController controller() => tester.widget<TwentyFortyEightBoard>(find.byType(TwentyFortyEightBoard)).controller;
    final board = find.byType(TwentyFortyEightBoard);
    final top = tester.getTopLeft(board).dy;

    // Down and up: with two tiles on the board at least one of them moves something
    await tester.drag(board, const Offset(0, 80));
    await tester.pumpAndSettle();
    await tester.drag(board, const Offset(0, -80));
    await tester.pumpAndSettle();

    expect(controller().moves, greaterThanOrEqualTo(1));
    expect(tester.getTopLeft(board).dy, equals(top));
    expect(tester.takeException(), isNull);
  });
}
