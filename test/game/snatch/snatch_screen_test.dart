import 'package:flutter/material.dart';
import 'package:flutter_mini_games/flutter_mini_games.dart';
import 'package:flutter_mini_games/src/core/duel/duel_game_controller.dart';
import 'package:flutter_mini_games/src/game/snatch/game/logic/snatch_game_controller.dart';
import 'package:flutter_mini_games/src/game/snatch/widget/snatch_half.dart';
import 'package:flutter_mini_games/src/game/snatch/widget/snatch_tile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('both players tap at once: the first correct tap scores, then the match can be won', (tester) async {
    // Small phone
    tester.view
      ..physicalSize = const Size(320, 568)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final results = <GameResult>[];
    await tester.pumpWidget(
      FlutterMiniGames(
        onGameFinished: results.add,
        child: MaterialApp(home: Builder(builder: const SnatchGameBuilder().build)),
      ),
    );
    SnatchGameController controller() => tester.widget<SnatchHalf>(find.byType(SnatchHalf).first).controller;
    Finder tile(DuelPlayer player, int index) => find.byWidgetPredicate((widget) => widget is SnatchTile && widget.player == player && widget.index == index);
    Offset matching(DuelPlayer player) => tester.getCenter(tile(player, controller().layoutOf(player).indexOf(controller().target)));

    // The game loop clamps long frames, so time passes frame by frame
    Future<void> advance(Duration duration) async {
      for (var i = 0; i <= duration.inMilliseconds ~/ 16 + 1; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
    }

    expect(find.text('Tap when ready'), findsNWidgets(2));
    expect(find.text('How to play'), findsNWidgets(2));
    await tester.tap(find.text('Tap when ready').first);
    await tester.tap(find.text('Tap when ready').last);
    await tester.pump();
    expect(controller().phase, equals(DuelPhase.countdown));
    await advance(DuelGameController.countdownDuration);
    expect(controller().phase, equals(DuelPhase.playing));

    // The top player touches first, the bottom player while the top finger is still down
    final topFinger = await tester.startGesture(matching(DuelPlayer.top), pointer: 11);
    final bottomFinger = await tester.startGesture(matching(DuelPlayer.bottom), pointer: 12);
    await topFinger.up();
    await bottomFinger.up();
    await tester.pump();
    expect(controller().points(DuelPlayer.top), equals(1));
    expect(controller().points(DuelPlayer.bottom), equals(0));
    expect(find.text('+1'), findsOneWidget);

    // Both players tap a tile at once: a wrong one for top, the matching one for bottom
    await advance(SnatchGameController.revealDuration);
    final wrongIndex = controller().layoutOf(DuelPlayer.top).indexOf(controller().target) == 0 ? 1 : 0;
    final wrongFinger = await tester.startGesture(tester.getCenter(tile(DuelPlayer.top, wrongIndex)), pointer: 13);
    final rightFinger = await tester.startGesture(matching(DuelPlayer.bottom), pointer: 14);
    await wrongFinger.up();
    await rightFinger.up();
    await tester.pump();
    expect(controller().points(DuelPlayer.top), equals(0));
    expect(controller().penalties(DuelPlayer.top), equals(1));
    expect(controller().points(DuelPlayer.bottom), equals(1));
    expect(find.text('-1'), findsOneWidget);
    // The overlay shows the points as the score
    expect(find.text('Player 1  1 – 0'), findsOneWidget);

    for (var i = 0; i < 6; i++) {
      await advance(SnatchGameController.revealDuration);
      await tester.tapAt(matching(DuelPlayer.bottom));
      await tester.pump();
    }
    expect(controller().phase, equals(DuelPhase.finished));
    expect(find.text('You win!'), findsOneWidget);
    expect(results.single.gameId, equals('snatch'));
    expect(results.single.data['winner'], equals('bottom'));
    expect(results.single.data['points'], equals({'bottom': 7, 'top': 0}));
    expect(results.single.data['penalties'], equals({'bottom': 0, 'top': 1}));

    await tester.tap(find.text('Rematch').first);
    await tester.pump();
    expect(find.text('Tap when ready'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}
