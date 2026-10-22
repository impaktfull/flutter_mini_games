import 'package:flutter_mini_games/src/core/controller/game_controller.dart';

/// For games that update every frame (e.g. Snake, Flit). Drive it with `GameLoop`.
///
/// Keep the simulation in [tick] and independent of the frame rate: move things by
/// `speed * delta`, never by a fixed amount per frame.
mixin RealtimeGameController on GameController {
  /// Whether `GameLoop` should call [tick], e.g. playing and not paused
  bool get isRunning;

  /// Advances the game by [delta]. Called every frame while [isRunning].
  void tick(Duration delta);
}
