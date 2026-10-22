import 'package:flutter/material.dart';
import 'package:flutter_mini_games/flutter_mini_games.dart';
import 'package:flutter_mini_games/src/core/duel/duel_game_controller.dart';
import 'package:flutter_mini_games/src/game/slap/game/logic/slap_game_controller.dart';
import 'package:flutter_mini_games/src/game/slap/game/model/slap_attack.dart';
import 'package:flutter_mini_games/src/game/slap/widget/slap_side.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the defender holds the target while the attacker slaps', (tester) async {
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
          child: Builder(builder: const SlapGameBuilder().build),
        ),
      ),
    );
    SlapGameController controller() => tester.widget<SlapSide>(find.byType(SlapSide).first).controller;

    expect(find.text('Attack'), findsOneWidget);
    expect(find.text('Defend'), findsOneWidget);
    // Both halves show how to play while getting ready
    expect(find.text('Defend: hold your target, lift to dodge a slap'), findsNWidgets(2));
    await tester.tap(find.text('Tap when ready').first);
    await tester.tap(find.text('Tap when ready').last);
    await tester.pump();
    expect(controller().phase, equals(DuelPhase.countdown));
    // The game loop drives the countdown
    for (var frame = 0; frame < 200 && controller().phase != DuelPhase.playing; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(controller().phase, equals(DuelPhase.playing));
    expect(controller().attacker, equals(DuelPlayer.bottom));
    expect(find.text('Hold your target'), findsOneWidget);

    // Player 2 (top, rotated) holds the target, Player 1 taps slap at the same time
    final target = find.byKey(const ValueKey('slap_target'));
    final hold = await tester.startGesture(tester.getCenter(target), pointer: 1);
    await tester.pump();
    expect(controller().isHolding(DuelPlayer.top), isTrue);
    expect(find.text('Holding'), findsOneWidget);
    expect(find.text('Slap or fake!'), findsOneWidget);

    final slap = await tester.startGesture(tester.getCenter(find.byKey(const ValueKey('slap_button'))), pointer: 2);
    await slap.up();
    await tester.pump();
    expect(controller().attack, equals(SlapAttackState.windUp));

    // Still holding when it lands
    for (var frame = 0; frame < 100 && controller().phase == DuelPhase.playing; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(controller().roundEnd, equals(SlapRoundEnd.slapped));
    expect(controller().roundWins(DuelPlayer.bottom), equals(1));
    expect(find.text('You win the round'), findsOneWidget);
    expect(find.text('Your slap landed!'), findsOneWidget);
    expect(find.text('Slapped!'), findsOneWidget);
    await hold.up();

    // Next round: roles swap, the bottom player defends and dodges
    for (var frame = 0; frame < 400 && controller().phase != DuelPhase.playing; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(controller().attacker, equals(DuelPlayer.top));
    final dodge = await tester.startGesture(tester.getCenter(find.byKey(const ValueKey('slap_target'))), pointer: 3);
    await tester.pump();
    final slapTop = await tester.startGesture(tester.getCenter(find.byKey(const ValueKey('slap_button'))), pointer: 4);
    await slapTop.up();
    await tester.pump(const Duration(milliseconds: 16));
    await dodge.up();
    await tester.pump();
    expect(controller().roundEnd, equals(SlapRoundEnd.dodged));
    expect(controller().roundWins(DuelPlayer.bottom), equals(2));
    expect(find.text('Dodged!'), findsOneWidget);
    expect(find.text('Player 1 dodged your slap'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
  });
}
