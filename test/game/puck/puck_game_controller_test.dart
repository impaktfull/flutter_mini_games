import 'package:flutter_mini_games/flutter_mini_games.dart';
import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/duel/duel_game_controller.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/game/puck/game/logic/puck_game_controller.dart';
import 'package:flutter_test/flutter_test.dart';

const _frame = Duration(milliseconds: 16);
const _w = PuckGameController.width;
const _h = PuckGameController.height;

PuckGameController _playing({List<GameResult>? results}) {
  final controller = PuckGameController();
  if (results != null) controller.resultListener = results.add;
  controller
    ..setReady(DuelPlayer.bottom)
    ..setReady(DuelPlayer.top)
    ..tick(DuelGameController.countdownDuration);
  expect(controller.phase, equals(DuelPhase.playing));
  return controller;
}

void _run(PuckGameController controller, Duration duration, {Duration frame = _frame}) {
  for (var elapsed = Duration.zero; elapsed < duration; elapsed += frame) {
    controller.tick(frame);
  }
}

/// Shoots the puck into the goal of [conceding] and plays until the next round starts
void _score(PuckGameController controller, DuelPlayer conceding) {
  final toBottom = conceding == DuelPlayer.bottom;
  controller
    ..debugSetPuck(Offset(_w / 2, toBottom ? _h - 0.02 : 0.02), Offset(0, toBottom ? 2 : -2))
    ..tick(_frame);
}

void _nextRound(PuckGameController controller) => controller
  ..tick(DuelGameController.roundOverDuration)
  ..tick(DuelGameController.countdownDuration);

