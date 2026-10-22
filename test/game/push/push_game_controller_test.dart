import 'dart:math';

import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/duel/duel_game_controller.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';
import 'package:flutter_mini_games/src/game/push/game/logic/push_game_controller.dart';
import 'package:flutter_test/flutter_test.dart';

const _frame = Duration(milliseconds: 16);

PushGameController _playing({List<GameResult>? results}) {
  final controller = PushGameController();
  if (results != null) controller.resultListener = results.add;
  controller
    ..setReady(DuelPlayer.bottom)
    ..setReady(DuelPlayer.top)
    ..tick(DuelGameController.countdownDuration);
  expect(controller.phase, equals(DuelPhase.playing));
  return controller;
}

/// [player] taps straight at the opponent until the round is over
void _winRound(PushGameController controller, DuelPlayer player) {
  for (var i = 0; i < 2000 && controller.isPlaying; i++) {
    if (i % 5 == 0) controller.push(player);
    controller.tick(_frame);
  }
  expect(controller.isPlaying, isFalse);
}

/// Next round: round over pause and countdown
void _nextRound(PushGameController controller) {
  controller
    ..tick(DuelGameController.roundOverDuration)
    ..tick(DuelGameController.countdownDuration);
  expect(controller.phase, equals(DuelPhase.playing));
}

double _dot(Offset a, Offset b) => a.dx * b.dx + a.dy * b.dy;

