import 'dart:math';

import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/controller/realtime_game_controller.dart';
import 'package:flutter_mini_games/src/core/duel/duel_game_controller.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';

/// What a tile shows besides its symbol
enum SnatchTileState {
  idle,

  /// The matching tile that scored the point (short pause after a point)
  hit,

  /// The matching tile in the half of the player that was too slow
  missed,

  /// A wrong tap: costs a point and locks the half for a moment
  wrong,
}

/// Snatch: a target symbol is shown in the middle, the first player to tap the matching tile in
/// their half scores a point. A wrong tap costs a point (never below 0). First to [pointsToWin].
///
/// Both halves show the same [symbolCount] symbols, each in its own shuffled order. After every
/// point there is a short pause ([revealDuration]) that shows who scored, then a new target and
/// new orders follow.
///
/// The whole match is one duel round ([roundsToWin] = 1): the duel core runs ready → countdown →
/// playing → winner and rematch, the points are kept here. [duelScore] returns the points so the
/// shared `DuelPhaseOverlay` shows them as the score, the result data holds the points and penalties.
class SnatchGameController extends GameController with RealtimeGameController, DuelGameController {
  static const id = 'snatch';

  /// Symbols per half
  static const symbolCount = 6;
  static const pointsToWin = 7;

  /// Pause after a point, showing the matching tile, before the next target
  static const revealDuration = Duration(milliseconds: 600);

  /// How long a half is locked after a wrong tap, so tapping every tile does not pay off
  static const wrongLockDuration = Duration(milliseconds: 600);

  final Random _random;

  final Map<DuelPlayer, List<int>> _layouts = {};
  final Map<DuelPlayer, int> _points = {DuelPlayer.bottom: 0, DuelPlayer.top: 0};
  final Map<DuelPlayer, int> _penalties = {DuelPlayer.bottom: 0, DuelPlayer.top: 0};
  final Map<DuelPlayer, int?> _wrongTile = {DuelPlayer.bottom: null, DuelPlayer.top: null};
  final Map<DuelPlayer, Duration> _lockRemaining = {DuelPlayer.bottom: Duration.zero, DuelPlayer.top: Duration.zero};
  int _target = 0;
  DuelPlayer? _lastScorer;
  Duration _revealRemaining = Duration.zero;

  SnatchGameController({Random? random}) : _random = random ?? Random(), super(gameId: id) {
    _deal(previousTarget: null);
  }

  @override
  int get roundsToWin => 1;

  @override
  bool get isRunning => duelIsRunning;

  /// The points of [player]; the shared overlay shows them as the score
  @override
  int duelScore(DuelPlayer player) => points(player);

  @override
  Map<String, Object?> get duelResultData => {
    'points': {for (final player in DuelPlayer.values) player.name: _points[player]},
    'penalties': {for (final player in DuelPlayer.values) player.name: _penalties[player]},
  };

  int points(DuelPlayer player) => _points[player]!;

  /// Wrong taps of [player] in this match
  int penalties(DuelPlayer player) => _penalties[player]!;

  /// The symbols of the half of [player], in tile order
  List<int> layoutOf(DuelPlayer player) => List.unmodifiable(_layouts[player]!);

  /// The symbol to find
  int get target => _target;

  /// Whether the target is visible: only while playing, so nobody gets a head start
  bool get isTargetVisible => phase == DuelPhase.playing || phase == DuelPhase.finished;

  /// The player who scored the last point, while its pause is shown (and after the winning point)
  DuelPlayer? get lastScorer => isRevealing || phase == DuelPhase.finished ? _lastScorer : null;

  /// The short pause after a point
  bool get isRevealing => _revealRemaining > Duration.zero;

  /// Whether the half of [player] is locked after a wrong tap
  bool isLocked(DuelPlayer player) => _lockRemaining[player]! > Duration.zero;

  SnatchTileState tileState(DuelPlayer player, int tile) {
    final scorer = lastScorer;
    if (scorer != null && _layouts[player]![tile] == _target) {
      return scorer == player ? SnatchTileState.hit : SnatchTileState.missed;
    }
    if (isLocked(player) && _wrongTile[player] == tile) return SnatchTileState.wrong;
    return SnatchTileState.idle;
  }

  /// [player] taps the tile at [tile] in their half
  void tap(DuelPlayer player, int tile) {
    if (phase != DuelPhase.playing || isRevealing || isLocked(player)) return;
    if (tile < 0 || tile >= symbolCount) return;
    registerMove();
    if (_layouts[player]![tile] == _target) {
      _points[player] = _points[player]! + 1;
      _lastScorer = player;
      if (_points[player]! >= pointsToWin) {
        endRound(player);
        return;
      }
      _revealRemaining = revealDuration;
    } else {
      _points[player] = max(0, _points[player]! - 1);
      _penalties[player] = _penalties[player]! + 1;
      _wrongTile[player] = tile;
      _lockRemaining[player] = wrongLockDuration;
    }
    notifyListeners();
  }

  @override
  void tick(Duration delta) {
    if (!tickDuel(delta)) return;
    var changed = false;
    for (final player in DuelPlayer.values) {
      final remaining = _lockRemaining[player]!;
      if (remaining <= Duration.zero) continue;
      _lockRemaining[player] = remaining - delta;
      if (!isLocked(player)) {
        _wrongTile[player] = null;
        changed = true;
      }
    }
    if (isRevealing) {
      _revealRemaining -= delta;
      if (!isRevealing) {
        _revealRemaining = Duration.zero;
        // A running lock stays, its marker would point at a tile with another symbol now
        _wrongTile.updateAll((player, tile) => null);
        _deal(previousTarget: _target);
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  @override
  void resetRound() {
    _points.updateAll((player, points) => 0);
    _penalties.updateAll((player, penalties) => 0);
    _clearWrongTaps();
    _lastScorer = null;
    _revealRemaining = Duration.zero;
    _deal(previousTarget: _target);
  }

  void _clearWrongTaps() {
    _wrongTile.updateAll((player, tile) => null);
    _lockRemaining.updateAll((player, remaining) => Duration.zero);
  }

  /// New target (never the same twice in a row) and a new order in each half,
  /// the two halves never in the same order
  void _deal({required int? previousTarget}) {
    var target = _random.nextInt(symbolCount);
    if (target == previousTarget) target = (target + 1 + _random.nextInt(symbolCount - 1)) % symbolCount;
    _target = target;

    final bottom = List.generate(symbolCount, (index) => index)..shuffle(_random);
    final top = List.generate(symbolCount, (index) => index);
    do {
      top.shuffle(_random);
    } while (_sameOrder(top, bottom));
    _layouts[DuelPlayer.bottom] = bottom;
    _layouts[DuelPlayer.top] = top;
  }

  static bool _sameOrder(List<int> a, List<int> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
