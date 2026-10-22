import 'package:flutter/material.dart';
import 'package:flutter_mini_games/flutter_mini_games.dart';
import 'package:flutter_mini_games/src/game/whack/game/logic/whack_game_controller.dart';
import 'package:flutter_mini_games/src/game/whack/widget/whack_field.dart';
import 'package:flutter_mini_games/src/game/whack/widget/whack_hole.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tap to start, tap a critter, the round ends and can be played again', (tester) async {
    // Small phone
    tester.view
      ..physicalSize = const Size(320, 568)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final results = <GameResult>[];
    await tester.pumpWidget(
      FlutterMiniGames(
        onGameFinished: results.add,
        child: MaterialApp(home: Builder(builder: const WhackGameBuilder().build)),
      ),
    );
    expect(find.text('Tap to start'), findsOneWidget);
    WhackGameController controller() => tester.widget<WhackField>(find.byType(WhackField)).controller;

    await tester.tap(find.byType(WhackField));
    await tester.pump();
    expect(find.text('Tap to start'), findsNothing);
    expect(controller().isRunning, isTrue);
    expect(controller().moves, equals(0));

    // Wait for a critter to be up
    WhackTarget? critter;
    for (var i = 0; i < 300 && critter == null; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      for (final target in controller().targets) {
        if (!target.isDecoy && controller().popOf(target) == 1) critter = target;
      }
    }
    expect(critter, isNotNull);

    await tester.tap(find.byWidgetPredicate((widget) => widget is WhackHole && widget.hole == critter!.hole));
    await tester.pump();
    expect(controller().hits, equals(1));
    expect(find.text('+1'), findsOneWidget);

    // Play out the round
    for (var i = 0; i < 31 * 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(controller().isGameOver, isTrue);
    expect(find.text("Time's up!"), findsOneWidget);
    await tester.pump();
    expect(results.single.gameId, equals('whack'));
    expect(results.single.outcome, equals(GameOutcome.won));

    await tester.ensureVisible(find.text('Play again'));
    await tester.tap(find.text('Play again'));
    await tester.pump();
    expect(find.text('Tap to start'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
  });
}
