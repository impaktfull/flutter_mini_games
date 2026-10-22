import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestGameController extends GameController {
  _TestGameController() : super(gameId: 'test');

  void move() => registerMove();

  void win() => finish(GameOutcome.won, score: 10);

  void restart() => restartSession();
}

void main() {
  group('GameController', () {
    test('starts playing on the first move', () {
      final controller = _TestGameController();
      expect(controller.status, equals(GameStatus.ready));

      controller.move();

      expect(controller.status, equals(GameStatus.playing));
      expect(controller.moves, equals(1));
    });

    test('reports the result when finished', () {
      final results = <GameResult>[];
      final controller = _TestGameController()..resultListener = results.add;
      controller
        ..move()
        ..move()
        ..win();

      expect(controller.isFinished, isTrue);
      expect(results.single.gameId, equals('test'));
      expect(results.single.outcome, equals(GameOutcome.won));
      expect(results.single.score, equals(10));
      expect(results.single.moves, equals(2));
    });

    test('ignores moves after finishing', () {
      final controller = _TestGameController()
        ..move()
        ..win()
        ..move();

      expect(controller.moves, equals(1));
    });

    test('reports an abandoned game when disposed while playing', () {
      final results = <GameResult>[];
      _TestGameController()
        ..resultListener = results.add
        ..move()
        ..dispose();

      expect(results.single.outcome, equals(GameOutcome.abandoned));
    });

    test('reports nothing when disposed before the first move or after finishing', () {
      final results = <GameResult>[];
      _TestGameController()
        ..resultListener = results.add
        ..dispose();
      _TestGameController()
        ..resultListener = results.add
        ..move()
        ..win()
        ..dispose();

      expect(results.map((result) => result.outcome), equals([GameOutcome.won]));
    });

    test('restarting the session resets status, moves and result', () {
      final controller = _TestGameController()
        ..move()
        ..win()
        ..restart();

      expect(controller.status, equals(GameStatus.ready));
      expect(controller.moves, equals(0));
      expect(controller.result, isNull);
      expect(controller.elapsed, equals(Duration.zero));
    });
  });
}
