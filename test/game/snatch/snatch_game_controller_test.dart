import 'dart:math';

import 'package:flutter_mini_games/flutter_mini_games.dart';
import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/duel/duel_game_controller.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/game/snatch/game/logic/snatch_game_controller.dart';
import 'package:flutter_mini_games/src/game/snatch/widget/snatch_symbols.dart';
import 'package:flutter_test/flutter_test.dart';

const bottom = DuelPlayer.bottom;
const top = DuelPlayer.top;

SnatchGameController playing({int seed = 42, List<GameResult>? results}) {
  final controller = SnatchGameController(random: Random(seed));
  if (results != null) controller.resultListener = results.add;
  return controller
    ..setReady(bottom)
    ..setReady(top)
    ..tick(DuelGameController.countdownDuration);
}

extension on SnatchGameController {
  int matchingTile(DuelPlayer player) => layoutOf(player).indexOf(target);

  int wrongTile(DuelPlayer player) => matchingTile(player) == 0 ? 1 : 0;

  /// Taps the matching tile and waits for the next target
  void score(DuelPlayer player) {
    tap(player, matchingTile(player));
    tick(SnatchGameController.revealDuration);
  }
}

void main() {
  test('has an icon for every symbol', () {
    expect(SnatchSymbols.icons.length, greaterThanOrEqualTo(SnatchGameController.symbolCount));
    expect(SnatchSymbols.icons.toSet().length, equals(SnatchSymbols.icons.length));
  });

  test('both halves show the same symbols in a different order', () {
    final controller = SnatchGameController(random: Random(1));
    for (var i = 0; i < 50; i++) {
      final bottomLayout = controller.layoutOf(bottom);
      final topLayout = controller.layoutOf(top);
      expect(bottomLayout.toSet(), equals({for (var s = 0; s < SnatchGameController.symbolCount; s++) s}));
      expect(topLayout.toSet(), equals(bottomLayout.toSet()));
      expect(topLayout, isNot(equals(bottomLayout)));
      controller.rematch();
    }
  });

  test('a seeded Random gives the same match', () {
    final a = playing(seed: 7);
    final b = playing(seed: 7);
    expect(a.layoutOf(bottom), equals(b.layoutOf(bottom)));
    expect(a.layoutOf(top), equals(b.layoutOf(top)));
    expect(a.target, equals(b.target));
  });

  test('hides the target and ignores taps until the round plays', () {
    final controller = SnatchGameController(random: Random(42));
    expect(controller.isTargetVisible, isFalse);
    controller.tap(bottom, controller.matchingTile(bottom));
    expect(controller.points(bottom), equals(0));

    controller
      ..setReady(bottom)
      ..setReady(top);
    expect(controller.phase, equals(DuelPhase.countdown));
    expect(controller.isRunning, isTrue);
    controller.tap(bottom, controller.matchingTile(bottom));
    expect(controller.points(bottom), equals(0));

    controller.tick(DuelGameController.countdownDuration);
    expect(controller.phase, equals(DuelPhase.playing));
    expect(controller.isTargetVisible, isTrue);
  });

  test('a correct tap scores, then a new target and new orders follow', () {
    final controller = playing();
    final target = controller.target;
    final layout = controller.layoutOf(bottom);
    final tile = controller.matchingTile(bottom);

    controller.tap(bottom, tile);
    expect(controller.points(bottom), equals(1));
    expect(controller.roundWins(bottom), equals(1));
    expect(controller.moves, equals(1));
    expect(controller.isRevealing, isTrue);
    expect(controller.lastScorer, equals(bottom));
    expect(controller.tileState(bottom, tile), equals(SnatchTileState.hit));
    expect(controller.tileState(top, controller.matchingTile(top)), equals(SnatchTileState.missed));

    controller.tick(SnatchGameController.revealDuration);
    expect(controller.isRevealing, isFalse);
    expect(controller.lastScorer, isNull);
    expect(controller.target, isNot(equals(target)));
    expect(controller.layoutOf(bottom), isNot(equals(layout)));
    expect(controller.phase, equals(DuelPhase.playing));
  });

  test('a wrong tap costs a point, never below 0, and locks the half for a moment', () {
    final controller = playing();
    final wrong = controller.wrongTile(top);

    controller.tap(top, wrong);
    expect(controller.points(top), equals(0));
    expect(controller.penalties(top), equals(1));
    expect(controller.isLocked(top), isTrue);
    expect(controller.tileState(top, wrong), equals(SnatchTileState.wrong));

    // Locked: even the right tile does nothing
    controller.tap(top, controller.matchingTile(top));
    expect(controller.points(top), equals(0));

    // The other player is not locked
    controller.tap(bottom, controller.matchingTile(bottom));
    expect(controller.points(bottom), equals(1));
    controller.tick(SnatchGameController.revealDuration);

    controller.score(top);
    controller.score(top);
    expect(controller.points(top), equals(2));
    controller.tap(top, controller.wrongTile(top));
    expect(controller.points(top), equals(1));
    controller.tick(SnatchGameController.wrongLockDuration);
    expect(controller.isLocked(top), isFalse);
    expect(controller.tileState(top, controller.wrongTile(top)), equals(SnatchTileState.idle));
  });

  test('when both players tap the match, the first tap wins', () {
    final controller = playing();
    controller
      ..tap(top, controller.matchingTile(top))
      ..tap(bottom, controller.matchingTile(bottom));

    expect(controller.points(top), equals(1));
    expect(controller.points(bottom), equals(0));
    expect(controller.penalties(bottom), equals(0));
  });

  test('the first player to 7 points wins and the result is reported', () {
    final results = <GameResult>[];
    final controller = playing(results: results);
    controller
      ..score(bottom)
      ..score(top)
      ..tap(top, controller.wrongTile(top))
      ..tick(SnatchGameController.wrongLockDuration);
    for (var i = 0; i < 6; i++) {
      controller.score(top);
    }
    expect(controller.points(top), equals(6));
    expect(controller.phase, equals(DuelPhase.playing));

    controller.tap(top, controller.matchingTile(top));

    expect(controller.phase, equals(DuelPhase.finished));
    expect(controller.matchWinner, equals(top));
    expect(controller.status, equals(GameStatus.finished));
    expect(controller.isRunning, isFalse);
    final result = results.single;
    expect(result.gameId, equals('snatch'));
    expect(result.outcome, equals(GameOutcome.won));
    expect(result.score, isNull);
    expect(result.data['winner'], equals('top'));
    expect(result.data['points'], equals({'bottom': 1, 'top': 7}));
    expect(result.data['penalties'], equals({'bottom': 0, 'top': 1}));
    expect(result.moves, equals(10));

    // No taps after the match
    controller.tap(bottom, controller.matchingTile(bottom));
    expect(controller.points(bottom), equals(1));
  });

  test('rematch resets the points and starts with the ready phase', () {
    final controller = playing()
      ..score(bottom)
      ..score(top)
      ..rematch();

    expect(controller.phase, equals(DuelPhase.ready));
    expect(controller.points(bottom), equals(0));
    expect(controller.points(top), equals(0));
    expect(controller.status, equals(GameStatus.ready));
    expect(controller.moves, equals(0));

    controller
      ..setReady(bottom)
      ..setReady(top)
      ..tick(DuelGameController.countdownDuration)
      ..score(bottom);
    expect(controller.points(bottom), equals(1));
  });
}
