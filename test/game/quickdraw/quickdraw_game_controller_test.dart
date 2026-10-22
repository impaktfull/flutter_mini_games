import 'dart:math';

import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/duel/duel_game_controller.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';
import 'package:flutter_mini_games/src/game/quickdraw/game/logic/quickdraw_game_controller.dart';
import 'package:flutter_mini_games/src/game/quickdraw/game/model/quickdraw_signal.dart';
import 'package:flutter_test/flutter_test.dart';

const _frame = Duration(milliseconds: 16);

QuickdrawGameController _started({int seed = 42, List<GameResult>? results}) {
  final controller = QuickdrawGameController(random: Random(seed));
  if (results != null) controller.resultListener = results.add;
  return controller
    ..setReady(DuelPlayer.bottom)
    ..setReady(DuelPlayer.top)
    ..tick(DuelGameController.countdownDuration);
}

/// Ticks in frames until GO is shown, returns the waited time
Duration _waitForGo(QuickdrawGameController controller) {
  var waited = Duration.zero;
  for (var i = 0; i < 10000; i++) {
    if (controller.isGo) return waited;
    controller.tick(_frame);
    waited += _frame;
  }
  fail('GO was never shown');
}

/// Plays a round won by [player] with a reaction of [reaction], then waits for the next countdown to end
void _winRound(QuickdrawGameController controller, DuelPlayer player, Duration reaction) {
  _waitForGo(controller);
  controller
    ..tick(reaction)
    ..onTap(player);
}

void _nextRound(QuickdrawGameController controller) {
  controller
    ..tick(DuelGameController.roundOverDuration)
    ..tick(DuelGameController.countdownDuration);
}

