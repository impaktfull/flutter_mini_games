import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/game/flip/game/logic/flip_game_controller.dart';
import 'package:flutter_mini_games/src/game/flip/style/flip_theme.dart';
import 'package:flutter_mini_games/src/game/flip/widget/flip_disc.dart';

/// Turn banner of one player: disc, name, status and disc count.
/// The banner of the player to move is filled with the player color.
/// The screen shows one per player, the one of [DuelPlayer.top] rotated towards that player.
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
    final theme = FlipTheme.of(context);
    final isActive = controller.isGameOver ? controller.winner == player : controller.currentPlayer == player;
    final background = isActive ? theme.colors.player(player) : theme.colors.banner;
    final foreground = isActive ? theme.colors.onPlayer(player) : theme.colors.text;
    final muted = isActive ? theme.colors.onPlayer(player) : theme.colors.textMuted;
    return AnimatedContainer(
      key: ValueKey('flip_header_${player.name}'),
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(theme.dimens.bannerRadius),
      ),
      child: Row(
        spacing: 10,
        children: [
          SizedBox.square(
            dimension: theme.dimens.bannerDiscSize,
            child: CustomPaint(
              painter: FlipDiscPainter(
                player: player,
                color: isActive ? foreground : theme.colors.player(player),
                ringWidth: theme.dimens.ringWidth,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  player.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textStyles.playerName.copyWith(color: foreground),
                ),
                Text(
                  status,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textStyles.status.copyWith(color: muted),
                ),
              ],
            ),
          ),
          Text(
            '${controller.countOf(player)}',
            style: theme.textStyles.count.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}
