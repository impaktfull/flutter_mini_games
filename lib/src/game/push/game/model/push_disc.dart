import 'dart:ui';

/// A player's disc in world units: the ring is centered at (0, 0), y grows downwards
/// (towards the bottom player).
class PushDisc {
  final Offset position;

  /// World units per second
  final Offset velocity;

  const PushDisc({
    required this.position,
    this.velocity = Offset.zero,
  });

  PushDisc copyWith({
    Offset? position,
    Offset? velocity,
  }) => PushDisc(
    position: position ?? this.position,
    velocity: velocity ?? this.velocity,
  );
}
