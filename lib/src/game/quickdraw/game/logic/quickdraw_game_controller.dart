import 'dart:math';

import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/controller/realtime_game_controller.dart';
import 'package:flutter_mini_games/src/core/duel/duel_pair.dart';
import 'package:flutter_mini_games/src/core/duel/duel_game_controller.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/game/quickdraw/game/model/quickdraw_signal.dart';

/// Quickdraw: a reaction duel for two players on one device, best of 5.
///
/// After the duel countdown every round waits a random delay, then shows "GO". The first
/// player to tap their half after GO wins the round; a tap before GO loses the round.
///
/// Time is game time from [tick] (driven by `GameLoop`): the reaction time is the game time
/// between the frame that shows GO and the tap.
class QuickdrawGameController extends GameController with RealtimeGameController, DuelGameController {
  static const id = 'quickdraw';

  /// Best of 5
  static const winsNeeded = 3;

  /// Shortest and longest random wait before GO
  static const minDelay = Duration(milliseconds: 1500);
  static const maxDelay = Duration(milliseconds: 5000);

  final Random _random;

  QuickdrawSignal _signal = QuickdrawSignal.waiting;
  Duration _delay = Duration.zero;
  Duration _waited = Duration.zero;
  Duration _reaction = Duration.zero;
  DuelPlayer? _earlyPlayer;
  int? _roundReactionMs;
  final DuelPair<int?> _bestReactionMs = DuelPair.generate((player) => null);

  QuickdrawGameController({Random? random}) : _random = random ?? Random(), super(gameId: id);

  @override
  int get roundsToWin => winsNeeded;

  /// Waiting or GO, only meaningful while a round is playing
  QuickdrawSignal get signal => _signal;

  bool get isGo => phase == DuelPhase.playing && _signal == QuickdrawSignal.go;

  /// Random wait before GO in the current round
  Duration get delay => _delay;

  /// The player who tapped before GO in the last round, null when the round was won by a reaction
  DuelPlayer? get earlyPlayer => _earlyPlayer;

  /// Reaction time of the round winner in ms, null when the round was lost by tapping too early
  int? get roundReactionMs => _roundReactionMs;

  /// Fastest reaction time in ms of [player] in this match, null before their first won reaction
  int? bestReactionMs(DuelPlayer player) => _bestReactionMs[player];

  @override
  bool get isRunning => duelIsRunning;

  @override
  void resetRound() {
    _signal = QuickdrawSignal.waiting;
    _delay = Duration.zero;
    _waited = Duration.zero;
    _reaction = Duration.zero;
    _earlyPlayer = null;
    _roundReactionMs = null;
  }

  @override
  void onRoundStarted() {
    final range = maxDelay.inMicroseconds - minDelay.inMicroseconds;
    _delay = Duration(microseconds: minDelay.inMicroseconds + (_random.nextDouble() * range).round());
    _waited = Duration.zero;
    _signal = QuickdrawSignal.waiting;
  }

  @override
  void tick(Duration delta) {
    if (!tickDuel(delta)) return;
    switch (_signal) {
      case QuickdrawSignal.waiting:
        _waited += delta;
        if (_waited < _delay) return;
        // GO becomes visible with this frame: the reaction time starts now
        _signal = QuickdrawSignal.go;
        _reaction = Duration.zero;
        notifyListeners();
      case QuickdrawSignal.go:
        // No rebuild needed, nothing changes on screen while the reaction time runs
        _reaction += delta;
    }
  }

  /// A tap on the half of [player]. Only counts while a round is playing: the first tap ends the round.
  void onTap(DuelPlayer player) {
    if (phase != DuelPhase.playing) return;
    registerMove();
    switch (_signal) {
      case QuickdrawSignal.waiting:
        _earlyPlayer = player;
        endRound(player.opponent);
      case QuickdrawSignal.go:
        final ms = _reaction.inMicroseconds ~/ Duration.microsecondsPerMillisecond;
        _roundReactionMs = ms;
        final best = _bestReactionMs[player];
        if (best == null || ms < best) _bestReactionMs[player] = ms;
        endRound(player);
    }
  }

  /// Each player's best reaction time
  @override
  Map<String, Object?> get duelResultData => {
    'bestReactionMs': _bestReactionMs.toJson(),
  };

  @override
  void rematch() {
    _bestReactionMs.updateAll((player, ms) => null);
    super.rematch();
  }
}
