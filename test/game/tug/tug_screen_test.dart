import 'package:flutter/material.dart';
import 'package:flutter_mini_games/flutter_mini_games.dart';
import 'package:flutter_mini_games/src/core/duel/duel_game_controller.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/game/tug/game/logic/tug_game_controller.dart';
import 'package:flutter_mini_games/src/game/tug/widget/tug_rope.dart';
import 'package:flutter_mini_games/src/game/tug/widget/tug_side.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ready, countdown, both halves pull at once, a round is won and the match can be replayed', (tester) async {
    // Small phone
    tester.view
      ..physicalSize = const Size(320, 568)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final results = <GameResult>[];
    await tester.pumpWidget(
      FlutterMiniGames(
        onGameFinished: results.add,
        child: MaterialApp(home: Builder(builder: const TugGameBuilder().build)),
      ),
    );
    TugGameController controller() => tester.widget<TugRope>(find.byType(TugRope)).controller;
    Finder side(DuelPlayer player) => find.byWidgetPredicate((widget) => widget is TugSide && widget.player == player);

    // Ready, with how to play on both halves
    expect(find.text('Tap when ready'), findsNWidgets(2));
    expect(find.text('Tap your half as fast as you can'), findsNWidgets(2));
    await tester.tap(find.text('Tap when ready').first);
    await tester.pump();
    await tester.tap(find.text('Tap when ready'));
    await tester.pump();

    // Countdown: taps don't pull yet
    expect(controller().phase, equals(DuelPhase.countdown));
    expect(find.text('3'), findsNWidgets(2));
    await tester.tapAt(tester.getCenter(side(DuelPlayer.bottom)));
    await tester.pump();
    expect(controller().position, equals(0));

    // The game loop runs the countdown
    for (var i = 0; i < 70 && controller().phase != DuelPhase.playing; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(controller().phase, equals(DuelPhase.playing));
    expect(find.text('Tap!'), findsNWidgets(2));

    // Both players tap at the same time with their own finger
    Future<void> tapBoth({int bottomTaps = 1, int topTaps = 1}) async {
      final bottomCenter = tester.getCenter(side(DuelPlayer.bottom));
      final topCenter = tester.getCenter(side(DuelPlayer.top));
      for (var i = 0; i < bottomTaps || i < topTaps; i++) {
        final bottom = i < bottomTaps ? await tester.startGesture(bottomCenter, pointer: 10 + i * 2) : null;
        final top = i < topTaps ? await tester.startGesture(topCenter, pointer: 11 + i * 2) : null;
        await bottom?.up();
        await top?.up();
        await tester.pump(const Duration(milliseconds: 16));
      }
    }

    await tapBoth();
    expect(controller().position, equals(0));
    expect(controller().pulls(DuelPlayer.bottom), equals(1));
    expect(controller().pulls(DuelPlayer.top), equals(1));
    expect(controller().moves, equals(2));

    await tapBoth(bottomTaps: 3, topTaps: 1);
    expect(controller().position, equals(2));
    expect(controller().leader, equals(DuelPlayer.bottom));

    // Player 2 pulls the marker to the top edge
    await tapBoth(bottomTaps: 0, topTaps: TugGameController.stepsToWin + 2);
    expect(controller().phase, equals(DuelPhase.roundOver));
    expect(controller().roundWinner, equals(DuelPlayer.top));
    await tester.pump();
    expect(find.text('You win the round'), findsOneWidget);
    expect(find.text('Player 2 wins the round'), findsOneWidget);

    // Next round starts by itself with the marker in the middle
    for (var i = 0; i < 120 && controller().phase != DuelPhase.playing; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(controller().phase, equals(DuelPhase.playing));
    expect(controller().position, equals(0));

    await tapBoth(bottomTaps: 0, topTaps: TugGameController.stepsToWin);
    await tester.pump();
    expect(find.text('You win!'), findsOneWidget);
    expect(find.text('You lose'), findsOneWidget);
    expect(results.single.gameId, equals('tug'));
    expect(results.single.outcome, equals(GameOutcome.won));
    expect(results.single.data['winner'], equals('top'));

    await tester.tap(find.text('Rematch').first);
    await tester.pump();
    expect(controller().phase, equals(DuelPhase.ready));
    expect(find.text('Tap when ready'), findsNWidgets(2));
  });

  testWidgets('fits without overflow from small phones to tablets', (tester) async {
    for (final size in const [Size(320, 568), Size(390, 844), Size(1024, 1366)]) {
      tester.view
        ..physicalSize = size
        ..devicePixelRatio = 1;
      await tester.pumpWidget(
        FlutterMiniGames(
          child: MaterialApp(home: Builder(builder: const TugGameBuilder().build)),
        ),
      );
      expect(tester.takeException(), isNull);
    }
    addTearDown(tester.view.reset);
  });

  test('player colors are theme tokens that copyWith can override', () {
    final core = CoreGameTheme.light();
    final theme = TugTheme.fromCore(core);
    expect(theme.colors.playerColor(DuelPlayer.bottom), core.playerColor(DuelPlayer.bottom));
    expect(theme.colors.onPlayerColor(DuelPlayer.top), core.onPlayerColor(DuelPlayer.top));

    final custom = theme.copyWith(
      colors: theme.colors.copyWith(bottomPlayer: core.colors.error, onTopPlayer: core.colors.text),
    );
    expect(custom.colors.playerColor(DuelPlayer.bottom), core.colors.error);
    expect(custom.colors.onPlayerColor(DuelPlayer.top), core.colors.text);
    expect(custom.colors.topPlayer, theme.colors.topPlayer);
  });
}
