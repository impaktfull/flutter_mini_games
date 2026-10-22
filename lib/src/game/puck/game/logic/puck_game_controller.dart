import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/controller/realtime_game_controller.dart';
import 'package:flutter_mini_games/src/core/duel/duel_game_controller.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';

/// Air hockey for two players on one device: drag your mallet in your own half and
/// shoot the puck into the opponent's goal. Every goal is a round, first to [goalsToWin].
///
/// All positions are in world units: the table is [width] wide and [height] high, y grows
/// downwards. [DuelPlayer.top] defends the goal at y = 0, [DuelPlayer.bottom] the goal at
/// y = [height].
class PuckGameController extends GameController with RealtimeGameController, DuelGameController {
  static const id = 'puck';

  static const width = 1.0;
  static const height = 1.8;

  /// Width of the goal mouth in the middle of the top and the bottom edge
  static const goalWidth = 0.36;

  static const puckRadius = 0.045;
  static const malletRadius = 0.075;

  /// Exponential slow down of the puck per second: speed × e^(-friction × seconds)
  static const friction = 0.35;

  /// Part of the speed the puck keeps when it bounces off a wall or a goal post
  static const wallRestitution = 0.9;

  /// Bounciness of a mallet hit, the mallet's own velocity is added on top
  static const malletRestitution = 0.8;

  static const maxPuckSpeed = 3.2;

  /// Fastest a mallet follows the finger, gives every mallet a finite velocity
  static const maxMalletSpeed = 8.0;

  /// Longest distance the puck and a mallet may move towards each other in one sub step,
  /// well below [puckRadius] + [malletRadius] so a fast puck never tunnels through a mallet
  static const maxStep = puckRadius / 2;

  /// Distance between the center line and the puck after a goal, in the half of the player who conceded
  static const serveOffset = 0.25;

  /// Distance between a mallet's start position and its goal line
  static const malletStartOffset = 0.18;

  /// Goals a player needs to win the match
  final int goalsToWin;

  Offset _puck = const Offset(width / 2, height / 2);
  Offset _puckVelocity = Offset.zero;
  final Map<DuelPlayer, Offset> _mallets = {for (final player in DuelPlayer.values) player: malletStart(player)};
  final Map<DuelPlayer, Offset> _targets = {for (final player in DuelPlayer.values) player: malletStart(player)};
  final Map<DuelPlayer, Offset> _malletVelocities = {for (final player in DuelPlayer.values) player: Offset.zero};
  DuelPlayer? _lastConceded;

  PuckGameController({this.goalsToWin = 5}) : super(gameId: id);

  @override
  int get roundsToWin => goalsToWin;

  Offset get puck => _puck;
  Offset get puckVelocity => _puckVelocity;
  Offset mallet(DuelPlayer player) => _mallets[player]!;
  Offset malletVelocity(DuelPlayer player) => _malletVelocities[player]!;
  int goals(DuelPlayer player) => roundWins(player);

  @override
  bool get isRunning => duelIsRunning;

  /// Start position of a mallet, in the middle in front of its own goal
  static Offset malletStart(DuelPlayer player) => Offset(width / 2, player == DuelPlayer.bottom ? height - malletStartOffset : malletStartOffset);

  /// Keeps a mallet position inside the half of [player] and inside the table
  static Offset clampToHalf(DuelPlayer player, Offset position) {
    final minY = player == DuelPlayer.bottom ? height / 2 + malletRadius : malletRadius;
    final maxY = player == DuelPlayer.bottom ? height - malletRadius : height / 2 - malletRadius;
    return Offset(position.dx.clamp(malletRadius, width - malletRadius), position.dy.clamp(minY, maxY));
  }

  /// Half of the table that contains [position]
  static DuelPlayer halfAt(Offset position) => position.dy < height / 2 ? DuelPlayer.top : DuelPlayer.bottom;

  /// Moves the mallet of [player] towards [target] (world units), only while a round is playing
  void moveMallet(DuelPlayer player, Offset target) {
    if (phase != DuelPhase.playing) return;
    _targets[player] = clampToHalf(player, target);
  }

  @override
  void tick(Duration delta) {
    tickDuel(delta);
    if (phase != DuelPhase.playing) return;
    final seconds = delta.inMicroseconds / Duration.microsecondsPerSecond;
    if (seconds <= 0) return;

    // Every mallet moves towards its finger at a limited speed, spread evenly over the frame
    final movements = <DuelPlayer, Offset>{};
    for (final player in DuelPlayer.values) {
      final toTarget = _targets[player]! - _mallets[player]!;
      final maxDistance = maxMalletSpeed * seconds;
      movements[player] = toTarget.distance <= maxDistance ? toTarget : toTarget / toTarget.distance * maxDistance;
      _malletVelocities[player] = movements[player]! / seconds;
    }

    // Sub steps keep every move shorter than maxStep, also at full speed
    final malletTravel = movements.values.map((movement) => movement.distance).reduce(max);
    final steps = ((maxPuckSpeed * seconds + malletTravel) / maxStep).ceil().clamp(1, 1000);
    final step = seconds / steps;

    for (var i = 0; i < steps; i++) {
      for (final player in DuelPlayer.values) {
        _mallets[player] = _mallets[player]! + movements[player]! / steps.toDouble();
      }
      _puck += _puckVelocity * step;
      _puckVelocity *= exp(-friction * step);
      for (final player in DuelPlayer.values) {
        _collideWithMallet(player);
      }
      _collideWithWalls();
      _limitSpeed();
      if (_checkGoal()) return;
    }
    notifyListeners();
  }

