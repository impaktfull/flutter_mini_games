import 'dart:math';

import 'package:flutter_mini_games/flutter_mini_games.dart';
import 'package:flutter_mini_games/src/core/duel/duel_game_controller.dart';
import 'package:flutter_mini_games/src/game/slap/game/logic/slap_game_controller.dart';
import 'package:flutter_mini_games/src/game/slap/game/model/slap_attack.dart';
import 'package:flutter_test/flutter_test.dart';

const _frame = Duration(milliseconds: 16);

/// Both players ready, countdown done: the first round is playing
SlapGameController _playing({List<GameResult>? results, int seed = 42}) {
  final controller = SlapGameController(random: Random(seed));
  if (results != null) controller.resultListener = results.add;
  controller
    ..setReady(DuelPlayer.bottom)
    ..setReady(DuelPlayer.top)
    ..tick(DuelGameController.countdownDuration);
  return controller;
}

/// Ticks in frames until [condition] holds or [max] passed
void _tickUntil(SlapGameController controller, bool Function() condition, {Duration max = const Duration(seconds: 10)}) {
  var passed = Duration.zero;
  while (!condition() && passed < max) {
    controller.tick(_frame);
    passed += _frame;
  }
}

/// Plays the round between the round result and the next playing round
void _nextRound(SlapGameController controller) {
  controller
    ..tick(DuelGameController.roundOverDuration)
    ..tick(DuelGameController.countdownDuration);
}

/// The defender holds and the attacker slaps until it lands
void _attackerWinsRound(SlapGameController controller, int pointer) {
  final attacker = controller.attacker;
  controller
    ..press(controller.defender, pointer)
    ..slap(attacker);
  _tickUntil(controller, () => controller.phase != DuelPhase.playing);
  controller.release(attacker.opponent, pointer);
}

