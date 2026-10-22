import 'dart:math';

import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/controller/realtime_game_controller.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';
import 'package:flutter_mini_games/src/game/whack/game/model/whack_target.dart';

/// Whack: targets pop up out of a 3x3 grid of holes, tap them before they hide.
///
/// A round lasts [roundDuration]. Targets stay up for a shorter time and pop up more often as the
/// round goes on. Decoys cost a point when tapped. Score = hits - decoys.
///
/// All timing is event based on the round time (spawn times, hide times), so the result does not
/// depend on how [tick] is split into frames.
class WhackGameController extends GameController with RealtimeGameController {
  static const id = 'whack';

  static const columns = 3;
  static const rows = 3;
  static const holeCount = columns * rows;

  /// Length of a round in seconds
  static const roundDuration = 30.0;

  /// How long a target can be hit at the start and at the end of the round, in seconds
  static const startVisibleDuration = 1.5;
  static const endVisibleDuration = 0.65;

  /// Time between two targets at the start and at the end of the round, in seconds
  static const startSpawnInterval = 0.9;
  static const endSpawnInterval = 0.45;

  /// Time before the first target pops up, in seconds
  static const firstSpawnDelay = 0.4;

  /// Chance that a new target is a decoy
  static const decoyChance = 0.25;

  /// Time a target takes to pop up or to hide, in seconds
  static const popDuration = 0.12;

  /// Time a tapped target stays visible (dropping back) before its hole is free again, in seconds
  static const hitLinger = 0.3;

  final Random _random;

  final List<WhackTarget> _targets = [];
  int _timeMicros = 0;
  double _nextSpawnAt = firstSpawnDelay;
  int _hits = 0;
  int _decoysHit = 0;
  int _misses = 0;
  int _escaped = 0;

  WhackGameController({Random? random}) : _random = random ?? Random(), super(gameId: id);

  /// Targets that are visible (popping up, up, hiding or just hit)
  List<WhackTarget> get targets => List.unmodifiable(_targets);

  /// Seconds since the start of the round
  double get time => _timeMicros / Duration.microsecondsPerSecond;

  /// Seconds left in the round
  double get remaining => max(0, roundDuration - time);

  /// Round time at which the next target pops up
  double get nextSpawnAt => _nextSpawnAt;

  /// Critters tapped
  int get hits => _hits;

  /// Decoys tapped
  int get decoysHit => _decoysHit;

  /// Taps on a hole without a target
  int get misses => _misses;

  /// Critters that hid again without being tapped
  int get escaped => _escaped;

  int get score => _hits - _decoysHit;

  bool get isReady => status == GameStatus.ready;
  bool get isGameOver => isFinished;

  @override
  bool get isRunning => status == GameStatus.playing;

  /// The target in [hole], or null when the hole is empty
  WhackTarget? targetAt(int hole) {
    for (final target in _targets) {
      if (target.hole == hole) return target;
    }
    return null;
  }

  /// How far the target in [hole] is out of its hole: 0 hidden, 1 fully up
  double popOf(WhackTarget target) => target.popAt(time, popDuration: popDuration, hitLinger: hitLinger);

  /// How long a target that pops up at round time [at] can be hit
  static double visibleDurationAt(double at) => _lerp(startVisibleDuration, endVisibleDuration, at / roundDuration);

  /// Time until the next target after one that popped up at round time [at]
  static double spawnIntervalAt(double at) => _lerp(startSpawnInterval, endSpawnInterval, at / roundDuration);

  static double _lerp(double a, double b, double t) => a + (b - a) * t.clamp(0.0, 1.0);

  /// Tap on the board: starts the round
  void start() {
    if (!isReady) return;
    startSession();
    notifyListeners();
  }

  /// Tap on [hole]: hits the target in it, a decoy costs a point
  void whack(int hole) {
    if (!isRunning || hole < 0 || hole >= holeCount) return;
    registerMove();
    final now = time;
    final index = _targets.indexWhere((target) => target.hole == hole && target.isHittableAt(now));
    if (index == -1) {
      _misses++;
    } else {
      final target = _targets[index];
      _targets[index] = target.copyWith(hitAt: now);
      if (target.isDecoy) {
        _decoysHit++;
      } else {
        _hits++;
      }
    }
    notifyListeners();
  }

  @override
  void tick(Duration delta) {
    if (!isRunning) return;
    final endMicros = (roundDuration * Duration.microsecondsPerSecond).round();
    _timeMicros = min(endMicros, _timeMicros + delta.inMicroseconds);
    final now = time;

    // Spawns every target that was due in this frame at its own time
    while (_nextSpawnAt <= now && _nextSpawnAt < roundDuration) {
      final at = _nextSpawnAt;
      _removeGone(at);
      _spawn(at);
      _nextSpawnAt = at + spawnIntervalAt(at);
    }
    _removeGone(now);

    if (_timeMicros >= endMicros) {
      _escaped += _targets.where((target) => !target.isHit && !target.isDecoy).length;
      _targets.clear();
      finish(
        GameOutcome.won,
        score: score,
        data: {'hits': _hits, 'decoys': _decoysHit, 'misses': _misses, 'escaped': _escaped},
      );
    }
    notifyListeners();
  }

  /// Removes the targets that are gone at [at], counting critters that were not tapped
  void _removeGone(double at) {
    _targets.removeWhere((target) {
      final isGone = target.goneAt(hitLinger) <= at;
      if (isGone && !target.isHit && !target.isDecoy) _escaped++;
      return isGone;
    });
  }

  /// Pops up a target in a random empty hole, nothing when every hole is taken
  void _spawn(double at) {
    final taken = {for (final target in _targets) target.hole};
    final free = [
      for (var hole = 0; hole < holeCount; hole++)
        if (!taken.contains(hole)) hole,
    ];
    if (free.isEmpty) return;
    final hole = free[_random.nextInt(free.length)];
    final kind = _random.nextDouble() < decoyChance ? WhackTargetKind.decoy : WhackTargetKind.critter;
    _targets.add(WhackTarget(hole: hole, kind: kind, spawnedAt: at, visibleDuration: visibleDurationAt(at)));
  }

  /// Starts a new round
  void resetGame() {
    restartSession();
    _targets.clear();
    _timeMicros = 0;
    _nextSpawnAt = firstSpawnDelay;
    _hits = 0;
    _decoysHit = 0;
    _misses = 0;
    _escaped = 0;
    notifyListeners();
  }
}
