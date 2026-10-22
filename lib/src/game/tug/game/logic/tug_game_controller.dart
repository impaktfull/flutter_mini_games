import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/controller/realtime_game_controller.dart';
import 'package:flutter_mini_games/src/core/duel/duel_game_controller.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';

/// Tug: tug of war for two players on one device, best of 3.
///
/// Both players mash their half of the screen. Every tap pulls the rope marker one step
/// toward the tapping player; the first to pull it [stepsToWin] steps from the middle
/// (to their edge) wins the round.
///
/// The marker position is kept in whole steps, so the result only depends on the taps.
class TugGameController extends GameController with RealtimeGameController, DuelGameController {
  static const id = 'tug';

  /// Taps from the middle to a player's edge
  static const stepsToWin = 15;

  int _position = 0;
  final Map<DuelPlayer, int> _pulls = {DuelPlayer.bottom: 0, DuelPlayer.top: 0};

  TugGameController() : super(gameId: id);

  @override
  int get roundsToWin => 2;

  @override
  bool get isRunning => duelIsRunning;

  /// Marker position in steps: 0 is the middle, [stepsToWin] the bottom edge, -[stepsToWin] the top edge
  int get position => _position;

  /// Marker position from -1 (top edge) to 1 (bottom edge)
  double get progress => _position / stepsToWin;

  /// Taps of [player] in the current round, e.g. to animate each pull
  int pulls(DuelPlayer player) => _pulls[player]!;

  /// The player whose edge the marker is closest to, null in the middle
  DuelPlayer? get leader => _position == 0 ? null : (_position > 0 ? DuelPlayer.bottom : DuelPlayer.top);

  @override
  void tick(Duration delta) {
    tickDuel(delta);
    // The rope only moves on taps; the loop drives the countdown and the pause between rounds
  }

  /// One tap of [player]: pulls the marker one step toward their edge
  void pull(DuelPlayer player) {
    if (phase != DuelPhase.playing) return;
    registerMove();
    _pulls[player] = _pulls[player]! + 1;
    _position += player == DuelPlayer.bottom ? 1 : -1;
    if (_position.abs() >= stepsToWin) {
      endRound(player);
      return;
    }
    notifyListeners();
  }

  @override
  void resetRound() {
    _position = 0;
    _pulls.updateAll((player, pulls) => 0);
  }
}
