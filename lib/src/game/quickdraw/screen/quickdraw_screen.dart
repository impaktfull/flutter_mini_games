import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_layout.dart';
import 'package:flutter_mini_games/src/core/duel/duel_phase_overlay.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/core/widget/components/how_to_play.dart';
import 'package:flutter_mini_games/src/core/widget/game_loop.dart';
import 'package:flutter_mini_games/src/core/widget/provider/game_controller_provider.dart';
import 'package:flutter_mini_games/src/core/widget/screen/screen.dart';
import 'package:flutter_mini_games/src/game/quickdraw/game/logic/quickdraw_game_controller.dart';
import 'package:flutter_mini_games/src/game/quickdraw/style/quickdraw_theme.dart';
import 'package:flutter_mini_games/src/game/quickdraw/widget/quickdraw_half.dart';

class QuickdrawScreen extends StatelessWidget {
  /// How to play, shown while the players get ready
  static const rules = [
    GameHowToPlayItem(icon: Icons.hourglass_top, text: 'Wait until your half shows GO'),
    GameHowToPlayItem(icon: Icons.bolt, text: 'First to tap after GO wins the round'),
    GameHowToPlayItem(icon: Icons.front_hand, text: 'Tapping before GO loses the round'),
  ];

  final CoreGameTheme? coreTheme;
  final GameThemeOverride<QuickdrawTheme>? theme;

  const QuickdrawScreen({
    this.coreTheme,
    this.theme,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GameControllerProvider(
      create: QuickdrawGameController.new,
      coreTheme: coreTheme,
      theme: (core) {
        final defaults = QuickdrawTheme.fromCore(core);
        return theme?.call(defaults) ?? defaults;
      },
      builder: (context, controller, theme, coreTheme) => FlutterMiniGamesScreen(
        title: 'Quickdraw',
        padding: EdgeInsets.zero,
        child: GameLoop(
          controller: controller,
          child: DuelLayout(
            center: ColoredBox(
              color: theme.colors.divider,
              child: SizedBox(height: theme.dimens.dividerThickness),
            ),
            side: (context, player) => Stack(
              fit: StackFit.expand,
              children: [
                DuelTapArea(
                  onTap: () => controller.onTap(player),
                  child: QuickdrawHalf(controller: controller, player: player),
                ),
                DuelPhaseOverlay(
                  controller: controller,
                  player: player,
                  rules: rules,
                  roundMessage: _roundMessage(controller, player),
                  finishMessage: _finishMessage(controller, player),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Best reaction time of [player] over the match
  static String _finishMessage(QuickdrawGameController controller, DuelPlayer player) {
    final best = controller.bestReactionMs(player);
    return best == null ? 'Your best: –' : 'Your best: $best ms';
  }

  /// Reaction time or "Too early!" of the last round, from the point of view of [player]
  static String? _roundMessage(QuickdrawGameController controller, DuelPlayer player) {
    final early = controller.earlyPlayer;
    if (early != null) return early == player ? 'Too early!' : '${early.label} was too early';
    final winner = controller.roundWinner;
    final ms = controller.roundReactionMs;
    if (winner == null || ms == null) return null;
    return winner == player ? 'Your reaction: $ms ms' : '${winner.label} reacted in $ms ms';
  }
}
