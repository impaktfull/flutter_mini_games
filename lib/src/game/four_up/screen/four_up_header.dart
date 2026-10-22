import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/core/duel/duel_turn_banner.dart';
import 'package:flutter_mini_games/src/game/four_up/game/logic/four_up_game_controller.dart';

/// Turn banner of one player, shown on that player's side of the board (the shared banner
/// rotates itself for [DuelPlayer.top]). Highlighted when it is their turn or they won.
class FourUpHeader extends StatelessWidget {
  final FourUpGameController controller;
  final DuelPlayer player;

  const FourUpHeader({
    required this.controller,
    required this.player,
    super.key,
  });

  String get _status {
    final winner = controller.winner;
    if (winner != null) return winner == player ? 'You win!' : 'You lose';
    if (controller.isDraw) return "It's a draw";
    return controller.currentPlayer == player ? 'Your turn' : 'Waiting…';
  }

  @override
  Widget build(BuildContext context) {
    final winner = controller.winner;
    return DuelTurnBanner(
      key: ValueKey('four_up_banner_${player.name}'),
      player: player,
      isActive: winner == null ? !controller.isDraw && controller.currentPlayer == player : winner == player,
      status: _status,
    );
  }
}
