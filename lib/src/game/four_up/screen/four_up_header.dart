import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/core/duel/duel_turn_banner.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/game/four_up/game/logic/four_up_game_controller.dart';
import 'package:flutter_mini_games/src/game/four_up/style/four_up_theme.dart';
import 'package:flutter_mini_games/src/game/four_up/widget/four_up_disc.dart';

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
      leading: _BannerDisc(player: player),
    );
  }
}

/// The player's disc in the banner, on a backdrop so it stays visible on the filled banner
class _BannerDisc extends StatelessWidget {
  final DuelPlayer player;

  const _BannerDisc({required this.player});

  @override
  Widget build(BuildContext context) {
    final theme = FourUpTheme.of(context);
    return Container(
      width: 24,
      height: 24,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(color: CoreGameTheme.of(context).colors.background, shape: BoxShape.circle),
      child: CustomPaint(
        painter: _BannerDiscPainter(
          player: player,
          color: theme.colors.disc(player),
          patternColor: theme.colors.onDisc(player),
        ),
      ),
    );
  }
}

class _BannerDiscPainter extends CustomPainter {
  final DuelPlayer player;
  final Color color;
  final Color patternColor;

  const _BannerDiscPainter({
    required this.player,
    required this.color,
    required this.patternColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    paintFourUpDisc(
      canvas,
      center: size.center(Offset.zero),
      radius: size.shortestSide / 2,
      player: player,
      color: color,
      patternColor: patternColor,
      patternStrokeWidth: 2,
    );
  }

  @override
  bool shouldRepaint(covariant _BannerDiscPainter oldDelegate) => oldDelegate.player != player || oldDelegate.color != color || oldDelegate.patternColor != patternColor;
}
