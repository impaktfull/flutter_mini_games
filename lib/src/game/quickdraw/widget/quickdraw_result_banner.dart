import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_game_controller.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/game/quickdraw/game/logic/quickdraw_game_controller.dart';
import 'package:flutter_mini_games/src/game/quickdraw/style/quickdraw_theme.dart';

/// Best reaction time of the player at the end of the match, at the top of a half. The reason a
/// round ended is the `roundMessage` of `DuelPhaseOverlay`, which shows nothing extra at the end of
/// a match. Sits on top of `DuelPhaseOverlay` so it stays readable; it never takes touches.
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
    if (controller.phase != DuelPhase.finished) return const SizedBox.shrink();
    final best = controller.bestReactionMs(player);
    final text = best == null ? 'Your best: –' : 'Your best: $best ms';
    final theme = QuickdrawTheme.of(context);
    final background = theme.colors.banner;
    final foreground = theme.colors.onBanner;
    return IgnorePointer(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          // Compact, so it stays clear of the trophy of the winner below it
          padding: const EdgeInsets.all(4),
          child: DecoratedBox(
            decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(theme.dimens.bannerRadius)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  Icon(Icons.timer_outlined, size: theme.dimens.bannerIconSize, color: foreground),
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
}
