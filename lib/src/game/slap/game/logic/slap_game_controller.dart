import 'dart:math';

import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/controller/realtime_game_controller.dart';
import 'package:flutter_mini_games/src/core/duel/duel_game_controller.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/game/slap/game/model/slap_attack.dart';

/// Slap: one player attacks, the other defends; roles swap every round.
///
/// Every round is one slap attempt:
/// - The defender holds their target (any finger on it counts, tracked per pointer).
///   The attacker can only attack while the defender holds.
/// - The attacker taps Slap or Fake. Both raise the hand for a random [windUp] between
///   [minWindUp] and [maxWindUp] (injectable `Random`), so they look the same and their timing
///   can't be learned. Then a slap comes down in [strikeDuration], a fake goes back in
///   [retractDuration]. The attacker has [maxFakes] fakes per round.
/// - Lifting during a slap (wind-up or strike) dodges it: point for the defender.
///   Still holding when it lands: point for the attacker.
///   Lifting during a fake: point for the attacker.
///   No slap within [attackTimeLimit] of holding: point for the defender.
///
/// Time is game time from [tick] (driven by `GameLoop`), so tests drive [tick] directly.
class SlapGameController extends GameController with RealtimeGameController, DuelGameController {
  static const id = 'slap';

  /// Points (rounds) a player needs to win the match
  static const pointsToWin = 5;

  /// Shortest and longest random wind-up of a slap or a fake
  static const minWindUp = Duration(milliseconds: 250);
  static const maxWindUp = Duration(milliseconds: 700);

  /// Time a slap takes to come down after the wind-up: the defender's reaction window
  static const strikeDuration = Duration(milliseconds: 350);

  /// Time a fake takes to go back after the wind-up
  static const retractDuration = Duration(milliseconds: 250);

  /// Holding time the attacker has to slap, fakes don't count
  static const attackTimeLimit = Duration(seconds: 6);

  /// Fakes the attacker can use per round
  static const maxFakes = 3;

  final Random _random;
  final Map<DuelPlayer, Set<int>> _pointers = {for (final player in DuelPlayer.values) player: <int>{}};

  DuelPlayer _attacker = DuelPlayer.bottom;
  SlapAttackState _attack = SlapAttackState.waitingForHold;
  bool _isFake = false;
  Duration _windUp = Duration.zero;
  Duration _elapsed = Duration.zero;
  Duration _attackTime = Duration.zero;
  int _fakesLeft = maxFakes;
  SlapRoundEnd? _roundEnd;

  SlapGameController({Random? random}) : _random = random ?? Random(), super(gameId: id);

  @override
  int get roundsToWin => pointsToWin;

  @override
  bool get isRunning => duelIsRunning;

  /// Attacker of the current round. [DuelPlayer.bottom] attacks first, roles swap every round
  DuelPlayer get attacker => _attacker;
  DuelPlayer get defender => _attacker.opponent;

  /// Whether [player] has a finger on their target
  bool isHolding(DuelPlayer player) => _pointers[player]!.isNotEmpty;

  SlapAttackState get attack => _attack;

  /// Whether the running attack is a fake, only known to the attacker
  bool get isFake => _isFake;

  /// Random wind-up of the running attack
  Duration get windUp => _windUp;

  int get fakesLeft => _fakesLeft;

  /// How the last round ended, null while it is played
  SlapRoundEnd? get roundEnd => _roundEnd;

  bool get isPlaying => phase == DuelPhase.playing;

  /// Whether the attacker can slap (or fake) right now
  bool get canAttack => isPlaying && _attack == SlapAttackState.armed;
  bool get canFake => canAttack && _fakesLeft > 0;

  /// Part of [attackTimeLimit] that is left, 1 at the start of a round
  double get attackTimeLeft => 1 - (_attackTime.inMicroseconds / attackTimeLimit.inMicroseconds).clamp(0.0, 1.0);

  /// Distance of the hand from its rest position towards the target, 0..1 (1 = on the target)
  double get handPosition {
    if (_roundEnd == SlapRoundEnd.slapped) return 1;
    if (_attack == SlapAttackState.strike) return _progress(strikeDuration);
    return 0;
  }

  /// How far the hand is raised, 0..1
  double get handLift {
    switch (_attack) {
      case SlapAttackState.windUp:
        final t = _progress(_windUp);
        return 1 - (1 - t) * (1 - t);
      case SlapAttackState.strike:
        return 1 - _progress(strikeDuration);
      case SlapAttackState.retract:
        return 1 - _progress(retractDuration);
      case SlapAttackState.waitingForHold:
      case SlapAttackState.armed:
        return 0;
    }
  }

