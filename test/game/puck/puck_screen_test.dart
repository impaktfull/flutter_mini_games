import 'package:flutter/material.dart';
import 'package:flutter_mini_games/flutter_mini_games.dart';
import 'package:flutter_mini_games/src/core/duel/duel_game_controller.dart';
import 'package:flutter_mini_games/src/game/puck/game/logic/puck_game_controller.dart';
import 'package:flutter_mini_games/src/game/puck/widget/puck_table.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

PuckGameController _controller(WidgetTester tester) => Provider.of<PuckGameController>(tester.element(find.byType(PuckTable)), listen: false);

Future<void> _frames(WidgetTester tester, Duration duration) async {
  for (var elapsed = Duration.zero; elapsed < duration; elapsed += const Duration(milliseconds: 16)) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

void main() {
  testWidgets('both players drag their mallet at the same time, each in their own half', (tester) async {
    tester.view
      ..physicalSize = const Size(360, 640)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      FlutterMiniGames(
        scoreStore: InMemoryGameScoreStore(),
        child: MaterialApp(home: Builder(builder: const PuckGameBuilder().build)),
      ),
    );
    await tester.pump();
    final controller = _controller(tester);

    expect(find.text('Tap when ready'), findsNWidgets(2));
    // Rules on both halves, the table paints the score itself
    expect(find.text('How to play'), findsNWidgets(2));
    expect(find.textContaining(' – '), findsNothing);
    await tester.tap(find.text('Tap when ready').first);
    await tester.tap(find.text('Tap when ready').last);
    await tester.pump();
    expect(controller.phase, equals(DuelPhase.countdown));
    await _frames(tester, DuelGameController.countdownDuration + const Duration(milliseconds: 100));
    expect(controller.phase, equals(DuelPhase.playing));
    expect(find.text('Tap when ready'), findsNothing);

    final table = tester.getRect(find.descendant(of: find.byType(PuckTable), matching: find.byType(LayoutBuilder)));
    final scale = table.width / PuckGameController.width;
    Offset toScreen(Offset world) => table.topLeft + world * scale;

    final top = await tester.startGesture(toScreen(PuckGameController.malletStart(DuelPlayer.top)));
    final bottom = await tester.startGesture(toScreen(PuckGameController.malletStart(DuelPlayer.bottom)), pointer: 2);
    await tester.pump();
    for (var i = 0; i < 10; i++) {
      await top.moveBy(Offset(0.03 * scale, 0.02 * scale));
      await bottom.moveBy(Offset(-0.03 * scale, -0.02 * scale));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await _frames(tester, const Duration(milliseconds: 200));

    final topMallet = controller.mallet(DuelPlayer.top);
    final bottomMallet = controller.mallet(DuelPlayer.bottom);
    expect(topMallet.dx, closeTo(0.8, 0.01));
    expect(topMallet.dy, closeTo(PuckGameController.malletStart(DuelPlayer.top).dy + 0.2, 0.01));
    expect(bottomMallet.dx, closeTo(0.2, 0.01));
    expect(bottomMallet.dy, closeTo(PuckGameController.malletStart(DuelPlayer.bottom).dy - 0.2, 0.01));

    // A finger that started in the bottom half keeps moving the bottom mallet, which stays in its half
    await bottom.moveTo(toScreen(const Offset(0.2, 0.1)));
    await _frames(tester, const Duration(milliseconds: 300));
    expect(controller.mallet(DuelPlayer.bottom).dy, closeTo(PuckGameController.height / 2 + PuckGameController.malletRadius, 1e-6));
    expect(controller.mallet(DuelPlayer.top).dy, lessThan(PuckGameController.height / 2));

    await top.up();
    await bottom.up();
    await tester.pump();

    // A goal for the bottom player, each half explains the round from its own view
    controller.debugSetPuck(const Offset(PuckGameController.width / 2, 0.02), const Offset(0, -2));
    await tester.pump(const Duration(milliseconds: 16));
    expect(controller.phase, equals(DuelPhase.roundOver));
    expect(find.text('Goal!'), findsOneWidget);
    expect(find.text('Conceded'), findsOneWidget);
    expect(find.textContaining(' – '), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