void main() {
  group('SlapGameController', () {
    test('is a two-player duel to 5 points that runs on the game loop', () {
      final controller = SlapGameController();
      expect(SlapGameController.id, equals('slap'));
      expect(controller.roundsToWin, equals(5));
      expect(controller.isRunning, isFalse);
      expect(controller.phase, equals(DuelPhase.ready));

      controller
        ..setReady(DuelPlayer.bottom)
        ..setReady(DuelPlayer.top);
      expect(controller.isRunning, isTrue);
      expect(controller.phase, equals(DuelPhase.countdown));
    });

    test('bottom attacks first and the roles swap every round', () {
      final controller = _playing();
      expect(controller.attacker, equals(DuelPlayer.bottom));
      expect(controller.defender, equals(DuelPlayer.top));

      _attackerWinsRound(controller, 1);
      expect(controller.phase, equals(DuelPhase.roundOver));
      // The roles stay during the round result
      expect(controller.attacker, equals(DuelPlayer.bottom));

      _nextRound(controller);
      expect(controller.phase, equals(DuelPhase.playing));
      expect(controller.attacker, equals(DuelPlayer.top));
      expect(controller.defender, equals(DuelPlayer.bottom));

      _attackerWinsRound(controller, 2);
      _nextRound(controller);
      expect(controller.attacker, equals(DuelPlayer.bottom));
    });

    test('the attacker can only slap while the defender holds', () {
      final controller = _playing();
      expect(controller.attack, equals(SlapAttackState.waitingForHold));
      expect(controller.canAttack, isFalse);

      controller.slap(DuelPlayer.bottom);
      expect(controller.attack, equals(SlapAttackState.waitingForHold));
      expect(controller.moves, equals(0));

      // A finger of the attacker doesn't count
      controller.press(DuelPlayer.bottom, 1);
      expect(controller.canAttack, isFalse);

      controller.press(DuelPlayer.top, 2);
      expect(controller.attack, equals(SlapAttackState.armed));
      expect(controller.canAttack, isTrue);

      // Lifting before an attack has no penalty, the attacker waits again
      controller.release(DuelPlayer.top, 2);
      expect(controller.attack, equals(SlapAttackState.waitingForHold));
      expect(controller.phase, equals(DuelPhase.playing));
    });

    test('only the attacker can slap', () {
      final controller = _playing()
        ..press(DuelPlayer.top, 1)
        ..slap(DuelPlayer.top)
        ..fake(DuelPlayer.top);

      expect(controller.attack, equals(SlapAttackState.armed));
      expect(controller.moves, equals(0));
    });

    test('a finger put down during the countdown holds when the round starts', () {
      final controller = SlapGameController(random: Random(1))
        ..setReady(DuelPlayer.bottom)
        ..setReady(DuelPlayer.top)
        ..press(DuelPlayer.top, 1);
      expect(controller.attack, equals(SlapAttackState.waitingForHold));

      controller.tick(DuelGameController.countdownDuration);
      expect(controller.attack, equals(SlapAttackState.armed));
    });

    test('ignores attacks outside a playing round', () {
      final controller = SlapGameController()
        ..press(DuelPlayer.top, 1)
        ..slap(DuelPlayer.bottom);

      expect(controller.attack, equals(SlapAttackState.waitingForHold));
      expect(controller.moves, equals(0));
    });

    test('a slap lands after its random wind-up and the strike', () {
      final controller = _playing()
        ..press(DuelPlayer.top, 1)
        ..slap(DuelPlayer.bottom);

      expect(controller.attack, equals(SlapAttackState.windUp));
      expect(controller.moves, equals(1));
      final windUp = controller.windUp;
      expect(windUp, greaterThanOrEqualTo(SlapGameController.minWindUp));
      expect(windUp, lessThanOrEqualTo(SlapGameController.maxWindUp));

      controller.tick(windUp - const Duration(milliseconds: 1));
      expect(controller.attack, equals(SlapAttackState.windUp));
      expect(controller.handPosition, equals(0));
      expect(controller.handLift, greaterThan(0.9));

      controller.tick(const Duration(milliseconds: 1));
      expect(controller.attack, equals(SlapAttackState.strike));

      controller.tick(SlapGameController.strikeDuration ~/ 2);
      expect(controller.handPosition, closeTo(0.5, 0.01));
      expect(controller.phase, equals(DuelPhase.playing));

      controller.tick(SlapGameController.strikeDuration ~/ 2);
      expect(controller.phase, equals(DuelPhase.roundOver));
      expect(controller.roundEnd, equals(SlapRoundEnd.slapped));
      expect(controller.roundWinner, equals(DuelPlayer.bottom));
      expect(controller.roundWins(DuelPlayer.bottom), equals(1));
      expect(controller.handPosition, equals(1));
    });

    test('the timing does not depend on how tick is split', () {
      final inOneTick = _playing(seed: 7)
        ..press(DuelPlayer.top, 1)
        ..slap(DuelPlayer.bottom);
      inOneTick.tick(inOneTick.windUp + SlapGameController.strikeDuration);
      expect(inOneTick.roundEnd, equals(SlapRoundEnd.slapped));

      final inFrames = _playing(seed: 7)
        ..press(DuelPlayer.top, 1)
        ..slap(DuelPlayer.bottom);
      _tickUntil(inFrames, () => inFrames.roundEnd != null);
      expect(inFrames.roundEnd, equals(SlapRoundEnd.slapped));
    });

    test('lifting during the strike dodges the slap', () {
      final controller = _playing()
        ..press(DuelPlayer.top, 1)
        ..slap(DuelPlayer.bottom);
      controller.tick(controller.windUp + const Duration(milliseconds: 200));
      expect(controller.attack, equals(SlapAttackState.strike));

      controller.release(DuelPlayer.top, 1);

      expect(controller.phase, equals(DuelPhase.roundOver));
      expect(controller.roundEnd, equals(SlapRoundEnd.dodged));
      expect(controller.roundWinner, equals(DuelPlayer.top));
    });

    test('lifting during the wind-up of a real slap also dodges it', () {
      final controller = _playing()
        ..press(DuelPlayer.top, 1)
        ..slap(DuelPlayer.bottom)
        ..tick(const Duration(milliseconds: 100))
        ..release(DuelPlayer.top, 1);

      expect(controller.roundEnd, equals(SlapRoundEnd.dodged));
      expect(controller.roundWinner, equals(DuelPlayer.top));
    });

    test('the defender keeps holding while one of two fingers stays on the target', () {
      final controller = _playing()
        ..press(DuelPlayer.top, 1)
        ..press(DuelPlayer.top, 2)
        ..slap(DuelPlayer.bottom)
        ..tick(const Duration(milliseconds: 100))
        ..release(DuelPlayer.top, 1);

      expect(controller.isHolding(DuelPlayer.top), isTrue);
      expect(controller.attack, equals(SlapAttackState.windUp));
    });

    test('a fake looks like a slap, goes back and lets the attacker attack again', () {
      final controller = _playing()
        ..press(DuelPlayer.top, 1)
        ..fake(DuelPlayer.bottom);

      expect(controller.attack, equals(SlapAttackState.windUp));
      expect(controller.isFake, isTrue);
      expect(controller.fakesLeft, equals(SlapGameController.maxFakes - 1));
      expect(controller.moves, equals(1));

      controller.tick(controller.windUp);
      expect(controller.attack, equals(SlapAttackState.retract));
      expect(controller.handPosition, equals(0));

      controller.tick(SlapGameController.retractDuration);
      expect(controller.attack, equals(SlapAttackState.armed));
      expect(controller.isFake, isFalse);
      expect(controller.phase, equals(DuelPhase.playing));
      expect(controller.roundWins(DuelPlayer.bottom), equals(0));
      expect(controller.roundWins(DuelPlayer.top), equals(0));
    });

    test('lifting on a fake costs the defender the round', () {
      final duringWindUp = _playing()
        ..press(DuelPlayer.top, 1)
        ..fake(DuelPlayer.bottom)
        ..tick(const Duration(milliseconds: 100))
        ..release(DuelPlayer.top, 1);
      expect(duringWindUp.roundEnd, equals(SlapRoundEnd.flinched));
      expect(duringWindUp.roundWinner, equals(DuelPlayer.bottom));

      final duringRetract = _playing()
        ..press(DuelPlayer.top, 1)
        ..fake(DuelPlayer.bottom);
      duringRetract
        ..tick(duringRetract.windUp + const Duration(milliseconds: 50))
        ..release(DuelPlayer.top, 1);
      expect(duringRetract.roundEnd, equals(SlapRoundEnd.flinched));
      expect(duringRetract.roundWinner, equals(DuelPlayer.bottom));
    });

    test('the attacker has a limited number of fakes per round', () {
      final controller = _playing()..press(DuelPlayer.top, 1);
      for (var i = 0; i < SlapGameController.maxFakes; i++) {
        controller.fake(DuelPlayer.bottom);
        _tickUntil(controller, () => controller.attack == SlapAttackState.armed);
      }
      expect(controller.fakesLeft, equals(0));
      expect(controller.canFake, isFalse);
      expect(controller.canAttack, isTrue);

      controller.fake(DuelPlayer.bottom);
      expect(controller.attack, equals(SlapAttackState.armed));

      // A new round gives new fakes
      controller.slap(DuelPlayer.bottom);
      _tickUntil(controller, () => controller.phase != DuelPhase.playing);
      _nextRound(controller);
      expect(controller.fakesLeft, equals(SlapGameController.maxFakes));
    });

    test('the wind-up is random and reproducible with a seeded Random', () {
      List<Duration> windUps(int seed) {
        final controller = _playing(seed: seed)..press(DuelPlayer.top, 1);
        final result = <Duration>[];
        for (var i = 0; i < SlapGameController.maxFakes; i++) {
          controller.fake(DuelPlayer.bottom);
          result.add(controller.windUp);
          _tickUntil(controller, () => controller.attack == SlapAttackState.armed);
        }
        return result;
      }

      expect(windUps(3), equals(windUps(3)));
      expect(windUps(3).toSet(), hasLength(SlapGameController.maxFakes));
      expect(windUps(3), isNot(equals(windUps(4))));
    });

    test('the defender wins the round when the attacker is too slow', () {
      final controller = _playing()..press(DuelPlayer.top, 1);
      expect(controller.attackTimeLeft, equals(1));

      controller.tick(SlapGameController.attackTimeLimit ~/ 2);
      expect(controller.attackTimeLeft, closeTo(0.5, 0.001));

      // The timer only runs while the defender holds
      controller
        ..release(DuelPlayer.top, 1)
        ..tick(const Duration(seconds: 30))
        ..press(DuelPlayer.top, 1);
      expect(controller.phase, equals(DuelPhase.playing));

      controller.tick(SlapGameController.attackTimeLimit ~/ 2);
      expect(controller.roundEnd, equals(SlapRoundEnd.tooSlow));
      expect(controller.roundWinner, equals(DuelPlayer.top));
    });

    test('scores to 5 and reports the winner', () {
      final results = <GameResult>[];
      final controller = _playing(results: results);
      var pointer = 0;
      // The attacker wins every round: bottom wins the odd rounds, top the even ones,
      // until bottom has 5 points in round 9
      while (controller.phase != DuelPhase.finished) {
        _attackerWinsRound(controller, pointer++);
        if (controller.phase == DuelPhase.roundOver) _nextRound(controller);
      }

      expect(pointer, equals(9));
      expect(controller.matchWinner, equals(DuelPlayer.bottom));
      expect(controller.roundWins(DuelPlayer.bottom), equals(5));
      expect(controller.roundWins(DuelPlayer.top), equals(4));
      expect(controller.isRunning, isFalse);
      expect(results.single.outcome, equals(GameOutcome.won));
      expect(results.single.score, isNull);
      expect(results.single.data['winner'], equals('bottom'));
      expect(results.single.data['rounds'], equals({'bottom': 5, 'top': 4}));
    });

    test('rematch starts a new match with bottom attacking', () {
      final controller = _playing();
      _attackerWinsRound(controller, 1);
      _nextRound(controller);
      expect(controller.attacker, equals(DuelPlayer.top));

      controller.rematch();

      expect(controller.phase, equals(DuelPhase.ready));
      expect(controller.attacker, equals(DuelPlayer.bottom));
      expect(controller.roundWins(DuelPlayer.bottom), equals(0));
      expect(controller.roundEnd, isNull);
      expect(controller.attack, equals(SlapAttackState.waitingForHold));
    });
  });
}