void main() {
  group('PushGameController', () {
    test('starts with both discs on their start lines and a full ring', () {
      final controller = PushGameController();

      expect(controller.phase, equals(DuelPhase.ready));
      expect(controller.isRunning, isFalse);
      expect(controller.ringRadius, equals(PushGameController.initialRingRadius));
      expect(controller.disc(DuelPlayer.bottom).position, equals(const Offset(0, PushGameController.startDistance)));
      expect(controller.disc(DuelPlayer.top).position, equals(const Offset(0, -PushGameController.startDistance)));
    });

    test('ignores pushes until the round is playing', () {
      final controller = PushGameController()
        ..setReady(DuelPlayer.bottom)
        ..push(DuelPlayer.bottom)
        ..setReady(DuelPlayer.top)
        ..push(DuelPlayer.top);

      expect(controller.phase, equals(DuelPhase.countdown));
      expect(controller.disc(DuelPlayer.bottom).velocity, equals(Offset.zero));
      expect(controller.disc(DuelPlayer.top).velocity, equals(Offset.zero));
      expect(controller.moves, equals(0));
    });

    test('a tap pushes the disc towards the opponent, friction slows it down', () {
      final controller = _playing()..push(DuelPlayer.bottom);

      final velocity = controller.disc(DuelPlayer.bottom).velocity;
      expect(velocity.dx, closeTo(0, 1e-9));
      expect(velocity.dy, closeTo(-PushGameController.pushImpulse, 1e-9));
      expect(controller.moves, equals(1));

      controller.tick(const Duration(milliseconds: 500));

      final disc = controller.disc(DuelPlayer.bottom);
      expect(disc.position.dy, lessThan(PushGameController.startDistance));
      expect(disc.velocity.distance, closeTo(PushGameController.pushImpulse * exp(-PushGameController.friction * 0.5), 1e-6));

      // The top player pushes downwards, towards the bottom disc
      controller.push(DuelPlayer.top);
      expect(controller.disc(DuelPlayer.top).velocity.dy, greaterThan(0));
    });

    test('the tap position aims left or right from the player\'s view', () {
      final controller = _playing();

      // Bottom player looks up: their right is +x
      final bottomRight = controller.aimDirection(DuelPlayer.bottom, 1);
      expect(bottomRight.dx, greaterThan(0));
      expect(bottomRight.dy, lessThan(0));
      expect(atan2(bottomRight.dx, -bottomRight.dy), closeTo(PushGameController.maxAimAngle, 1e-9));
      expect(controller.aimDirection(DuelPlayer.bottom, -1).dx, lessThan(0));

      // Top player looks down: their right is -x
      final topRight = controller.aimDirection(DuelPlayer.top, 1);
      expect(topRight.dx, lessThan(0));
      expect(topRight.dy, greaterThan(0));

      controller.push(DuelPlayer.bottom, aim: 1);
      expect(controller.disc(DuelPlayer.bottom).velocity.dx, greaterThan(0));
    });

    test('holding keeps a weak push in the aimed direction until released', () {
      final controller = _playing()..hold(DuelPlayer.bottom, -1);
      expect(controller.holdAim(DuelPlayer.bottom), equals(-1));

      for (var i = 0; i < 30; i++) {
        controller.tick(_frame);
      }
      final disc = controller.disc(DuelPlayer.bottom);
      expect(disc.velocity.dx, lessThan(0));
      expect(disc.velocity.dy, lessThan(0));
      expect(disc.position.dx, lessThan(0));
      // Holding is not a move and much weaker than tapping
      expect(controller.moves, equals(0));
      expect(disc.velocity.distance, lessThan(PushGameController.pushImpulse));

      controller.hold(DuelPlayer.bottom, null);
      expect(controller.holdAim(DuelPlayer.bottom), isNull);
      final speed = controller.disc(DuelPlayer.bottom).velocity.distance;
      controller.tick(const Duration(milliseconds: 200));
      expect(controller.disc(DuelPlayer.bottom).velocity.distance, lessThan(speed));
    });

    test('discs collide and pass on their momentum', () {
      final controller = _playing();
      for (var i = 0; i < 4; i++) {
        controller.push(DuelPlayer.bottom);
      }
      Offset momentum() => controller.disc(DuelPlayer.bottom).velocity + controller.disc(DuelPlayer.top).velocity;

      const step = Duration(milliseconds: 4);
      var before = momentum();
      var collided = false;
      for (var i = 0; i < 500 && !collided; i++) {
        before = momentum();
        controller.tick(step);
        collided = controller.disc(DuelPlayer.top).velocity != Offset.zero;
      }
      expect(collided, isTrue);

      final bottom = controller.disc(DuelPlayer.bottom);
      final top = controller.disc(DuelPlayer.top);
      // The top disc is knocked away from the bottom disc (upwards), faster than the bottom disc goes on
      expect(top.velocity.dy, lessThan(0));
      expect(top.velocity.distance, greaterThan(bottom.velocity.distance));
      // Momentum is conserved apart from the friction of this step
      final decay = exp(-PushGameController.friction * step.inMicroseconds / Duration.microsecondsPerSecond);
      expect((momentum() - before * decay).distance, lessThan(1e-6));
      // The discs don't overlap
      expect((top.position - bottom.position).distance, greaterThanOrEqualTo(PushGameController.discRadius * 2 - 1e-9));
      expect(_dot(top.velocity - bottom.velocity, top.position - bottom.position), greaterThanOrEqualTo(0));
    });

    test('a disc whose center leaves the ring loses the round', () {
      final controller = _playing();

      _winRound(controller, DuelPlayer.bottom);

      expect(controller.disc(DuelPlayer.top).position.distance, greaterThan(controller.ringRadius));
      expect(controller.disc(DuelPlayer.bottom).position.distance, lessThanOrEqualTo(controller.ringRadius));
      expect(controller.phase, equals(DuelPhase.roundOver));
      expect(controller.roundWinner, equals(DuelPlayer.bottom));
      expect(controller.roundWins(DuelPlayer.bottom), equals(1));
      expect(controller.roundWins(DuelPlayer.top), equals(0));
    });

    test('the ring shrinks after a delay until a disc is out', () {
      final controller = _playing()..tick(PushGameController.shrinkDelay);
      expect(controller.ringRadius, closeTo(PushGameController.initialRingRadius, 1e-9));

      controller.tick(const Duration(seconds: 2));
      expect(controller.ringRadius, closeTo(PushGameController.initialRingRadius - 2 * PushGameController.shrinkSpeed, 1e-6));

      // The top disc moved a bit towards the center, so the bottom disc is out first
      controller.hold(DuelPlayer.top, 0);
      controller.tick(const Duration(milliseconds: 100));
      controller.hold(DuelPlayer.top, null);
      for (var i = 0; i < 2000 && controller.isPlaying; i++) {
        controller.tick(const Duration(milliseconds: 50));
      }

      expect(controller.roundWinner, equals(DuelPlayer.top));
      expect(controller.ringRadius, lessThan(PushGameController.startDistance + 0.01));
      expect(controller.ringRadius, greaterThan(0));
    });

    test('both discs leaving the ring at once is a drawn round', () {
      final controller = _playing();
      for (var i = 0; i < 2000 && controller.isPlaying; i++) {
        controller.tick(const Duration(milliseconds: 50));
      }

      expect(controller.phase, equals(DuelPhase.roundOver));
      expect(controller.roundWinner, isNull);
      expect(controller.roundWins(DuelPlayer.bottom), equals(0));
      expect(controller.roundWins(DuelPlayer.top), equals(0));
    });

    test('a new round resets the discs and the ring', () {
      final controller = _playing();
      _winRound(controller, DuelPlayer.bottom);
      _nextRound(controller);

      expect(controller.ringRadius, equals(PushGameController.initialRingRadius));
      expect(controller.roundSeconds, equals(0));
      expect(controller.disc(DuelPlayer.top).position, equals(PushGameController.startPosition(DuelPlayer.top)));
      expect(controller.disc(DuelPlayer.bottom).velocity, equals(Offset.zero));
    });

    test('best of 3 finishes with the winner and no score, rematch starts over', () {
      final results = <GameResult>[];
      final controller = _playing(results: results);

      _winRound(controller, DuelPlayer.top);
      _nextRound(controller);
      _winRound(controller, DuelPlayer.bottom);
      expect(controller.phase, equals(DuelPhase.roundOver));
      _nextRound(controller);
      _winRound(controller, DuelPlayer.top);

      expect(controller.phase, equals(DuelPhase.finished));
      expect(controller.matchWinner, equals(DuelPlayer.top));
      expect(controller.isRunning, isFalse);
      final result = results.single;
      expect(result.gameId, equals(PushGameController.id));
      expect(result.outcome, equals(GameOutcome.won));
      expect(result.score, isNull);
      expect(result.data['winner'], equals('top'));
      expect(result.data['rounds'], equals({'bottom': 1, 'top': 2}));

      // Taps after the match are ignored
      final moves = controller.moves;
      controller.push(DuelPlayer.bottom);
      expect(controller.moves, equals(moves));

      controller.rematch();
      expect(controller.phase, equals(DuelPhase.ready));
      expect(controller.status, equals(GameStatus.ready));
      expect(controller.roundWins(DuelPlayer.top), equals(0));
      expect(controller.ringRadius, equals(PushGameController.initialRingRadius));
      expect(controller.disc(DuelPlayer.bottom).position, equals(PushGameController.startPosition(DuelPlayer.bottom)));
    });

    test('the physics does not depend on the frame rate', () {
      final slow = _playing()..push(DuelPlayer.bottom, aim: 0.5);
      final fast = _playing()..push(DuelPlayer.bottom, aim: 0.5);
      slow.hold(DuelPlayer.top, -0.5);
      fast.hold(DuelPlayer.top, -0.5);

      for (var i = 0; i < 20; i++) {
        slow.tick(const Duration(milliseconds: 50));
      }
      for (var i = 0; i < 125; i++) {
        fast.tick(const Duration(milliseconds: 8));
      }

      for (final player in DuelPlayer.values) {
        expect((slow.disc(player).position - fast.disc(player).position).distance, lessThan(0.01));
      }
    });
  });
}
