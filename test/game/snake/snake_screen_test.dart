import 'package:flutter/material.dart';
import 'package:flutter_mini_games/flutter_mini_games.dart';
import 'package:flutter_mini_games/src/game/snake/game/logic/snake_game_controller.dart';
import 'package:flutter_mini_games/src/game/snake/game/model/snake_cell.dart';
import 'package:flutter_mini_games/src/game/snake/widget/snake_board.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a swipe starts the game and the game loop moves the snake', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(home: Builder(builder: const SnakeGameBuilder().build)));
    expect(find.text('Swipe to start'), findsOneWidget);

    SnakeGameController controller() => tester.widget<SnakeBoard>(find.byType(SnakeBoard)).controller;
    expect(controller().isRunning, isFalse);

    await tester.drag(find.byType(SnakeBoard), const Offset(0, -60));
    await tester.pump();
    expect(find.text('Swipe to start'), findsNothing);
    expect(controller().isRunning, isTrue);
    expect(controller().head, equals(const SnakeCell(7, 7)));

    // The first frame takes the first step, then two step intervals in frames of 20 ms
    for (var i = 0; i < 18; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    expect(controller().head, equals(const SnakeCell(7, 4)));

    // Run into the top wall
    await tester.pump(const Duration(seconds: 1));
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(controller().isLost, isTrue);
    expect(find.text('Game over'), findsOneWidget);

    await tester.tap(find.text('Play again'));
    await tester.pump();
    expect(find.text('Swipe to start'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
