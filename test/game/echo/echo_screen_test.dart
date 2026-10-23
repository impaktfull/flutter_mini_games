import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mini_games/flutter_mini_games.dart';
import 'package:flutter_mini_games/src/game/echo/game/logic/echo_game_controller.dart';
import 'package:flutter_mini_games/src/game/echo/widget/echo_board.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('watch the playback, repeat it, then lose on a wrong pad', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(home: Builder(builder: const EchoGameBuilder().build)));
    expect(find.text('Tap to start'), findsOneWidget);

    EchoGameController controller() => tester.widget<EchoBoard>(find.byType(EchoBoard)).controller;
    Finder pad(int pad) => find.byKey(ValueKey('echo_pad_$pad'));

    Future<void> waitForInput() async {
      for (var i = 0; i < 200 && !controller().isAwaitingInput; i++) {
        await tester.pump(const Duration(milliseconds: 20));
      }
      expect(controller().isAwaitingInput, isTrue);
    }

    await tester.tap(find.text('Start'));
    await tester.pump();
    expect(find.text('Tap to start'), findsNothing);
    expect(controller().isPlayingBack, isTrue);

    // Taps during the playback are ignored
    await tester.tapAt(tester.getCenter(pad(controller().sequence.first)));
    await tester.pump();
    expect(controller().moves, equals(0));

    await waitForInput();
    expect(find.text('Your turn 0/1'), findsOneWidget);
    await tester.tapAt(tester.getCenter(pad(controller().sequence.first)));
    await tester.pump();
    expect(controller().score, equals(1));
    expect(find.text('Score: 1'), findsOneWidget);

    await waitForInput();
    final expected = controller().sequence.first;
    await tester.tapAt(tester.getCenter(pad((expected + 1) % EchoGameController.padCount)));
    await tester.pump();
    expect(controller().isGameOver, isTrue);
    expect(find.text('Game over'), findsOneWidget);
    expect(controller().result!.score, equals(1));

    await tester.tap(find.text('Play again'));
    await tester.pump();
    expect(find.text('Tap to start'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('padAt maps a position to a pad and ignores the gaps', () {
    const size = Size(210, 210);
    const gap = 10.0;

    expect(EchoBoard.padAt(const Offset(50, 50), size, gap), 0);
    expect(EchoBoard.padAt(const Offset(150, 50), size, gap), 1);
    expect(EchoBoard.padAt(const Offset(50, 150), size, gap), 2);
    expect(EchoBoard.padAt(const Offset(150, 150), size, gap), 3);
    expect(EchoBoard.padAt(const Offset(105, 50), size, gap), isNull);
    expect(EchoBoard.padAt(const Offset(50, 105), size, gap), isNull);
    expect(EchoBoard.padAt(const Offset(-1, 50), size, gap), isNull);
  });

  testWidgets('a tap on a pad and space both start the game, gaps are ignored', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(home: Builder(builder: const EchoGameBuilder().build)));
    EchoGameController controller() => tester.widget<EchoBoard>(find.byType(EchoBoard)).controller;

    // The point between the four pads is in the gap
    final topLeft = tester.getRect(find.byKey(const ValueKey('echo_pad_0')));
    final bottomRight = tester.getRect(find.byKey(const ValueKey('echo_pad_3')));
    await tester.tapAt(Rect.fromPoints(topLeft.center, bottomRight.center).center);
    await tester.pump();
    expect(controller().isReady, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(controller().isPlayingBack, isTrue);

    await tester.tap(find.text('Restart'));
    await tester.pump();
    expect(controller().isReady, isTrue);

    await tester.tapAt(tester.getCenter(find.byKey(const ValueKey('echo_pad_2'))));
    await tester.pump();
    expect(controller().isPlayingBack, isTrue);
    expect(controller().moves, 0);
    expect(tester.takeException(), isNull);
  });
}