void main() {
  group('QuickdrawGameController', () {
    test('ignores taps and does not run before both players are ready', () {
      final controller = QuickdrawGameController(random: Random(1))..onTap(DuelPlayer.bottom);

      expect(controller.isRunning, isFalse);
      expect(controller.phase, equals(DuelPhase.ready));
      expect(controller.moves, equals(0));
      expect(controller.status, equals(GameStatus.ready));
    });

    test('ignores taps during the countdown', () {
      final controller = QuickdrawGameController(random: Random(1))
        ..setReady(DuelPlayer.bottom)
        ..setReady(DuelPlayer.top)
        ..onTap(DuelPlayer.bottom);

      expect(controller.phase, equals(DuelPhase.countdown));
      expect(controller.roundWins(DuelPlayer.top), equals(0));
      expect(controller.moves, equals(0));
    });

    test('the wait before GO is always between 1.5 and 5 seconds', () {
      for (var seed = 0; seed < 200; seed++) {
        final controller = _started(seed: seed);
        expect(controller.delay, greaterThanOrEqualTo(QuickdrawGameController.minDelay));
        expect(controller.delay, lessThanOrEqualTo(QuickdrawGameController.maxDelay));
      }
    });

    test('the same seed gives the same waits', () {
      final a = _started(seed: 7);
      final b = _started(seed: 7);

      expect(a.delay, equals(b.delay));
    });

    test('shows GO after the wait, not before', () {
      final controller = _started();
      expect(controller.signal, equals(QuickdrawSignal.waiting));

      controller.tick(controller.delay - const Duration(milliseconds: 1));
      expect(controller.isGo, isFalse);
      controller.tick(const Duration(milliseconds: 1));
      expect(controller.isGo, isTrue);
      expect(controller.phase, equals(DuelPhase.playing));
    });

    test('the frame that ends the countdown does not count for the wait', () {
      final controller = QuickdrawGameController(random: Random(3))
        ..setReady(DuelPlayer.bottom)
        ..setReady(DuelPlayer.top)
        ..tick(DuelGameController.countdownDuration + const Duration(seconds: 10));

      expect(controller.phase, equals(DuelPhase.playing));
      expect(controller.isGo, isFalse);
    });

    test('the first tap after GO wins the round and measures the reaction time', () {
      final controller = _started();
      _waitForGo(controller);
      controller
        ..tick(const Duration(milliseconds: 200))
        ..tick(const Duration(milliseconds: 34))
        ..onTap(DuelPlayer.top);

      expect(controller.phase, equals(DuelPhase.roundOver));
      expect(controller.roundWinner, equals(DuelPlayer.top));
      expect(controller.roundWins(DuelPlayer.top), equals(1));
      expect(controller.roundReactionMs, equals(234));
      expect(controller.earlyPlayer, isNull);
      expect(controller.bestReactionMs(DuelPlayer.top), equals(234));
      expect(controller.bestReactionMs(DuelPlayer.bottom), isNull);
    });

    test('a tap before GO loses the round for that player', () {
      final controller = _started()
        ..tick(const Duration(milliseconds: 500))
        ..onTap(DuelPlayer.bottom);

      expect(controller.phase, equals(DuelPhase.roundOver));
      expect(controller.earlyPlayer, equals(DuelPlayer.bottom));
      expect(controller.roundWinner, equals(DuelPlayer.top));
      expect(controller.roundWins(DuelPlayer.top), equals(1));
      expect(controller.roundReactionMs, isNull);
      expect(controller.bestReactionMs(DuelPlayer.top), isNull);
    });

    test('near-simultaneous taps: the first one wins, the second is ignored', () {
      final controller = _started();
      _waitForGo(controller);
      controller
        ..tick(const Duration(milliseconds: 180))
        ..onTap(DuelPlayer.bottom)
        ..onTap(DuelPlayer.top);

      expect(controller.roundWinner, equals(DuelPlayer.bottom));
      expect(controller.roundWins(DuelPlayer.bottom), equals(1));
      expect(controller.roundWins(DuelPlayer.top), equals(0));
      expect(controller.moves, equals(1));

      // Same frame, other order
      final other = _started();
      _waitForGo(other);
      other
        ..tick(const Duration(milliseconds: 180))
        ..onTap(DuelPlayer.top)
        ..onTap(DuelPlayer.bottom);
      expect(other.roundWinner, equals(DuelPlayer.top));
    });

    test('a new round waits again after the round result and the countdown', () {
      final controller = _started(seed: 5);
      _winRound(controller, DuelPlayer.bottom, const Duration(milliseconds: 250));
      controller.tick(DuelGameController.roundOverDuration);
      expect(controller.phase, equals(DuelPhase.countdown));
      expect(controller.roundReactionMs, isNull);

      controller.tick(DuelGameController.countdownDuration);
      expect(controller.phase, equals(DuelPhase.playing));
      expect(controller.signal, equals(QuickdrawSignal.waiting));
      expect(controller.delay, greaterThanOrEqualTo(QuickdrawGameController.minDelay));
    });

    test('best of 5: the first player to win 3 rounds wins the match with the best reaction times', () {
      final results = <GameResult>[];
      final controller = _started(results: results);

      _winRound(controller, DuelPlayer.bottom, const Duration(milliseconds: 300));
      _nextRound(controller);
      _winRound(controller, DuelPlayer.top, const Duration(milliseconds: 260));
      _nextRound(controller);
      // Top taps too early: bottom wins the round
      controller
        ..tick(const Duration(milliseconds: 100))
        ..onTap(DuelPlayer.top);
      _nextRound(controller);
      _winRound(controller, DuelPlayer.top, const Duration(milliseconds: 240));
      _nextRound(controller);
      expect(controller.phase, equals(DuelPhase.playing));
      expect(results, isEmpty);
      _winRound(controller, DuelPlayer.bottom, const Duration(milliseconds: 210));

      expect(controller.phase, equals(DuelPhase.finished));
      expect(controller.matchWinner, equals(DuelPlayer.bottom));
      expect(controller.isRunning, isFalse);
      expect(controller.status, equals(GameStatus.finished));
      expect(controller.moves, equals(5));

      final result = results.single;
      expect(result.gameId, equals('quickdraw'));
      expect(result.outcome, equals(GameOutcome.won));
      expect(result.score, isNull);
      expect(result.data['winner'], equals('bottom'));
      expect(result.data['rounds'], equals({'bottom': 3, 'top': 2}));
      expect(result.data['bestReactionMs'], equals({'bottom': 210, 'top': 240}));

      // Taps after the match are ignored
      controller.onTap(DuelPlayer.top);
      expect(controller.roundWins(DuelPlayer.top), equals(2));
    });

    test('rematch resets rounds and reaction times', () {
      final results = <GameResult>[];
      final controller = _started(results: results);
      for (var i = 0; i < QuickdrawGameController.winsNeeded; i++) {
        _winRound(controller, DuelPlayer.top, const Duration(milliseconds: 300));
        if (i < QuickdrawGameController.winsNeeded - 1) _nextRound(controller);
      }
      expect(controller.matchWinner, equals(DuelPlayer.top));

      controller.rematch();

      expect(controller.phase, equals(DuelPhase.ready));
      expect(controller.status, equals(GameStatus.ready));
      expect(controller.roundWins(DuelPlayer.top), equals(0));
      expect(controller.bestReactionMs(DuelPlayer.top), isNull);
      expect(controller.moves, equals(0));
      expect(controller.result, isNull);

      controller
        ..setReady(DuelPlayer.top)
        ..setReady(DuelPlayer.bottom)
        ..tick(DuelGameController.countdownDuration);
      expect(controller.phase, equals(DuelPhase.playing));
      expect(controller.signal, equals(QuickdrawSignal.waiting));
    });

    test('leaving during a match is reported as abandoned', () {
      final results = <GameResult>[];
      _started(results: results).dispose();

      expect(results.single.outcome, equals(GameOutcome.abandoned));
    });
  });
}