  void _collideWithMallet(DuelPlayer player) {
    final mallet = _mallets[player]!;
    final offset = _puck - mallet;
    final distance = offset.distance;
    const minDistance = puckRadius + malletRadius;
    if (distance >= minDistance) return;
    // Pushes the puck towards the opponent when it lies exactly on the mallet's center
    final normal = distance == 0 ? Offset(0, player == DuelPlayer.bottom ? -1 : 1) : offset / distance;
    final malletVelocity = _malletVelocities[player]!;
    final approach = _dot(_puckVelocity - malletVelocity, normal);
    if (approach < 0) _puckVelocity -= normal * ((1 + malletRestitution) * approach);
    _puck = mallet + normal * minDistance;
  }

  void _collideWithWalls() {
    var x = _puck.dx;
    var y = _puck.dy;
    var vx = _puckVelocity.dx;
    var vy = _puckVelocity.dy;
    if (x < puckRadius) {
      x = puckRadius;
      vx = vx.abs() * wallRestitution;
    } else if (x > width - puckRadius) {
      x = width - puckRadius;
      vx = -vx.abs() * wallRestitution;
    }
    final inMouth = (x - width / 2).abs() < goalWidth / 2;
    if (!inMouth) {
      if (y < puckRadius) {
        y = puckRadius;
        vy = vy.abs() * wallRestitution;
      } else if (y > height - puckRadius) {
        y = height - puckRadius;
        vy = -vy.abs() * wallRestitution;
      }
    }
    _puck = Offset(x, y);
    _puckVelocity = Offset(vx, vy);
    if (y < puckRadius || y > height - puckRadius) _collideWithPosts();
    _separateFromMallets();
  }

  /// The ends of the goal mouths: the puck bounces off them like off a point
  void _collideWithPosts() {
    const left = width / 2 - goalWidth / 2;
    const right = width / 2 + goalWidth / 2;
    for (final post in const [Offset(left, 0), Offset(right, 0), Offset(left, height), Offset(right, height)]) {
      final offset = _puck - post;
      final distance = offset.distance;
      if (distance >= puckRadius || distance == 0) continue;
      final normal = offset / distance;
      final approach = _dot(_puckVelocity, normal);
      if (approach < 0) _puckVelocity -= normal * ((1 + wallRestitution) * approach);
      _puck = post + normal * puckRadius;
    }
  }

  /// A puck pinned against a wall pushes the mallet back instead of passing through it
  void _separateFromMallets() {
    for (final player in DuelPlayer.values) {
      final offset = _puck - _mallets[player]!;
      final distance = offset.distance;
      const minDistance = puckRadius + malletRadius;
      if (distance >= minDistance || distance == 0) continue;
      _mallets[player] = clampToHalf(player, _puck - offset / distance * minDistance);
    }
  }

  void _limitSpeed() {
    final speed = _puckVelocity.distance;
    if (speed > maxPuckSpeed) _puckVelocity = _puckVelocity / speed * maxPuckSpeed;
  }

  /// Ends the round when the puck crossed a goal line, returns whether it did
  bool _checkGoal() {
    final DuelPlayer conceded;
    if (_puck.dy < 0) {
      conceded = DuelPlayer.top;
    } else if (_puck.dy > height) {
      conceded = DuelPlayer.bottom;
    } else {
      return false;
    }
    _lastConceded = conceded;
    _puckVelocity = Offset.zero;
    _malletVelocities.updateAll((player, velocity) => Offset.zero);
    endRound(conceded.opponent);
    return true;
  }

  /// Puck towards the player who conceded the last goal (center for the first round), mallets at the start
  @override
  @protected
  void resetRound() {
    final conceded = _lastConceded;
    final serveY = switch (conceded) {
      null => height / 2,
      DuelPlayer.bottom => height / 2 + serveOffset,
      DuelPlayer.top => height / 2 - serveOffset,
    };
    _puck = Offset(width / 2, serveY);
    _puckVelocity = Offset.zero;
    for (final player in DuelPlayer.values) {
      _mallets[player] = malletStart(player);
      _targets[player] = malletStart(player);
      _malletVelocities[player] = Offset.zero;
    }
  }

  @override
  void rematch() {
    _lastConceded = null;
    super.rematch();
  }

  /// Places the puck, for tests
  @visibleForTesting
  void debugSetPuck(Offset position, [Offset velocity = Offset.zero]) {
    _puck = position;
    _puckVelocity = velocity;
  }

  /// Places a mallet and its target, for tests
  @visibleForTesting
  void debugSetMallet(DuelPlayer player, Offset position) {
    _mallets[player] = clampToHalf(player, position);
    _targets[player] = _mallets[player]!;
  }

  static double _dot(Offset a, Offset b) => a.dx * b.dx + a.dy * b.dy;
}
