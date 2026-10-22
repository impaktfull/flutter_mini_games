import 'dart:math';

enum WhackTargetKind {
  /// Tap it: +1 point
  critter,

  /// Don't tap it: -1 point
  decoy,
}

/// Something that popped up out of a hole. Times are in seconds since the start of the round.
class WhackTarget {
  /// Index of the hole, 0..8 from the top left, row by row
  final int hole;
  final WhackTargetKind kind;

  /// Round time at which the target started to pop up
  final double spawnedAt;

  /// How long the target can be hit, it hides again afterwards
  final double visibleDuration;

  /// Round time at which the target was tapped, null when it was not tapped (yet)
  final double? hitAt;

  const WhackTarget({
    required this.hole,
    required this.kind,
    required this.spawnedAt,
    required this.visibleDuration,
    this.hitAt,
  });

  bool get isDecoy => kind == WhackTargetKind.decoy;
  bool get isHit => hitAt != null;

  /// Round time at which the target can no longer be hit
  double get hidesAt => spawnedAt + visibleDuration;

  /// Whether a tap at [time] hits this target
  bool isHittableAt(double time) => !isHit && time >= spawnedAt && time < hidesAt;

  /// Round time at which the target has disappeared and its hole is free again
  double goneAt(double hitLinger) {
    final hitAt = this.hitAt;
    return hitAt == null ? hidesAt : hitAt + hitLinger;
  }

  /// How far the target is out of its hole at [time]: 0 hidden, 1 fully up.
  /// It pops up in [popDuration], hides in the last [popDuration] and drops in [hitLinger] after a hit.
  double popAt(double time, {required double popDuration, required double hitLinger}) {
    final hitAt = this.hitAt;
    final age = time - spawnedAt;
    final rising = popDuration <= 0 ? 1.0 : age / popDuration;
    final falling = hitAt == null ? (popDuration <= 0 ? 1.0 : (hidesAt - time) / popDuration) : (hitLinger <= 0 ? 0.0 : 1 - (time - hitAt) / hitLinger);
    return min(rising, falling).clamp(0.0, 1.0);
  }

  WhackTarget copyWith({double? hitAt}) => WhackTarget(
    hole: hole,
    kind: kind,
    spawnedAt: spawnedAt,
    visibleDuration: visibleDuration,
    hitAt: hitAt ?? this.hitAt,
  );

  @override
  String toString() => 'WhackTarget(hole: $hole, kind: ${kind.name}, spawnedAt: $spawnedAt, visibleDuration: $visibleDuration, hitAt: $hitAt)';
}
