import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mini_games/flutter_mini_games.dart';
import 'package:flutter_mini_games/src/game/reflex/game/logic/reflex_game_controller.dart';
import 'package:flutter_mini_games/src/game/reflex/game/model/reflex_phase.dart';
import 'package:flutter_mini_games/src/game/reflex/widget/reflex_board.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('plays a full game: start, too early, five tries and the result', (tester) async {
    // Small phone
    tester.view
      ..physicalSize = const Size(320, 568)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final results = <GameResult>[];
    await tester.pumpWidget(
      MaterialApp(
        home: FlutterMiniGames(
          onGameFinished: results.add,
          child: Builder(builder: const ReflexGameBuilder().build),
        ),
      ),
    );
    ReflexGameController controller() => tester.widget<ReflexBoard>(find.byType(ReflexBoard)).controller;
    final board = find.byType(ReflexBoard);

    expect(find.text('Tap to start'), findsOneWidget);
    await tester.tap(board);
    await tester.pump();
    expect(find.text('Wait...'), findsOneWidget);

    // Too early
    await tester.tap(board);
    await tester.pump();
    expect(find.text('Too early!'), findsOneWidget);
    await tester.tap(board);
    await tester.pump();
    expect(controller().phase, equals(ReflexPhase.waiting));

    for (var i = 0; i < ReflexGameController.tries; i++) {
      // The game loop drives the delay
      for (var frame = 0; frame < 400 && controller().phase != ReflexPhase.go; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(find.text('TAP!'), findsOneWidget);
      for (var frame = 0; frame < 15; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      await tester.tap(board);
      await tester.pump();
      if (i < ReflexGameController.tries - 1) {
        expect(controller().phase, equals(ReflexPhase.measured));
        expect(find.text('${controller().lastTime} ms'), findsWidgets);
        await tester.tap(board);
        await tester.pump();
      }
    }

    expect(controller().isGameOver, isTrue);
    expect(controller().times, hasLength(ReflexGameController.tries));
    for (final time in controller().times) {
      expect(time, inInclusiveRange(200, 260));
    }
    expect(find.text('Play again'), findsOneWidget);
    expect(results.single.outcome, equals(GameOutcome.won));
    expect(results.single.data['averageMs'], equals(controller().averageMs));
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text('Play again'));
    await tester.tap(find.text('Play again'));
    await tester.pump();
    expect(find.text('Tap to start'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('space starts the game and taps', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Builder(builder: const ReflexGameBuilder().build)));
    ReflexGameController controller() => tester.widget<ReflexBoard>(find.byType(ReflexBoard)).controller;

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(controller().phase, equals(ReflexPhase.waiting));

    await tester.pumpWidget(const SizedBox());
  });
}
