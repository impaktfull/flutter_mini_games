import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/game/boxes/game/logic/boxes_game_controller.dart';
import 'package:flutter_mini_games/src/game/boxes/style/boxes_theme.dart';
import 'package:flutter_mini_games/src/game/boxes/widget/boxes_board.dart';

/// Banner of one player: whose turn it is (or the result) and the player's boxes.
/// The screen shows one for each player, the top one rotated for the opposite player.
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

  bool get _isHighlighted => controller.isGameOver ? controller.winner == player : controller.currentPlayer == player;

  @override
  Widget build(BuildContext context) {
    final theme = BoxesTheme.of(context);
    final playerColor = theme.playerColor(player);
    final onPlayerColor = theme.onPlayerColor(player);
    final isHighlighted = _isHighlighted;
    final foreground = isHighlighted ? onPlayerColor : theme.colors.onBanner;
    final boxes = controller.boxesOf(player);
    return Container(
      key: ValueKey('boxes_header_${player.name}'),
      padding: theme.dimens.bannerPadding,
      decoration: BoxDecoration(
        color: isHighlighted ? playerColor : theme.colors.banner,
        borderRadius: BorderRadius.circular(theme.dimens.bannerRadius),
        border: Border.all(color: playerColor, width: theme.dimens.bannerBorderWidth),
      ),
      child: Row(
        spacing: 12,
        children: [
          Container(
            width: theme.dimens.bannerSymbolSize,
            height: theme.dimens.bannerSymbolSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isHighlighted ? onPlayerColor : playerColor,
              borderRadius: BorderRadius.circular(theme.dimens.boxRadius),
            ),
            child: Text(
              boxesSymbol(player),
              style: theme.textStyles.bannerLabel.copyWith(color: isHighlighted ? playerColor : onPlayerColor),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textStyles.bannerLabel.copyWith(color: foreground),
                ),
                Text(
                  _status,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textStyles.bannerStatus.copyWith(color: foreground),
                ),
              ],
            ),
          ),
          Text(
            '$boxes',
            key: ValueKey('boxes_score_${player.name}'),
            style: theme.textStyles.bannerScore.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}
