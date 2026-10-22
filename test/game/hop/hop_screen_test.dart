import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mini_games/flutter_mini_games.dart';
import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/game/hop/game/logic/hop_game_controller.dart';
import 'package:flutter_mini_games/src/game/hop/game/model/hop_steer.dart';
import 'package:flutter_mini_games/src/game/hop/widget/hop_playfield.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

HopGameController _controller(WidgetTester tester) => Provider.of<HopGameController>(tester.element(find.byType(HopPlayfield)), listen: false);

Future<void> _pumpGame(WidgetTester tester) async {
  tester.view
    ..physicalSize = const Size(360, 740)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: Builder(builder: const HopGameBuilder().build)));
}

void main() {
  testWidgets('holding a half of the board starts the game and the loop advances it', (tester) async {
    await _pumpGame(tester);
    final controller = _controller(tester);
    expect(controller.isReady, isTrue);
    expect(find.text('Tap to start'), findsOneWidget);

    final board = tester.getRect(find.descendant(of: find.byType(HopPlayfield), matching: find.byType(AspectRatio)));
    final gesture = await tester.startGesture(board.centerLeft + const Offset(20, 0));
    await tester.pump();
    expect(controller.status, equals(GameStatus.playing));
    expect(controller.steer, equals(HopSteer.left));
    expect(find.text('Tap to start'), findsNothing);

    final startY = controller.characterY;
    final startX = controller.characterX;
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(controller.characterY, greaterThan(startY));
    expect(controller.characterX, lessThan(startX));

    await gesture.up();
    await tester.pump();
    expect(controller.steer, equals(HopSteer.none));
    expect(controller.moves, equals(1));

    // Leave the screen so no frames are scheduled anymore
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('arrow keys steer while held', (tester) async {
    await _pumpGame(tester);
    final controller = _controller(tester);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(controller.status, equals(GameStatus.playing));
    expect(controller.steer, equals(HopSteer.right));

    await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(controller.steer, equals(HopSteer.none));

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('space starts the game without counting a move', (tester) async {
    await _pumpGame(tester);
    final controller = _controller(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(controller.status, equals(GameStatus.playing));
    expect(controller.moves, equals(0));

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('shows game over and plays again', (tester) async {
    await _pumpGame(tester);
    final controller = _controller(tester)..start();
    controller.debugSetPlatforms([]);

    for (var i = 0; i < 200 && !controller.isGameOver; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('Game over'), findsOneWidget);

    await tester.tap(find.text('Play again'));
    await tester.pump();
    expect(controller.isReady, isTrue);
    expect(find.text('Tap to start'), findsOneWidget);
  });
}
