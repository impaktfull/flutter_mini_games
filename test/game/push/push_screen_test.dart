import 'package:flutter/material.dart';
import 'package:flutter_mini_games/flutter_mini_games.dart';
import 'package:flutter_mini_games/src/core/duel/duel_game_controller.dart';
import 'package:flutter_mini_games/src/game/push/game/logic/push_game_controller.dart';
import 'package:flutter_mini_games/src/game/push/widget/push_arena.dart';
import 'package:flutter_mini_games/src/game/push/widget/push_touch_area.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

PushGameController _controller(WidgetTester tester) => Provider.of<PushGameController>(tester.element(find.byType(PushArena)), listen: false);

void main() {
  test('maps the horizontal tap position to the aim', () {
    expect(PushTouchArea.aimFor(0, 200), equals(-1));
    expect(PushTouchArea.aimFor(100, 200), equals(0));
    expect(PushTouchArea.aimFor(200, 200), equals(1));
    expect(PushTouchArea.aimFor(250, 200), equals(1));
  });

  testWidgets('both players get ready, then push and aim at the same time', (tester) async {
    // Small phone
    tester.view
      ..physicalSize = const Size(320, 568)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      FlutterMiniGames(
        scoreStore: InMemoryGameScoreStore(),
        child: MaterialApp(home: Builder(builder: const PushGameBuilder().build)),
      ),
    );
    await tester.pump();

    final controller = _controller(tester);
    expect(find.text('Tap when ready'), findsNWidgets(2));
    expect(find.text('How to play'), findsNWidgets(2));
    await tester.tap(find.text('Tap when ready').first);
    await tester.tap(find.text('Tap when ready').last);
    await tester.pump();
    expect(controller.phase, equals(DuelPhase.countdown));

    for (var i = 0; i < 70 && !controller.isPlaying; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(controller.isPlaying, isTrue);
    expect(find.text('Tap when ready'), findsNothing);

    final arena = tester.getRect(find.byType(PushArena));
    // Bottom player: right edge of their half. Top player: left edge of the screen, which is their right
    final bottom = await tester.startGesture(Offset(arena.right - 1, arena.bottom - 40));
    final top = await tester.startGesture(Offset(arena.left + 1, arena.top + 40), pointer: 2);
    await tester.pump();

    expect(controller.moves, equals(2));
    expect(controller.holdAim(DuelPlayer.bottom), closeTo(1, 0.02));
    expect(controller.holdAim(DuelPlayer.top), closeTo(1, 0.02));
    final bottomVelocity = controller.disc(DuelPlayer.bottom).velocity;
    final topVelocity = controller.disc(DuelPlayer.top).velocity;
    expect(bottomVelocity.dy, lessThan(0));
    expect(bottomVelocity.dx, greaterThan(0));
    expect(topVelocity.dy, greaterThan(0));
    expect(topVelocity.dx, lessThan(0));

    await tester.pump(const Duration(milliseconds: 50));
    expect(controller.disc(DuelPlayer.bottom).position.dy, lessThan(PushGameController.startDistance));

    await bottom.up();
    await top.up();
    await tester.pump();
    expect(controller.holdAim(DuelPlayer.bottom), isNull);
    expect(controller.holdAim(DuelPlayer.top), isNull);

    // Play the round until the ring shrinks below a disc
    for (var i = 0; i < 600 && controller.isPlaying; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(controller.phase, equals(DuelPhase.roundOver));
    if (controller.roundWinner == null) {
      expect(find.text('Both out of the ring'), findsNWidgets(2));
    } else {
      expect(find.text('Pushed out!'), findsOneWidget);
      expect(find.text('Out of the ring'), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });
}
