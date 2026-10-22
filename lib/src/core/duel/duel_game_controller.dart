import 'package:flutter/foundation.dart';
import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';

enum DuelPhase {
  /// Waiting until both players are ready
  ready,

  /// 3-2-1 before a round
  countdown,
  playing,

  /// Short pause showing who won the round
  roundOver,
  finished,
}

/// Shared match flow for two players on one device: ready → countdown → rounds
/// (best of N) → winner, with rematch.
///
/// Real-time duels call [tickDuel] from `tick` and only simulate when it returns true;
/// use [duelIsRunning] for `isRunning`. The game resets its round state in [resetRound]
/// and calls [endRound] with the round winner.
///
/// Optional hooks: [duelCountdownDuration] / [duelRoundOverDuration], [duelScore] (the score the
/// overlay shows, e.g. points instead of rounds) and [duelResultData] (extra result data).
mixin DuelGameController on GameController {
  static const countdownDuration = Duration(seconds: 3);
  static const roundOverDuration = Duration(milliseconds: 1500);

  DuelPhase _phase = DuelPhase.ready;
  final Set<DuelPlayer> _ready = {};
  final Map<DuelPlayer, int> _roundWins = {DuelPlayer.bottom: 0, DuelPlayer.top: 0};
  Duration _phaseRemaining = Duration.zero;
  DuelPlayer? _roundWinner;

  /// Rounds a player needs to win the match, e.g. 2 for best of 3
  int get roundsToWin;

  /// 3-2-1 before every round
  Duration get duelCountdownDuration => countdownDuration;

  /// Pause that shows who won a round
  Duration get duelRoundOverDuration => roundOverDuration;

  /// Score of a player shown by the overlay, rounds won by default
  int duelScore(DuelPlayer player) => roundWins(player);

  /// Extra data added to the result of the match, e.g. goals or reaction times
  Map<String, Object?> get duelResultData => const {};

  DuelPhase get phase => _phase;
  bool isReady(DuelPlayer player) => _ready.contains(player);
  int roundWins(DuelPlayer player) => _roundWins[player]!;

  /// Winner of the last round, null for a drawn round
  DuelPlayer? get roundWinner => _roundWinner;

  /// Winner of the match once [phase] is [DuelPhase.finished]
  DuelPlayer? get matchWinner => _phase == DuelPhase.finished ? _roundWinner : null;

  /// Whole seconds left in the countdown (3, 2, 1)
  int get countdownSeconds => (_phaseRemaining.inMilliseconds / 1000).ceil();

  /// Whether the timers of the match flow need a game loop
  bool get duelIsRunning => _phase == DuelPhase.countdown || _phase == DuelPhase.playing || _phase == DuelPhase.roundOver;

  /// Resets the state of a round, e.g. the rope back to the middle
  @protected
  void resetRound();

  void setReady(DuelPlayer player) {
    if (_phase != DuelPhase.ready || !_ready.add(player)) return;
    if (_ready.length == DuelPlayer.values.length) {
      startSession();
      _startCountdown();
    }
    notifyListeners();
  }

  void _startCountdown() {
    resetRound();
    _phase = DuelPhase.countdown;
    _phaseRemaining = duelCountdownDuration;
  }

  /// Advances the countdown and the pause after a round. Returns whether the game may
  /// simulate this frame: only when the whole frame was part of a playing round, so the
  /// frame that ends the countdown is not simulated as play time.
  @protected
  bool tickDuel(Duration delta) {
    if (_phase == DuelPhase.playing) return true;
    if (_phase != DuelPhase.countdown && _phase != DuelPhase.roundOver) return false;
    final secondsBefore = countdownSeconds;
    _phaseRemaining -= delta;
    if (_phaseRemaining > Duration.zero) {
      if (countdownSeconds != secondsBefore) notifyListeners();
      return false;
    }
    if (_phase == DuelPhase.countdown) {
      _phase = DuelPhase.playing;
      onRoundStarted();
    } else {
      _startCountdown();
    }
    notifyListeners();
    return false;
  }

  /// Called when a round starts playing, after the countdown
  @protected
  void onRoundStarted() {}

  /// Ends the round; a null [winner] is a drawn round
  @protected
  void endRound(DuelPlayer? winner) {
    if (_phase != DuelPhase.playing) return;
    _roundWinner = winner;
    if (winner != null) _roundWins[winner] = _roundWins[winner]! + 1;
    if (winner != null && _roundWins[winner]! >= roundsToWin) {
      _phase = DuelPhase.finished;
      finish(
        GameOutcome.won,
        data: {
          'winner': winner.name,
          'rounds': {for (final player in DuelPlayer.values) player.name: _roundWins[player]},
          ...duelResultData,
        },
      );
    } else {
      _phase = DuelPhase.roundOver;
      _phaseRemaining = duelRoundOverDuration;
    }
    notifyListeners();
  }

  /// Starts a new match with the same players
  void rematch() {
    restartSession();
    _ready.clear();
    _roundWins.updateAll((player, wins) => 0);
    _roundWinner = null;
    _phase = DuelPhase.ready;
    resetRound();
    notifyListeners();
  }
}
