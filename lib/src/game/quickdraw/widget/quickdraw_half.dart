import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_game_controller.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/game/quickdraw/game/logic/quickdraw_game_controller.dart';
import 'package:flutter_mini_games/src/game/quickdraw/style/quickdraw_theme.dart';

/// The half of one player: wait, GO or too early. Every state has its own color plus a big
/// icon and text, so GO never relies on color alone.
///
/// The color changes instantly (no animation), an animation would delay the moment the players can react.
class QuickdrawHalf extends StatelessWidget {
  final QuickdrawGameController controller;
  final DuelPlayer player;

  const QuickdrawHalf({
    required this.controller,
    required this.player,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = QuickdrawTheme.of(context);
    final colors = theme.colors;
    final isTooEarly = controller.phase == DuelPhase.roundOver && controller.earlyPlayer == player;
    final (background, foreground) = switch (controller.phase) {
      DuelPhase.playing when controller.isGo => (colors.go, colors.onGo),
      DuelPhase.playing => (colors.waiting, colors.onWaiting),
      _ when isTooEarly => (colors.tooEarly, colors.onTooEarly),
      _ => (colors.idle, colors.onIdle),
    };
    // Outside a playing round DuelPhaseOverlay and QuickdrawResultBanner show the messages,
    // the half only keeps its color (too early stays red behind the round result)
    if (controller.phase != DuelPhase.playing) return ColoredBox(color: background);
    return ColoredBox(
      color: background,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          // Scales down on small halves instead of overflowing
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: controller.isGo ? _buildGo(theme, foreground) : _buildWait(theme, foreground),
          ),
        ),
      ),
    );
  }

  Widget _buildGo(QuickdrawTheme theme, Color foreground) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        Icon(Icons.bolt, size: theme.dimens.signalIconSize, color: foreground),
        Text('GO!', style: theme.textStyles.signal.copyWith(color: foreground)),
      ],
    );
  }

  Widget _buildWait(QuickdrawTheme theme, Color foreground) {
    const icon = Icons.hourglass_top;
    const message = 'Wait...';
    const hint = 'Tap your half on GO';
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        Icon(icon, size: theme.dimens.iconSize, color: foreground),
        Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textStyles.message.copyWith(color: foreground),
        ),
        Text(
          hint,
          textAlign: TextAlign.center,
          style: theme.textStyles.hint.copyWith(color: foreground),
        ),
      ],
    );
  }
}
