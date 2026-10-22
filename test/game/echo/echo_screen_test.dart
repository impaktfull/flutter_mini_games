import 'package:flutter/material.dart';
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
    await tester.tap(pad(controller().sequence.first));
    await tester.pump();
    expect(controller().moves, equals(0));

    await waitForInput();
    expect(find.text('Your turn 0/1'), findsOneWidget);
    await tester.tap(pad(controller().sequence.first));
    await tester.pump();
    expect(controller().score, equals(1));
    expect(find.text('Score: 1'), findsOneWidget);

    await waitForInput();
    final expected = controller().sequence.first;
    await tester.tap(pad((expected + 1) % EchoGameController.padCount));
    await tester.pump();
    expect(controller().isGameOver, isTrue);
    expect(find.text('Game over'), findsOneWidget);
    expect(controller().result!.score, equals(1));

    await tester.tap(find.text('Play again'));
    await tester.pump();
    expect(find.text('Tap to start'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
