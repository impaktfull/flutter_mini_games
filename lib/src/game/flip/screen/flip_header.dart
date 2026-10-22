import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/game/flip/style/flip_theme.dart';
import 'package:flutter_mini_games/src/game/flip/widget/flip_disc.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/core/duel/duel_turn_banner.dart';
import 'package:flutter_mini_games/src/game/flip/game/logic/flip_game_controller.dart';

/// Turn banner of one player: status and disc count, filled for the player to move.
/// The screen shows one per player; the shared banner rotates itself for [DuelPlayer.top].
class FlipHeader extends StatelessWidget {
  final FlipGameController controller;
  final DuelPlayer player;

  const FlipHeader({
    required this.controller,
    required this.player,
    super.key,
  });

  String get status {
    if (controller.isGameOver) {
      final winner = controller.winner;
      if (winner == null) return "It's a draw";
      return winner == player ? 'You win!' : 'You lose';
    }
    if (controller.passedPlayer == player) return 'No move, passed';
    if (controller.currentPlayer == player) {
      return controller.passedPlayer == null ? 'Your turn' : 'Your turn again';
    }
    return 'Waiting';
  }

  @override
  Widget build(BuildContext context) {
    return DuelTurnBanner(
      key: ValueKey('flip_header_${player.name}'),
      player: player,
      isActive: controller.isGameOver ? controller.winner == player : controller.currentPlayer == player,
      status: status,
      trailing: '${controller.countOf(player)}',
      leading: Container(
        width: 24,
        height: 24,
        padding: const EdgeInsets.all(3),
        // Backdrop, so the disc stays visible on the filled banner
        decoration: BoxDecoration(color: CoreGameTheme.of(context).colors.background, shape: BoxShape.circle),
        child: CustomPaint(
          painter: FlipDiscPainter(
            player: player,
            color: FlipTheme.of(context).colors.player(player),
            ringWidth: FlipTheme.of(context).dimens.ringWidth,
          ),
        ),
      ),
    );
  }
}