void main() {
  group('PuckGameController', () {
    test('starts with the puck in the middle and the mallets in front of their goals', () {
      final controller = _playing();

      expect(controller.puck, equals(const Offset(_w / 2, _h / 2)));
      expect(controller.mallet(DuelPlayer.bottom), equals(PuckGameController.malletStart(DuelPlayer.bottom)));
      expect(controller.mallet(DuelPlayer.top), equals(PuckGameController.malletStart(DuelPlayer.top)));
      expect(controller.isRunning, isTrue);
    });

    test('ignores mallet moves before the round plays', () {
      final controller = PuckGameController()..moveMallet(DuelPlayer.bottom, const Offset(0.2, 1.2));
      controller
        ..setReady(DuelPlayer.bottom)
        ..setReady(DuelPlayer.top)
        ..moveMallet(DuelPlayer.bottom, const Offset(0.2, 1.2))
        ..tick(DuelGameController.countdownDuration);
      _run(controller, const Duration(milliseconds: 500));

      expect(controller.mallet(DuelPlayer.bottom), equals(PuckGameController.malletStart(DuelPlayer.bottom)));
    });

    test('keeps every mallet in its own half and on the table', () {
      final controller = _playing()
        ..moveMallet(DuelPlayer.bottom, const Offset(-1, 0.1))
        ..moveMallet(DuelPlayer.top, const Offset(5, 1.5));
      _run(controller, const Duration(seconds: 1));

      const r = PuckGameController.malletRadius;
      expect((controller.mallet(DuelPlayer.bottom) - const Offset(r, _h / 2 + r)).distance, lessThan(1e-9));
      expect((controller.mallet(DuelPlayer.top) - const Offset(_w - r, _h / 2 - r)).distance, lessThan(1e-9));
    });

    test('a mallet follows the finger with a limited speed', () {
      final controller = _playing()..moveMallet(DuelPlayer.bottom, const Offset(0.5, 0.9));
      final start = controller.mallet(DuelPlayer.bottom);
      controller.tick(_frame);

      final moved = (controller.mallet(DuelPlayer.bottom) - start).distance;
      expect(moved, closeTo(PuckGameController.maxMalletSpeed * 0.016, 1e-9));
      expect(controller.malletVelocity(DuelPlayer.bottom).dy, closeTo(-PuckGameController.maxMalletSpeed, 1e-6));
    });

    test('the puck bounces off the side walls and the end walls next to the goal', () {
      final controller = _playing()..debugSetPuck(const Offset(0.1, 0.6), const Offset(-1, 0));
      _run(controller, const Duration(milliseconds: 200));

      expect(controller.puckVelocity.dx, greaterThan(0));
      expect(controller.puckVelocity.dx, lessThan(1));
      expect(controller.puck.dx, greaterThanOrEqualTo(PuckGameController.puckRadius));

      controller.debugSetPuck(const Offset(0.1, 0.1), const Offset(0, -1));
      _run(controller, const Duration(milliseconds: 200));
      expect(controller.puckVelocity.dy, greaterThan(0));
      expect(controller.phase, equals(DuelPhase.playing));
    });

    test('the puck bounces off a goal post', () {
      const post = PuckGameController.width / 2 - PuckGameController.goalWidth / 2;
      final controller = _playing()
        ..debugSetMallet(DuelPlayer.top, const Offset(0.9, 0.7))
        ..debugSetPuck(const Offset(post + 0.02, 0.1), const Offset(0, -1));
      _run(controller, const Duration(milliseconds: 200));

      expect(controller.puckVelocity.dy, greaterThan(0));
      expect(controller.phase, equals(DuelPhase.playing));
    });

    test('friction slows the puck down independent of the frame rate', () {
      final fast = _playing()..debugSetPuck(const Offset(0.2, _h / 2), const Offset(0.3, 0));
      final slow = _playing()..debugSetPuck(const Offset(0.2, _h / 2), const Offset(0.3, 0));
      _run(fast, const Duration(seconds: 1), frame: const Duration(milliseconds: 10));
      _run(slow, const Duration(seconds: 1), frame: const Duration(milliseconds: 50));

      const expected = 0.3 * 0.7046880897187134; // e^(-0.35)
      expect(fast.puckVelocity.dx, closeTo(expected, 1e-3));
      expect(slow.puckVelocity.dx, closeTo(expected, 1e-3));
      expect(fast.puck.dx, closeTo(slow.puck.dx, 1e-3));
    });

    test('a stationary mallet only reflects the puck', () {
      final controller = _playing()
        ..debugSetMallet(DuelPlayer.bottom, const Offset(0.5, 1.3))
        ..debugSetPuck(const Offset(0.5, 1.1), const Offset(0, 1));
      _run(controller, const Duration(milliseconds: 200));

      expect(controller.puckVelocity.dy, lessThan(0));
      expect(controller.puckVelocity.distance, lessThan(1));
    });

    test('a moving mallet transfers its velocity to the puck', () {
      final controller = _playing()
        ..debugSetMallet(DuelPlayer.bottom, const Offset(0.5, 1.3))
        ..debugSetPuck(const Offset(0.5, 1.1));
      // Moves the mallet up at 1 unit per second
      var target = controller.mallet(DuelPlayer.bottom);
      for (var i = 0; i < 10; i++) {
        target -= const Offset(0, 0.016);
        controller
          ..moveMallet(DuelPlayer.bottom, target)
          ..tick(_frame);
      }

      // (1 + restitution) × mallet speed, minus a little friction
      expect(controller.puckVelocity.dy, closeTo(-1.8, 0.05));
      expect(controller.puckVelocity.dx, closeTo(0, 1e-9));
    });

    test('a fast hit is limited to the max puck speed', () {
      final controller = _playing()
        ..debugSetMallet(DuelPlayer.bottom, const Offset(0.5, 1.4))
        ..debugSetPuck(const Offset(0.5, 1.0))
        ..moveMallet(DuelPlayer.bottom, const Offset(0.5, 0.8));
      _run(controller, const Duration(milliseconds: 100));

      expect(controller.puckVelocity.distance, lessThanOrEqualTo(PuckGameController.maxPuckSpeed));
      expect(controller.puckVelocity.distance, greaterThan(PuckGameController.maxPuckSpeed * 0.95));
      expect(controller.puckVelocity.dy, lessThan(0));
    });

    test('a fast puck never tunnels through a mallet, also with long frames', () {
      for (final frame in const [Duration(milliseconds: 16), Duration(milliseconds: 50)]) {
        final controller = _playing()
          ..debugSetMallet(DuelPlayer.bottom, const Offset(0.5, 1.3))
          ..debugSetPuck(const Offset(0.5, 0.9), const Offset(0, PuckGameController.maxPuckSpeed));
        var minDistance = double.infinity;
        // Long enough to hit the mallet, too short to come back from the other side
        for (var elapsed = Duration.zero; elapsed < const Duration(milliseconds: 200); elapsed += frame) {
          controller.tick(frame);
          final distance = (controller.puck - controller.mallet(DuelPlayer.bottom)).distance;
          if (distance < minDistance) minDistance = distance;
        }

        expect(controller.puck.dy, lessThan(controller.mallet(DuelPlayer.bottom).dy));
        expect(controller.puckVelocity.dy, lessThan(0));
        expect(minDistance, greaterThanOrEqualTo(PuckGameController.puckRadius + PuckGameController.malletRadius - 1e-9));
      }
    });

    test('a mallet swung at full speed never passes through the puck', () {
      final controller = _playing()
        ..debugSetMallet(DuelPlayer.top, const Offset(0.5, 0.1))
        ..debugSetPuck(const Offset(0.5, 0.5), const Offset(0, -PuckGameController.maxPuckSpeed))
        ..moveMallet(DuelPlayer.top, const Offset(0.5, 0.7));
      for (var i = 0; i < 3; i++) {
        controller.tick(const Duration(milliseconds: 50));
      }

      expect(controller.puck.dy, greaterThan(controller.mallet(DuelPlayer.top).dy));
      expect(controller.puckVelocity.dy, greaterThan(0));
    });

    test('a goal ends the round and places the puck towards the player who conceded', () {
      final controller = _playing();
      _score(controller, DuelPlayer.top);

      expect(controller.phase, equals(DuelPhase.roundOver));
      expect(controller.roundWinner, equals(DuelPlayer.bottom));
      expect(controller.goals(DuelPlayer.bottom), equals(1));

      controller.tick(DuelGameController.roundOverDuration);
      expect(controller.phase, equals(DuelPhase.countdown));
      expect(controller.puck, equals(const Offset(_w / 2, _h / 2 - PuckGameController.serveOffset)));
      expect(controller.puckVelocity, equals(Offset.zero));
      expect(controller.mallet(DuelPlayer.top), equals(PuckGameController.malletStart(DuelPlayer.top)));

      controller.tick(DuelGameController.countdownDuration);
      _score(controller, DuelPlayer.bottom);
      expect(controller.goals(DuelPlayer.top), equals(1));
      controller.tick(DuelGameController.roundOverDuration);
      expect(controller.puck, equals(const Offset(_w / 2, _h / 2 + PuckGameController.serveOffset)));
    });

    test('the puck in the goal mouth only counts once it crosses the goal line', () {
      final controller = _playing()..debugSetPuck(const Offset(_w / 2, PuckGameController.puckRadius), const Offset(0, -0.5));
      controller.tick(_frame);
      expect(controller.phase, equals(DuelPhase.playing));

      _run(controller, const Duration(milliseconds: 200));
      expect(controller.phase, equals(DuelPhase.roundOver));
    });

    test('the first player to 5 goals wins the match', () {
      final results = <GameResult>[];
      final controller = _playing(results: results);
      for (var i = 0; i < 4; i++) {
        _score(controller, DuelPlayer.bottom);
        _nextRound(controller);
      }
      _score(controller, DuelPlayer.top);
      _nextRound(controller);
      expect(results, isEmpty);
      _score(controller, DuelPlayer.bottom);

      expect(controller.phase, equals(DuelPhase.finished));
      expect(controller.matchWinner, equals(DuelPlayer.top));
      expect(controller.isRunning, isFalse);
      expect(controller.status, equals(GameStatus.finished));

      final result = results.single;
      expect(result.gameId, equals('puck'));
      expect(result.outcome, equals(GameOutcome.won));
      expect(result.score, isNull);
      expect(result.data['winner'], equals('top'));
      expect(result.data['rounds'], equals({'bottom': 1, 'top': 5}));

      // Nothing moves after the match
      final puck = controller.puck;
      controller.tick(_frame);
      expect(controller.puck, equals(puck));
    });

    test('rematch starts a new match from the middle', () {
      final controller = _playing();
      _score(controller, DuelPlayer.bottom);
      controller.rematch();

      expect(controller.phase, equals(DuelPhase.ready));
      expect(controller.status, equals(GameStatus.ready));
      expect(controller.goals(DuelPlayer.top), equals(0));
      expect(controller.puck, equals(const Offset(_w / 2, _h / 2)));

      controller
        ..setReady(DuelPlayer.bottom)
        ..setReady(DuelPlayer.top)
        ..tick(DuelGameController.countdownDuration);
      expect(controller.phase, equals(DuelPhase.playing));
      expect(controller.puck, equals(const Offset(_w / 2, _h / 2)));
    });

    test('goalsToWin changes the length of the match', () {
      final controller = PuckGameController(goalsToWin: 1)
        ..setReady(DuelPlayer.bottom)
        ..setReady(DuelPlayer.top)
        ..tick(DuelGameController.countdownDuration);
      _score(controller, DuelPlayer.top);

      expect(controller.phase, equals(DuelPhase.finished));
      expect(controller.matchWinner, equals(DuelPlayer.bottom));
    });
  });
}
