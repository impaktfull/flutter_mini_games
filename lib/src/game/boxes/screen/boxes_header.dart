import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/core/duel/duel_turn_banner.dart';
import 'package:flutter_mini_games/src/game/boxes/game/logic/boxes_game_controller.dart';

/// Banner of one player: whose turn it is (or the result) and the player's boxes.
/// The screen shows one for each player; the shared banner rotates itself for [DuelPlayer.top].
class BoxesHeader extends StatelessWidget {
  final BoxesGameController controller;
  final DuelPlayer player;

  const BoxesHeader({
    required this.controller,
    required this.player,
    super.key,
  });

  String get _status {
    if (controller.isGameOver) {
      final winner = controller.winner;
      if (winner == null) return "It's a draw";
      return winner == player ? 'You win!' : 'You lose';
    }
    return controller.currentPlayer == player ? 'Your turn' : 'Waiting';
  }

  @override
  Widget build(BuildContext context) {
    return DuelTurnBanner(
      key: ValueKey('boxes_header_${player.name}'),
      player: player,
      isActive: controller.isGameOver ? controller.winner == player : controller.currentPlayer == player,
      status: _status,
      trailing: '${controller.boxesOf(player)}',
    );
  }
}
