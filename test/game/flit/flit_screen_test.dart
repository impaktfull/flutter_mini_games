import 'package:flutter/material.dart';
import 'package:flutter_mini_games/flutter_mini_games.dart';
import 'package:flutter_mini_games/src/game/flit/game/logic/flit_game_controller.dart';
import 'package:flutter_mini_games/src/game/flit/widget/flit_board.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

FlitGameController _controller(WidgetTester tester) => Provider.of<FlitGameController>(tester.element(find.byType(FlitBoard)), listen: false);

void main() {
  testWidgets('a tap starts the game, the game loop advances it and play again starts over', (tester) async {
    // Small phone
    tester.view
      ..physicalSize = const Size(360, 640)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      FlutterMiniGames(
        scoreStore: InMemoryGameScoreStore(),
        child: MaterialApp(home: Builder(builder: const FlitGameBuilder().build)),
      ),
    );
    await tester.pump();

    final controller = _controller(tester);
    expect(find.text('Tap to start'), findsOneWidget);
    expect(controller.isRunning, isFalse);

    await tester.tap(find.byType(FlitBoard));
    await tester.pump();
    expect(controller.isRunning, isTrue);
    expect(find.text('Tap to start'), findsNothing);
    final columnX = controller.columns.first.x;

    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(controller.columns.first.x, lessThan(columnX));
    expect(controller.velocity, greaterThan(FlitGameController.flapVelocity));

    // Without flapping the flyer falls to the ground
    for (var i = 0; i < 200 && !controller.isGameOver; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(controller.isGameOver, isTrue);
    await tester.pump();
    expect(find.text('Game over'), findsOneWidget);

    await tester.tap(find.text('Play again'));
    await tester.pump();
    expect(controller.isReady, isTrue);
    expect(find.text('Tap to start'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