  double _progress(Duration duration) => (_elapsed.inMicroseconds / duration.inMicroseconds).clamp(0.0, 1.0);

  @override
  void resetRound() {
    _attacker = (roundWins(DuelPlayer.bottom) + roundWins(DuelPlayer.top)).isEven ? DuelPlayer.bottom : DuelPlayer.top;
    // The attacker has no target: forget their fingers, the target they were on is gone
    _pointers[_attacker]!.clear();
    _attack = SlapAttackState.waitingForHold;
    _isFake = false;
    _windUp = Duration.zero;
    _elapsed = Duration.zero;
    _attackTime = Duration.zero;
    _fakesLeft = maxFakes;
    _roundEnd = null;
  }

  @override
  void onRoundStarted() {
    if (isHolding(defender)) _attack = SlapAttackState.armed;
  }

  /// A finger of [player] touches their target. Tracked in every phase, so a finger that
  /// is put down during the countdown counts as holding when the round starts
  void press(DuelPlayer player, int pointer) {
    if (!_pointers[player]!.add(pointer)) return;
    if (isPlaying && player == defender && _attack == SlapAttackState.waitingForHold) {
      _attack = SlapAttackState.armed;
    }
    notifyListeners();
  }

  /// A finger of [player] leaves their target (lifted or cancelled)
  void release(DuelPlayer player, int pointer) {
    if (!_pointers[player]!.remove(pointer)) return;
    if (isPlaying && player == defender && !isHolding(player)) _onDefenderLifted();
    notifyListeners();
  }

  void _onDefenderLifted() {
    switch (_attack) {
      case SlapAttackState.waitingForHold:
        return;
      case SlapAttackState.armed:
        // No attack yet: no penalty, the attacker has to wait until the defender holds again
        _attack = SlapAttackState.waitingForHold;
      case SlapAttackState.windUp:
        _endRound(_isFake ? attacker : defender, _isFake ? SlapRoundEnd.flinched : SlapRoundEnd.dodged);
      case SlapAttackState.strike:
        _endRound(defender, SlapRoundEnd.dodged);
      case SlapAttackState.retract:
        _endRound(attacker, SlapRoundEnd.flinched);
    }
  }

  /// The attacker taps their slap button
  void slap(DuelPlayer player) => _startAttack(player, isFake: false);

  /// The attacker taps their fake button
  void fake(DuelPlayer player) => _startAttack(player, isFake: true);

  void _startAttack(DuelPlayer player, {required bool isFake}) {
    if (player != attacker || !canAttack) return;
    if (isFake && _fakesLeft == 0) return;
    if (isFake) _fakesLeft--;
    registerMove();
    _isFake = isFake;
    final range = maxWindUp.inMicroseconds - minWindUp.inMicroseconds;
    _windUp = Duration(microseconds: minWindUp.inMicroseconds + (_random.nextDouble() * range).round());
    _elapsed = Duration.zero;
    _attack = SlapAttackState.windUp;
    notifyListeners();
  }

  @override
  void tick(Duration delta) {
    if (!tickDuel(delta)) return;
    switch (_attack) {
      case SlapAttackState.waitingForHold:
        return;
      case SlapAttackState.armed:
        _attackTime += delta;
        if (_attackTime >= attackTimeLimit) {
          _endRound(defender, SlapRoundEnd.tooSlow);
          return;
        }
      case SlapAttackState.windUp:
      case SlapAttackState.strike:
      case SlapAttackState.retract:
        _advanceAttack(delta);
        if (!isPlaying) return;
    }
    notifyListeners();
  }

  /// Moves the attack through its stages; a stage that ends within [delta] hands the rest
  /// of [delta] to the next one, so the result does not depend on how `tick` is split
  void _advanceAttack(Duration delta) {
    _elapsed += delta;
    while (true) {
      switch (_attack) {
        case SlapAttackState.windUp:
          if (_elapsed < _windUp) return;
          _elapsed -= _windUp;
          _attack = _isFake ? SlapAttackState.retract : SlapAttackState.strike;
        case SlapAttackState.strike:
          if (_elapsed < strikeDuration) return;
          _endRound(attacker, SlapRoundEnd.slapped);
          return;
        case SlapAttackState.retract:
          if (_elapsed < retractDuration) return;
          // The defender still holds, otherwise the round would be over
          _attack = SlapAttackState.armed;
          _isFake = false;
          _elapsed = Duration.zero;
          return;
        case SlapAttackState.waitingForHold:
        case SlapAttackState.armed:
          return;
      }
    }
  }

  void _endRound(DuelPlayer winner, SlapRoundEnd end) {
    _roundEnd = end;
    endRound(winner);
  }
}
