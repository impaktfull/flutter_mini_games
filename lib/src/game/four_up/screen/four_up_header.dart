import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/game/four_up/game/logic/four_up_game_controller.dart';
import 'package:flutter_mini_games/src/game/four_up/style/four_up_theme.dart';
import 'package:flutter_mini_games/src/game/four_up/widget/four_up_disc.dart';

/// Turn banner of one player, shown on that player's side of the board (rotated for
/// [DuelPlayer.top]). Highlighted in the player's color when it is their turn or they won.
class FourUpHeader extends StatelessWidget {
  final FourUpGameController controller;
  final DuelPlayer player;

  const FourUpHeader({
    required this.controller,
    required this.player,
    super.key,
  });

  String get _message {
    final winner = controller.winner;
    if (winner != null) return winner == player ? 'You win!' : 'You lose';
    if (controller.isDraw) return "It's a draw";
    return controller.currentPlayer == player ? 'Your turn' : 'Waiting…';
  }

  @override
  Widget build(BuildContext context) {
    final theme = FourUpTheme.of(context);
    final winner = controller.winner;
    final isActive = winner == null ? !controller.isDraw && controller.currentPlayer == player : winner == player;
    final style = isActive ? theme.textStyles.banner.copyWith(color: theme.colors.onDisc(player)) : theme.textStyles.bannerInactive;
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.fromLTRB(8, 6, 14, 6),
        decoration: BoxDecoration(
          color: isActive ? theme.colors.disc(player) : theme.colors.bannerInactive,
          borderRadius: BorderRadius.circular(theme.dimens.bannerRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            // On the active banner the disc sits on its own color: a ring keeps it visible
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: isActive ? Border.all(color: theme.colors.onDisc(player), width: 1.5) : null,
              ),
              child: FourUpDisc(player: player, size: theme.dimens.bannerDiscSize),
            ),
            Flexible(
              child: Text(
                '${player.label} · $_message',
                key: ValueKey('four_up_banner_${player.name}'),
                overflow: TextOverflow.ellipsis,
                style: style,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
