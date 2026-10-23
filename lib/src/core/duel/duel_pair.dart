import 'package:flutter_mini_games/src/core/duel/duel_player.dart';

/// One value per player of a two-player game.
///
/// Use it for per-player state instead of a `Map<DuelPlayer, T>`: every player always has a
/// value, so a lookup never needs a `!` and can never be missing.
class DuelPair<T> {
  T bottom;
  T top;

  DuelPair(this.bottom, this.top);

  /// Creates the value of each player with [create] (a new object per player)
  DuelPair.generate(T Function(DuelPlayer player) create) : bottom = create(DuelPlayer.bottom), top = create(DuelPlayer.top);

  T operator [](DuelPlayer player) => switch (player) {
    DuelPlayer.bottom => bottom,
    DuelPlayer.top => top,
  };

  void operator []=(DuelPlayer player, T value) {
    switch (player) {
      case DuelPlayer.bottom:
        bottom = value;
      case DuelPlayer.top:
        top = value;
    }
  }

  /// Replaces the value of each player with the result of [update]
  void updateAll(T Function(DuelPlayer player, T value) update) {
    bottom = update(DuelPlayer.bottom, bottom);
    top = update(DuelPlayer.top, top);
  }

  /// The values of both players, bottom first
  Iterable<T> get values => [bottom, top];

  /// For result data: `{'bottom': ..., 'top': ...}`
  Map<String, T> toJson() => {DuelPlayer.bottom.name: bottom, DuelPlayer.top.name: top};
}
