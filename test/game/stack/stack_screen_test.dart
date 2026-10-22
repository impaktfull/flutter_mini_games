import 'package:flutter/material.dart';
import 'package:flutter_mini_games/flutter_mini_games.dart';
import 'package:flutter_mini_games/src/game/stack/game/logic/stack_game_controller.dart';
import 'package:flutter_mini_games/src/game/stack/widget/stack_tower.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

StackGameController _controller(WidgetTester tester) => Provider.of<StackGameController>(tester.element(find.byType(StackTower)), listen: false);

void main() {
  testWidgets('a tap starts the game, the loop moves the block and a tap drops it', (tester) async {
    // Small phone
    tester.view
      ..physicalSize = const Size(360, 740)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(home: Builder(builder: const StackGameBuilder().build)));
    expect(find.text('Tap to start'), findsOneWidget);
    final controller = _controller(tester);
    final start = controller.current.left;

    await tester.tap(find.byType(StackTower));
    await tester.pump();
    expect(find.text('Tap to start'), findsNothing);
    expect(controller.isRunning, isTrue);
    expect(controller.moves, equals(0));

    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 16));
    expect(controller.current.left, isNot(equals(start)));

    await tester.tap(find.byType(StackTower));
    await tester.pump();
    expect(controller.moves, equals(1));
    expect(tester.takeException(), isNull);

    // Leaving the screen stops the loop
    await tester.pumpWidget(const SizedBox());
  });
}
