import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/core/duel/duel_turn_banner.dart';
import 'package:flutter_mini_games/src/game/tic_tac_toe/game/logic/tic_tac_toe_game_controller.dart';
import 'package:flutter_mini_games/src/game/tic_tac_toe/style/tic_tac_toe_theme.dart';

/// Turn banner of one player, shown on that player's side of the board (the shared banner
/// rotates itself for [DuelPlayer.top]). Highlighted when it is their turn or they won.
class TicTacToeHeader extends StatelessWidget {
  final TicTacToeGameController controller;
  final DuelPlayer player;

  const TicTacToeHeader({
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
      key: ValueKey('tic_tac_toe_banner_${player.name}'),
      player: player,
      isActive: winner == null ? !controller.isDraw && controller.currentPlayer == player : winner == player,
      status: _status,
      leading: _BannerMark(player: player),
    );
  }
}

/// The player's mark in the banner, on a backdrop so it stays visible on the filled banner
class _BannerMark extends StatelessWidget {
  final DuelPlayer player;

  const _BannerMark({required this.player});

  @override
  Widget build(BuildContext context) {
    final theme = TicTacToeTheme.of(context);
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: theme.colors.cellBackground, shape: BoxShape.circle),
      child: Text(
        TicTacToeGameController.markOf(player),
        style: theme.textStyles.bannerMark.copyWith(color: theme.colors.playerColor(player)),
      ),
    );
  }
}
