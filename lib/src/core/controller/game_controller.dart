import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';

enum GameStatus {
  /// Waiting for the first move
  ready,
  playing,
  finished,
}

/// Base class for all game controllers.
///
/// Tracks the shared session state (status, time, moves) and reports a [GameResult]
/// when a game calls [finish]. A session that is left while playing is reported as
/// [GameOutcome.abandoned].
abstract class GameController extends ChangeNotifier {
  final String gameId;
  final Stopwatch _stopwatch = Stopwatch();
  GameStatus _status = GameStatus.ready;
  int _moves = 0;
  GameResult? _result;
  ValueChanged<GameResult>? _resultListener;

  GameController({required this.gameId});

  GameStatus get status => _status;
  bool get isFinished => _status == GameStatus.finished;
  Duration get elapsed => _stopwatch.elapsed;
  int get moves => _moves;

  /// Result of the current session, null until it is finished
  GameResult? get result => _result;

  /// Used by `GameControllerProvider` to report results to the host app
  set resultListener(ValueChanged<GameResult>? listener) => _resultListener = listener;

  /// Counts a move and starts the timer on the first one
  @protected
  void registerMove() {
    if (isFinished) return;
    _moves++;
    if (_status == GameStatus.ready) {
      _status = GameStatus.playing;
      _stopwatch.start();
    }
  }

  /// Ends the session and reports the result
  @protected
  GameResult finish(
    GameOutcome outcome, {
    int? score,
    Map<String, Object?> data = const {},
  }) {
    _stopwatch.stop();
    _status = GameStatus.finished;
    final result = GameResult(
      gameId: gameId,
      outcome: outcome,
      score: score,
      duration: _stopwatch.elapsed,
      moves: _moves,
      finishedAt: DateTime.now(),
      data: data,
    );
    _result = result;
    _resultListener?.call(result);
    return result;
  }

  /// Starts a new session (e.g. on reset or next puzzle)
  @protected
  void restartSession() {
    _stopwatch
      ..stop()
      ..reset();
    _status = GameStatus.ready;
    _moves = 0;
    _result = null;
  }

  @override
  void dispose() {
    if (_status == GameStatus.playing) finish(GameOutcome.abandoned);
    super.dispose();
  }
}
