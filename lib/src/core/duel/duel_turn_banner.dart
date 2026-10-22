import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';

/// Shows a player whose turn it is in turn-based two-player games. Shared by all of them.
///
/// The banner of [DuelPlayer.top] is rotated 180° so the opposite player reads it. Active
/// banners are filled with the player color, inactive ones are outlined.
class DuelTurnBanner extends StatelessWidget {
  final DuelPlayer player;
  final bool isActive;

  /// Status, e.g. "Your turn" or "No move, passed"
  final String status;

  /// Optional value on the right, e.g. the number of discs or boxes
  final String? trailing;

  /// Replaces the player symbol on the left, e.g. the game's own disc (24x24)
  final Widget? leading;

  const DuelTurnBanner({
    required this.player,
    required this.isActive,
    required this.status,
    this.trailing,
    this.leading,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CoreGameTheme.of(context);
    final color = theme.playerColor(player);
    final onColor = isActive ? theme.onPlayerColor(player) : theme.colors.text;
    final trailing = this.trailing;
    return RotatedBox(
      quarterTurns: player == DuelPlayer.top ? 2 : 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: theme.dimens.padding, vertical: theme.dimens.padding / 2),
        decoration: BoxDecoration(
          color: isActive ? color : theme.colors.background,
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(theme.dimens.radiusLarge),
        ),
        child: Row(
          spacing: 8,
          children: [
            leading ??
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: onColor, width: 2),
                  ),
                  child: Text(
                    player.symbol,
                    style: theme.textStyles.caption.copyWith(color: onColor, fontWeight: FontWeight.bold),
                  ),
                ),
            Expanded(
              child: Text(
                '${player.label} · $status',
                overflow: TextOverflow.ellipsis,
                style: theme.textStyles.label.copyWith(color: onColor),
              ),
            ),
            if (trailing != null) Text(trailing, style: theme.textStyles.label.copyWith(color: onColor)),
          ],
        ),
      ),
    );
  }
}
