import 'package:flutter/foundation.dart';
import 'package:flutter_mini_games/src/core/controller/game_controller.dart';

/// For games that update every frame (e.g. Snake, Flit). Drive it with `GameLoop`.
///
/// Keep the simulation in [tick] and independent of the frame rate: move things by
/// `speed * delta`, never by a fixed amount per frame.
///
/// Frame updates and state updates are split, so a frame never rebuilds the screen:
/// - [notifyFrame] after things moved: only listeners of [frame] are notified, e.g. a
///   `CustomPainter(repaint: controller.frame)` that reads the controller in `paint`
/// - `notifyListeners()` only when state shown outside the board changes (start, game over,
///   score, lives, phase, ...): it rebuilds the screen and notifies [frame] as well
mixin RealtimeGameController on GameController {
  final _FrameNotifier _frame = _FrameNotifier();

  /// Notifies every frame in which something moved, and on every state change
  Listenable get frame => _frame;

  /// Whether `GameLoop` should call [tick], e.g. playing and not paused
  bool get isRunning;

  /// Advances the game by [delta]. Called every frame while [isRunning].
  void tick(Duration delta);

  /// Repaints the board without rebuilding the screen
  @protected
  void notifyFrame() => _frame.notify();

  @override
  void notifyListeners() {
    super.notifyListeners();
    _frame.notify();
  }

  @override
  void dispose() {
    super.dispose();
    _frame.dispose();
  }
}

class _FrameNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}
