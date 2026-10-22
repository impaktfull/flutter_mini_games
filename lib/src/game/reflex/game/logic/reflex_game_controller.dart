import 'dart:math';

import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/controller/realtime_game_controller.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';
import 'package:flutter_mini_games/src/game/reflex/game/model/reflex_phase.dart';

/// Reflex: tap as soon as the board changes color, [tries] times.
///
/// Time is game time from [tick] (driven by `GameLoop`), so the measurement is frame-rate
/// independent and testable: the reaction time is the game time between the change and the tap.
class ReflexGameController extends GameController with RealtimeGameController {
  static const id = 'reflex';

  /// Number of measured tries in one game
  static const tries = 5;

  /// Shortest and longest random wait before the board changes color
  static const minDelay = Duration(milliseconds: 1500);
  static const maxDelay = Duration(milliseconds: 5000);

  /// The score is [maxScore] minus the average reaction time in ms, never below 0
  static const maxScore = 1000;

  final Random _random;

  ReflexPhase _phase = ReflexPhase.ready;
  final List<int> _times = [];
  Duration _delay = Duration.zero;
  Duration _waited = Duration.zero;
  Duration _reaction = Duration.zero;
  int _earlyTaps = 0;

  ReflexGameController({Random? random}) : _random = random ?? Random(), super(gameId: id);

  ReflexPhase get phase => _phase;

  /// Measured reaction times in ms, in order
  List<int> get times => List.unmodifiable(_times);

  /// The try that is being played or was just measured, 1-based
  int get currentTry => min(tries, _phase == ReflexPhase.measured || _phase == ReflexPhase.finished ? _times.length : _times.length + 1);

  /// Last measured reaction time in ms
  int? get lastTime => _times.isEmpty ? null : _times.last;

  /// Average of the measured times in ms, null before the first one
  int? get averageMs => _times.isEmpty ? null : (_times.reduce((a, b) => a + b) / _times.length).round();

  /// Best (lowest) measured time in ms
  int? get bestMs => _times.isEmpty ? null : _times.reduce(min);

  /// Random wait of the current try
  Duration get delay => _delay;

  /// Number of taps before the board changed color
  int get earlyTaps => _earlyTaps;

  /// Score of the game, available when it is finished
  int get score => calculateScore(averageMs ?? maxScore);

  bool get isReady => _phase == ReflexPhase.ready;
  bool get isGameOver => _phase == ReflexPhase.finished;

  @override
  bool get isRunning => _phase == ReflexPhase.waiting || _phase == ReflexPhase.go;

  /// `max(0, 1000 - average ms)`
  static int calculateScore(int averageMs) => max(0, maxScore - averageMs);

  /// Tap anywhere on the board, does what the current phase needs
  void onTap() {
    switch (_phase) {
      case ReflexPhase.ready:
        startSession();
        _startTry();
      case ReflexPhase.tooEarly:
      case ReflexPhase.measured:
        _startTry();
      case ReflexPhase.waiting:
        registerMove();
        _earlyTaps++;
        _phase = ReflexPhase.tooEarly;
      case ReflexPhase.go:
        registerMove();
        _measure();
      case ReflexPhase.finished:
        return;
    }
    notifyListeners();
  }

  void _startTry() {
    final range = maxDelay.inMicroseconds - minDelay.inMicroseconds;
    _delay = Duration(microseconds: minDelay.inMicroseconds + (_random.nextDouble() * range).round());
    _waited = Duration.zero;
    _reaction = Duration.zero;
    _phase = ReflexPhase.waiting;
  }

  void _measure() {
    _times.add(_reaction.inMicroseconds ~/ Duration.microsecondsPerMillisecond);
    if (_times.length < tries) {
      _phase = ReflexPhase.measured;
      return;
    }
    _phase = ReflexPhase.finished;
    final average = averageMs!;
    finish(
      GameOutcome.won,
      score: calculateScore(average),
      data: {
        'averageMs': average,
        'bestMs': bestMs,
        'timesMs': List<int>.of(_times),
        'earlyTaps': _earlyTaps,
      },
    );
  }

  @override
  void tick(Duration delta) {
    switch (_phase) {
      case ReflexPhase.waiting:
        _waited += delta;
        if (_waited < _delay) return;
        // The change becomes visible with this frame: the reaction time starts now
        _phase = ReflexPhase.go;
        _reaction = Duration.zero;
        notifyListeners();
      case ReflexPhase.go:
        // No rebuild needed, the board does not change while the reaction time runs
        _reaction += delta;
      case ReflexPhase.ready:
      case ReflexPhase.tooEarly:
      case ReflexPhase.measured:
      case ReflexPhase.finished:
        return;
    }
  }

  /// Starts a new game
  void resetGame() {
    restartSession();
    _phase = ReflexPhase.ready;
    _times.clear();
    _delay = Duration.zero;
    _waited = Duration.zero;
    _reaction = Duration.zero;
    _earlyTaps = 0;
    notifyListeners();
  }
}
