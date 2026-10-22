import 'dart:math';
import 'dart:ui';

import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/controller/realtime_game_controller.dart';
import 'package:flutter_mini_games/src/core/duel/duel_game_controller.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/game/push/game/model/push_disc.dart';

/// Sumo ring for two players: tap your half to push your disc towards the other disc
/// and push it out of the ring. Best of 3.
///
/// World units: the ring is centered at (0, 0) and starts with radius [initialRingRadius],
/// y grows downwards, so [DuelPlayer.bottom] starts below the center and [DuelPlayer.top] above.
///
/// Controls per player:
/// - Every tap gives the disc an impulse of [pushImpulse] towards the opponent's disc
/// - The tap position aims: the middle of your half pushes straight at the opponent,
///   the left / right edge up to [maxAimAngle] to your left / right ([push] `aim` -1..1)
/// - Holding a finger down keeps a weak push ([holdAcceleration]) in the aimed direction,
///   so you can steer around the opponent; tapping fast is much stronger
class PushGameController extends GameController with RealtimeGameController, DuelGameController {
  static const id = 'push';

  static const initialRingRadius = 1.0;
  static const discRadius = 0.13;

  /// Distance from the center to each disc at the start of a round
  static const startDistance = 0.45;

  /// Velocity change of one tap, world units per second
  static const pushImpulse = 0.3;

  /// Acceleration while a finger is held down, world units per second²
  static const holdAcceleration = 0.5;

  /// Largest aim angle to the left or right of the opponent, in radians (60°)
  static const maxAimAngle = pi / 3;

  /// Velocity decay per second: v *= e^(-friction * seconds)
  static const friction = 1.2;

  static const maxSpeed = 2.0;

  /// Bounciness of a collision between the discs (0 = no bounce, 1 = elastic)
  static const restitution = 0.8;

  /// The ring starts shrinking after this delay ...
  static const shrinkDelay = Duration(seconds: 3);

  /// ... by this many world units per second, until a disc is out
  static const shrinkSpeed = 0.05;

  /// Longest physics step, longer frames are split for stable collisions
  static const _maxStep = 1 / 120;

  @override
  final int roundsToWin;

  final Map<DuelPlayer, PushDisc> _discs = {};
  final Map<DuelPlayer, double> _holdAim = {};
  double _ringRadius = initialRingRadius;
  double _roundSeconds = 0;

  PushGameController({this.roundsToWin = 2}) : super(gameId: id) {
    resetRound();
  }

  PushDisc disc(DuelPlayer player) => _discs[player]!;

  /// Current radius of the shrinking ring
  double get ringRadius => _ringRadius;

  /// Aim (-1 left .. 1 right, from the player's view) while the player holds a finger down
  double? holdAim(DuelPlayer player) => _holdAim[player];

  /// Seconds played in the current round
  double get roundSeconds => _roundSeconds;

  bool get isPlaying => phase == DuelPhase.playing;

  @override
  bool get isRunning => duelIsRunning;

  static Offset startPosition(DuelPlayer player) => Offset(0, player == DuelPlayer.bottom ? startDistance : -startDistance);

  /// Direction the [player] pushes in for [aim] (-1 left .. 1 right, from the player's view)
  Offset aimDirection(DuelPlayer player, double aim) {
    var toOpponent = disc(player.opponent).position - disc(player).position;
    if (toOpponent.distance == 0) toOpponent = Offset(0, player == DuelPlayer.bottom ? -1 : 1);
    final base = toOpponent / toOpponent.distance;
    // Positive angles turn clockwise on screen, which is to the right for both players
    final angle = aim.clamp(-1.0, 1.0) * maxAimAngle;
    return Offset(
      base.dx * cos(angle) - base.dy * sin(angle),
      base.dx * sin(angle) + base.dy * cos(angle),
    );
  }

  /// One tap: an impulse towards the opponent, aimed with [aim]
  void push(DuelPlayer player, {double aim = 0}) {
    if (!isPlaying) return;
    registerMove();
    final current = disc(player);
    _discs[player] = current.copyWith(velocity: _limit(current.velocity + aimDirection(player, aim) * pushImpulse));
    notifyListeners();
  }

  /// Starts, updates ([aim]) or stops (null) the weak push while a finger is held down
  void hold(DuelPlayer player, double? aim) {
    if (aim == null) {
      _holdAim.remove(player);
    } else {
      _holdAim[player] = aim.clamp(-1.0, 1.0);
    }
    if (isPlaying) notifyListeners();
  }

  @override
  void resetRound() {
    for (final player in DuelPlayer.values) {
      _discs[player] = PushDisc(position: startPosition(player));
    }
    _ringRadius = initialRingRadius;
    _roundSeconds = 0;
  }

  @override
  void tick(Duration delta) {
    // The frame that ends the countdown belongs to the countdown, not to the round
    final wasPlaying = isPlaying;
    tickDuel(delta);
    if (!wasPlaying || !isPlaying) return;
    var seconds = delta.inMicroseconds / Duration.microsecondsPerSecond;
    while (seconds > 0 && isPlaying) {
      final step = min(seconds, _maxStep);
      _step(step);
      seconds -= step;
    }
    notifyListeners();
  }

  void _step(double seconds) {
    _roundSeconds += seconds;
    final shrinkSeconds = _roundSeconds - shrinkDelay.inMicroseconds / Duration.microsecondsPerSecond;
    if (shrinkSeconds > 0) _ringRadius = max(0, initialRingRadius - shrinkSeconds * shrinkSpeed);

    final decay = exp(-friction * seconds);
    for (final player in DuelPlayer.values) {
      final current = disc(player);
      var velocity = current.velocity;
      final aim = _holdAim[player];
      if (aim != null) velocity += aimDirection(player, aim) * (holdAcceleration * seconds);
      velocity = _limit(velocity * decay);
      _discs[player] = PushDisc(position: current.position + velocity * seconds, velocity: velocity);
    }
    _collide();

    final out = [
      for (final player in DuelPlayer.values)
        if (disc(player).position.distance > _ringRadius) player,
    ];
    if (out.isEmpty) return;
    endRound(out.length == 1 ? out.single.opponent : null);
  }

  /// Equal masses: exchange the momentum along the line between the centers
  void _collide() {
    final a = disc(DuelPlayer.bottom);
    final b = disc(DuelPlayer.top);
    final between = b.position - a.position;
    final distance = between.distance;
    if (distance >= discRadius * 2 || distance == 0) return;
    final normal = between / distance;

    // Separate the overlapping discs
    final overlap = discRadius * 2 - distance;
    final positionA = a.position - normal * (overlap / 2);
    final positionB = b.position + normal * (overlap / 2);
    var velocityA = a.velocity;
    var velocityB = b.velocity;

    final approaching = _dot(velocityB - velocityA, normal);
    if (approaching < 0) {
      final impulse = -(1 + restitution) * approaching / 2;
      velocityA -= normal * impulse;
      velocityB += normal * impulse;
    }
    _discs[DuelPlayer.bottom] = PushDisc(position: positionA, velocity: velocityA);
    _discs[DuelPlayer.top] = PushDisc(position: positionB, velocity: velocityB);
  }

  static double _dot(Offset a, Offset b) => a.dx * b.dx + a.dy * b.dy;

  static Offset _limit(Offset velocity) {
    final speed = velocity.distance;
    return speed > maxSpeed ? velocity * (maxSpeed / speed) : velocity;
  }
}
