import 'package:flutter/material.dart';
import 'package:flutter_mini_games/flutter_mini_games.dart';
import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/duel/duel_game_controller.dart';
import 'package:flutter_mini_games/src/core/duel/duel_layout.dart';
import 'package:flutter_mini_games/src/core/duel/duel_phase_overlay.dart';
import 'package:flutter_mini_games/src/core/widget/provider/game_theme_provider.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestDuelController extends GameController with DuelGameController {
  _TestDuelController() : super(gameId: 'duel');

  int points = 0;

  @override
  int duelScore(DuelPlayer player) => player == DuelPlayer.bottom ? points : 0;

  @override
  Map<String, Object?> get duelResultData => {'points': points};

  int resets = 0;
  int starts = 0;

  @override
  int get roundsToWin => 2;

  @override
  void resetRound() => resets++;

  @override
  void onRoundStarted() => starts++;

  bool tick(Duration delta) => tickDuel(delta);

  void win(DuelPlayer? player) => endRound(player);
}

void main() {
  group('DuelGameController', () {
    test('starts the countdown when both players are ready', () {
      final controller = _TestDuelController()..setReady(DuelPlayer.bottom);
      expect(controller.phase, equals(DuelPhase.ready));
      expect(controller.status, equals(GameStatus.ready));

      controller.setReady(DuelPlayer.top);

      expect(controller.phase, equals(DuelPhase.countdown));
      expect(controller.countdownSeconds, equals(3));
      expect(controller.status, equals(GameStatus.playing));
      expect(controller.moves, equals(0));
    });

    test('plays rounds until a player reaches roundsToWin', () {
      final results = <GameResult>[];
      final controller = _TestDuelController()
        ..resultListener = results.add
        ..setReady(DuelPlayer.bottom)
        ..setReady(DuelPlayer.top)
        ..tick(DuelGameController.countdownDuration);
      expect(controller.phase, equals(DuelPhase.playing));
      expect(controller.starts, equals(1));

      controller.win(DuelPlayer.top);
      expect(controller.phase, equals(DuelPhase.roundOver));
      expect(controller.roundWinner, equals(DuelPlayer.top));

      controller.tick(DuelGameController.roundOverDuration);
      expect(controller.phase, equals(DuelPhase.countdown));
      controller
        ..tick(DuelGameController.countdownDuration)
        ..win(null)
        ..tick(DuelGameController.roundOverDuration)
        ..tick(DuelGameController.countdownDuration)
        ..win(DuelPlayer.top);

      expect(controller.phase, equals(DuelPhase.finished));
      expect(controller.matchWinner, equals(DuelPlayer.top));
      expect(results.single.outcome, equals(GameOutcome.won));
      expect(results.single.data['winner'], equals('top'));
      expect(results.single.data['rounds'], equals({'bottom': 0, 'top': 2}));
    });

    test('only lets the game simulate frames that are fully part of a round', () {
      final controller = _TestDuelController()
        ..setReady(DuelPlayer.bottom)
        ..setReady(DuelPlayer.top);

      expect(controller.tick(const Duration(seconds: 1)), isFalse);
      expect(controller.tick(const Duration(seconds: 2)), isFalse, reason: 'the frame that ends the countdown');
      expect(controller.phase, equals(DuelPhase.playing));
      expect(controller.tick(const Duration(milliseconds: 16)), isTrue);
    });

    test('adds the game result data and shows the game score', () {
      final results = <GameResult>[];
      final controller = _TestDuelController()
        ..resultListener = results.add
        ..points = 7
        ..setReady(DuelPlayer.bottom)
        ..setReady(DuelPlayer.top)
        ..tick(DuelGameController.countdownDuration)
        ..win(DuelPlayer.bottom)
        ..tick(DuelGameController.roundOverDuration)
        ..tick(DuelGameController.countdownDuration)
        ..win(DuelPlayer.bottom);

      expect(controller.duelScore(DuelPlayer.bottom), equals(7));
      expect(results.single.data['points'], equals(7));
      expect(results.single.data['winner'], equals('bottom'));
    });

    test('ignores round results outside a playing round', () {
      final controller = _TestDuelController()..win(DuelPlayer.bottom);

      expect(controller.roundWins(DuelPlayer.bottom), equals(0));
    });

    test('rematch resets everything', () {
      final controller = _TestDuelController()
        ..setReady(DuelPlayer.bottom)
        ..setReady(DuelPlayer.top)
        ..tick(DuelGameController.countdownDuration)
        ..win(DuelPlayer.bottom)
        ..rematch();

      expect(controller.phase, equals(DuelPhase.ready));
      expect(controller.roundWins(DuelPlayer.bottom), equals(0));
      expect(controller.isReady(DuelPlayer.bottom), isFalse);
      expect(controller.status, equals(GameStatus.ready));
    });
  });

  group('DuelLayout', () {
    Widget app(Widget child) => MaterialApp(
      home: GameThemeProvider<CoreGameTheme>(theme: CoreGameTheme.light(), builder: (context, theme) => child),
    );

    testWidgets('rotates the top half and reports simultaneous taps per half', (tester) async {
      final taps = <DuelPlayer>[];
      await tester.pumpWidget(
        app(
          DuelLayout(
            side: (context, player) => DuelTapArea(
              onTap: () => taps.add(player),
              child: Center(child: Text(player.label)),
            ),
          ),
        ),
      );

      final rotated = find.ancestor(of: find.text('Player 2'), matching: find.byType(RotatedBox));
      expect(tester.widget<RotatedBox>(rotated).quarterTurns, equals(2));

      final top = await tester.startGesture(const Offset(400, 100));
      final bottom = await tester.startGesture(const Offset(400, 500), pointer: 2);
      await top.up();
      await bottom.up();

      expect(taps, equals([DuelPlayer.top, DuelPlayer.bottom]));
    });

    testWidgets('overlay walks through ready, countdown and the winner', (tester) async {
      final controller = _TestDuelController();
      await tester.pumpWidget(
        app(
          ListenableBuilder(
            listenable: controller,
            builder: (context, child) => DuelLayout(
              side: (context, player) => DuelPhaseOverlay(controller: controller, player: player),
            ),
          ),
        ),
      );

      expect(find.text('Tap when ready'), findsNWidgets(2));
      await tester.tap(find.text('Tap when ready').last);
      await tester.pump();
      expect(find.text('Waiting for Player 2'), findsOneWidget);

      await tester.tap(find.text('Tap when ready'));
      await tester.pump();
      expect(find.text('3'), findsNWidgets(2));

      controller
        ..tick(DuelGameController.countdownDuration)
        ..win(DuelPlayer.bottom)
        ..tick(DuelGameController.roundOverDuration)
        ..tick(DuelGameController.countdownDuration)
        ..win(DuelPlayer.bottom);
      await tester.pump();

      expect(find.text('You win!'), findsOneWidget);
      expect(find.text('You lose'), findsOneWidget);
      await tester.tap(find.text('Rematch').first);
      await tester.pump();
      expect(controller.phase, equals(DuelPhase.ready));
    });
  });
}
