import 'package:flutter_mini_games/flutter_mini_games.dart';
import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/duel/duel_game_controller.dart';
import 'package:flutter_mini_games/src/game/tug/game/logic/tug_game_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TugGameController playing({List<GameResult>? results}) {
    final controller = TugGameController();
    if (results != null) controller.resultListener = results.add;
    controller
      ..setReady(DuelPlayer.bottom)
      ..setReady(DuelPlayer.top)
      ..tick(DuelGameController.countdownDuration);
    expect(controller.phase, equals(DuelPhase.playing));
    return controller;
  }

  void pullTimes(TugGameController controller, DuelPlayer player, int times) {
    for (var i = 0; i < times; i++) {
      controller.pull(player);
    }
  }

  void nextRound(TugGameController controller) => controller
    ..tick(DuelGameController.roundOverDuration)
    ..tick(DuelGameController.countdownDuration);

  test('is a real-time two-player game with best of 3', () {
    final controller = TugGameController();
    expect(controller.gameId, equals('tug'));
    expect(controller.roundsToWin, equals(2));
    expect(controller.isRunning, isFalse);
    expect(const TugGameBuilder().isMultiPlayer, isTrue);
    expect(const TugGameBuilder().id, equals('tug'));
  });

  test('taps only count while a round is playing', () {
    final controller = TugGameController()..pull(DuelPlayer.bottom);
    expect(controller.position, equals(0));
    expect(controller.moves, equals(0));

    controller
      ..setReady(DuelPlayer.bottom)
      ..setReady(DuelPlayer.top)
      ..pull(DuelPlayer.top);
    expect(controller.phase, equals(DuelPhase.countdown));
    expect(controller.isRunning, isTrue);
    expect(controller.position, equals(0));
    expect(controller.moves, equals(0));

    controller
      ..tick(DuelGameController.countdownDuration)
      ..pull(DuelPlayer.top);
    expect(controller.position, equals(-1));
    expect(controller.moves, equals(1));
  });

  test('every tap pulls the marker one step toward the tapping player', () {
    final controller = playing();
    pullTimes(controller, DuelPlayer.bottom, 3);
    expect(controller.position, equals(3));
    expect(controller.progress, closeTo(3 / TugGameController.stepsToWin, 1e-9));
    expect(controller.leader, equals(DuelPlayer.bottom));

    pullTimes(controller, DuelPlayer.top, 5);
    expect(controller.position, equals(-2));
    expect(controller.leader, equals(DuelPlayer.top));
    expect(controller.pulls(DuelPlayer.bottom), equals(3));
    expect(controller.pulls(DuelPlayer.top), equals(5));
    expect(controller.moves, equals(8));

    // Ticks don't move the rope
    controller.tick(const Duration(seconds: 1));
    expect(controller.position, equals(-2));
  });

  test('pulling the marker to your edge wins the round', () {
    final controller = playing();
    pullTimes(controller, DuelPlayer.top, TugGameController.stepsToWin - 1);
    expect(controller.phase, equals(DuelPhase.playing));

    controller.pull(DuelPlayer.top);
    expect(controller.phase, equals(DuelPhase.roundOver));
    expect(controller.roundWinner, equals(DuelPlayer.top));
    expect(controller.roundWins(DuelPlayer.top), equals(1));
    expect(controller.progress, equals(-1));

    // Taps during the pause are ignored
    controller.pull(DuelPlayer.bottom);
    expect(controller.position, equals(-TugGameController.stepsToWin));

    // The next round starts with the marker in the middle
    controller.tick(DuelGameController.roundOverDuration);
    expect(controller.phase, equals(DuelPhase.countdown));
    expect(controller.position, equals(0));
    expect(controller.pulls(DuelPlayer.top), equals(0));
  });

  test('best of 3: the first to win 2 rounds wins the match', () {
    final results = <GameResult>[];
    final controller = playing(results: results);
    pullTimes(controller, DuelPlayer.bottom, TugGameController.stepsToWin);
    nextRound(controller);
    pullTimes(controller, DuelPlayer.top, TugGameController.stepsToWin);
    nextRound(controller);
    expect(results, isEmpty);

    pullTimes(controller, DuelPlayer.top, 4);
    pullTimes(controller, DuelPlayer.bottom, TugGameController.stepsToWin + 4);

    expect(controller.phase, equals(DuelPhase.finished));
    expect(controller.matchWinner, equals(DuelPlayer.bottom));
    expect(controller.status, equals(GameStatus.finished));
    expect(controller.isRunning, isFalse);
    final result = results.single;
    expect(result.gameId, equals('tug'));
    expect(result.outcome, equals(GameOutcome.won));
    expect(result.score, isNull);
    expect(result.data['winner'], equals('bottom'));
    expect(result.data['rounds'], equals({'bottom': 2, 'top': 1}));
    expect(result.moves, equals(TugGameController.stepsToWin * 3 + 8));

    // No more moves after the match
    controller.pull(DuelPlayer.top);
    expect(controller.moves, equals(result.moves));
  });

  test('rematch starts a new match with the marker in the middle', () {
    final controller = playing();
    pullTimes(controller, DuelPlayer.top, TugGameController.stepsToWin);
    nextRound(controller);
    pullTimes(controller, DuelPlayer.top, TugGameController.stepsToWin);
    expect(controller.phase, equals(DuelPhase.finished));

    controller.rematch();
    expect(controller.phase, equals(DuelPhase.ready));
    expect(controller.status, equals(GameStatus.ready));
    expect(controller.position, equals(0));
    expect(controller.moves, equals(0));
    expect(controller.roundWins(DuelPlayer.top), equals(0));

    controller
      ..setReady(DuelPlayer.top)
      ..setReady(DuelPlayer.bottom)
      ..tick(DuelGameController.countdownDuration)
      ..pull(DuelPlayer.bottom);
    expect(controller.position, equals(1));
  });
}
