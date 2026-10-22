import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_game_controller.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/game/quickdraw/game/logic/quickdraw_game_controller.dart';
import 'package:flutter_mini_games/src/game/quickdraw/style/quickdraw_theme.dart';

/// Reaction time or "Too early!" of the last round and the best time at the end of the match,
/// at the top of a half. Sits on top of `DuelPhaseOverlay` so it stays readable; it never takes touches.
class QuickdrawResultBanner extends StatelessWidget {
  final QuickdrawGameController controller;
  final DuelPlayer player;

  const QuickdrawResultBanner({
    required this.controller,
    required this.player,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final content = _content();
    if (content == null) return const SizedBox.shrink();
    final (icon, text, isTooEarly) = content;
    final theme = QuickdrawTheme.of(context);
    final background = isTooEarly ? theme.colors.tooEarly : theme.colors.banner;
    final foreground = isTooEarly ? theme.colors.onTooEarly : theme.colors.onBanner;
    return IgnorePointer(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: DecoratedBox(
            decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(theme.dimens.bannerRadius)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  Icon(icon, size: theme.dimens.bannerIconSize, color: foreground),
                  Flexible(
                    child: Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textStyles.banner.copyWith(color: foreground),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Icon, text and whether this player tapped too early; null when there is nothing to show
  (IconData, String, bool)? _content() {
    switch (controller.phase) {
      case DuelPhase.roundOver:
        final early = controller.earlyPlayer;
        if (early == player) return (Icons.front_hand, 'Too early!', true);
        if (early != null) return (Icons.front_hand, '${early.label} was too early', false);
        final winner = controller.roundWinner;
        final ms = controller.roundReactionMs;
        if (winner == null || ms == null) return null;
        return (Icons.bolt, winner == player ? '$ms ms' : '${winner.label}: $ms ms', false);
      case DuelPhase.finished:
        final best = controller.bestReactionMs(player);
        return (Icons.timer_outlined, best == null ? 'Your best: –' : 'Your best: $best ms', false);
      case DuelPhase.ready:
      case DuelPhase.countdown:
      case DuelPhase.playing:
        return null;
    }
  }
}
