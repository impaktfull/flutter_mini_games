import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_game_controller.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';

/// Match flow on one player's half: ready button, countdown, round result, winner and
/// rematch, plus the round score. Shared by all two-player games.
///
/// Put it on top of the game in each half (e.g. in a `Stack` inside `DuelLayout.side`).
/// While a round is playing it only shows the score and lets touches through.
class DuelPhaseOverlay extends StatelessWidget {
  final DuelGameController controller;
  final DuelPlayer player;

  const DuelPhaseOverlay({
    required this.controller,
    required this.player,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CoreGameTheme.of(context);
    final message = _buildMessage(theme);
    return Stack(
      fit: StackFit.expand,
      children: [
        if (message != null)
          Positioned.fill(
            child: ColoredBox(
              color: theme.colors.background.withValues(alpha: 0.85),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(padding: EdgeInsets.all(theme.dimens.padding), child: message),
                ),
              ),
            ),
          ),
        Align(
          alignment: Alignment.bottomCenter,
          child: IgnorePointer(
            child: Padding(
              padding: EdgeInsets.all(theme.dimens.padding / 2),
              child: Text(
                '${player.label}  ${controller.roundWins(player)} – ${controller.roundWins(player.opponent)}',
                style: theme.textStyles.caption,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget? _buildMessage(CoreGameTheme theme) {
    switch (controller.phase) {
      case DuelPhase.ready:
        final isReady = controller.isReady(player);
        return _ReadyButton(
          label: isReady ? 'Waiting for ${player.opponent.label}' : 'Tap when ready',
          color: theme.playerColor(player),
          onColor: theme.onPlayerColor(player),
          onTap: isReady ? null : () => controller.setReady(player),
        );
      case DuelPhase.countdown:
        return Text('${controller.countdownSeconds}', style: theme.textStyles.title.copyWith(fontSize: 64));
      case DuelPhase.playing:
        return null;
      case DuelPhase.roundOver:
        final winner = controller.roundWinner;
        final text = winner == null ? 'Draw' : (winner == player ? 'You win the round' : '${winner.label} wins the round');
        return Text(text, textAlign: TextAlign.center, style: theme.textStyles.title);
      case DuelPhase.finished:
        final hasWon = controller.matchWinner == player;
        return Column(
          mainAxisSize: MainAxisSize.min,
          spacing: theme.dimens.padding,
          children: [
            Text(hasWon ? '🏆 You win!' : 'You lose', textAlign: TextAlign.center, style: theme.textStyles.title),
            _ReadyButton(
              label: 'Rematch',
              color: theme.playerColor(player),
              onColor: theme.onPlayerColor(player),
              onTap: controller.rematch,
            ),
          ],
        );
    }
  }
}

class _ReadyButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color onColor;
  final VoidCallback? onTap;

  const _ReadyButton({
    required this.label,
    required this.color,
    required this.onColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CoreGameTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.6 : 1,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: theme.dimens.padding * 2, vertical: theme.dimens.padding),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(theme.dimens.radiusLarge),
          ),
          child: Text(label, style: theme.textStyles.label.copyWith(color: onColor)),
        ),
      ),
    );
  }
}
