import 'package:flutter/material.dart';
import 'package:flutter_mini_games/flutter_mini_games.dart';
import 'package:flutter_mini_games/src/core/duel/duel_game_controller.dart';
import 'package:flutter_mini_games/src/game/quickdraw/game/logic/quickdraw_game_controller.dart';
import 'package:flutter_mini_games/src/game/quickdraw/widget/quickdraw_half.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('plays a round with two simultaneous fingers: the first one wins', (tester) async {
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
          child: Builder(builder: const QuickdrawGameBuilder().build),
        ),
      ),
    );
    QuickdrawGameController controller() => tester.widget<QuickdrawHalf>(find.byType(QuickdrawHalf).first).controller;
    // DuelLayout builds the top half first
    final topHalf = tester.getCenter(find.byType(QuickdrawHalf).first);
    final bottomHalf = tester.getCenter(find.byType(QuickdrawHalf).last);
    expect(tester.widget<QuickdrawHalf>(find.byType(QuickdrawHalf).first).player, equals(DuelPlayer.top));

    expect(find.text('Tap when ready'), findsNWidgets(2));
    await tester.tap(find.text('Tap when ready').first);
    await tester.tap(find.text('Tap when ready').last);
    await tester.pump();
    expect(controller().phase, equals(DuelPhase.countdown));

    // The game loop drives the countdown and the wait
    for (var frame = 0; frame < 600 && !controller().isGo; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(controller().isGo, isTrue);
    expect(find.text('GO!'), findsNWidgets(2));
    expect(find.byIcon(Icons.bolt), findsNWidgets(2));
    for (var frame = 0; frame < 12; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    // Both players touch at the same time, the top finger lands first
    final top = await tester.startGesture(topHalf);
    final bottom = await tester.startGesture(bottomHalf, pointer: 2);
    await top.up();
    await bottom.up();
    await tester.pump();

    expect(controller().phase, equals(DuelPhase.roundOver));
    expect(controller().roundWinner, equals(DuelPlayer.top));
    expect(controller().roundWins(DuelPlayer.top), equals(1));
    expect(controller().roundWins(DuelPlayer.bottom), equals(0));
    final ms = controller().roundReactionMs!;
    expect(find.text('$ms ms'), findsOneWidget);
    expect(find.text('Player 2: $ms ms'), findsOneWidget);
    expect(results, isEmpty);

    // Next round: the bottom player taps too early
    for (var frame = 0; frame < 400 && controller().phase != DuelPhase.playing; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(find.text('Wait...'), findsNWidgets(2));
    await tester.tapAt(bottomHalf);
    await tester.pump();
    expect(controller().earlyPlayer, equals(DuelPlayer.bottom));
    expect(controller().roundWins(DuelPlayer.top), equals(2));
    expect(find.text('Too early!'), findsOneWidget);
    expect(find.text('Player 1 was too early'), findsOneWidget);

    // Leave the screen and let the timers settle
    await tester.pumpWidget(const SizedBox());
    expect(results.single.outcome, equals(GameOutcome.abandoned));
  });
}
