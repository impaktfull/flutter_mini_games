import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_layout.dart';
import 'package:flutter_mini_games/src/core/duel/duel_phase_overlay.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/core/widget/components/how_to_play.dart';
import 'package:flutter_mini_games/src/core/widget/game_loop.dart';
import 'package:flutter_mini_games/src/core/widget/provider/game_controller_provider.dart';
import 'package:flutter_mini_games/src/core/widget/screen/screen.dart';
import 'package:flutter_mini_games/src/game/slap/game/logic/slap_game_controller.dart';
import 'package:flutter_mini_games/src/game/slap/game/model/slap_attack.dart';
import 'package:flutter_mini_games/src/game/slap/style/slap_theme.dart';
import 'package:flutter_mini_games/src/game/slap/widget/slap_side.dart';

class SlapScreen extends StatelessWidget {
  /// How to play, shown while the players get ready
  static const rules = [
    GameHowToPlayItem(icon: Icons.shield, text: 'Defend: hold your target, lift to dodge a slap'),
    GameHowToPlayItem(icon: Icons.sports_mma, text: 'Attack: slap before time runs out, or fake'),
    GameHowToPlayItem(icon: Icons.swap_vert, text: 'Lifting on a fake loses. Roles swap every round'),
  ];

  final CoreGameTheme? coreTheme;
  final GameThemeOverride<SlapTheme>? theme;

  const SlapScreen({
    this.coreTheme,
    this.theme,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GameControllerProvider(
      create: SlapGameController.new,
      coreTheme: coreTheme,
      theme: (core) {
        final defaults = SlapTheme.fromCore(core);
        return theme?.call(defaults) ?? defaults;
      },
      builder: (context, controller, theme, coreTheme) => FlutterMiniGamesScreen(
        title: 'Slap',
        child: GameLoop(
          controller: controller,
          child: DuelLayout(
            center: Padding(
              padding: EdgeInsets.symmetric(vertical: coreTheme.dimens.padding / 2),
              child: SizedBox(
                height: theme.dimens.dividerHeight,
                child: ColoredBox(color: theme.colors.divider),
              ),
            ),
            side: (context, player) => Stack(
              fit: StackFit.expand,
              children: [
                SlapSide(controller: controller, player: player),
                DuelPhaseOverlay(
                  controller: controller,
                  player: player,
                  rules: rules,
                  roundMessage: _roundMessage(controller, player),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Why the last round ended, from the point of view of [player]
  static String? _roundMessage(SlapGameController controller, DuelPlayer player) {
    final isAttacker = controller.attacker == player;
    return switch (controller.roundEnd) {
      null => null,
      SlapRoundEnd.dodged => isAttacker ? '${controller.defender.label} dodged your slap' : 'Dodged!',
      SlapRoundEnd.slapped => isAttacker ? 'Your slap landed!' : 'Slapped!',
      SlapRoundEnd.flinched => isAttacker ? '${controller.defender.label} fell for your fake' : 'Fooled by a fake!',
      SlapRoundEnd.tooSlow => isAttacker ? "Time's up! Slap faster" : "Time's up!",
    };
  }
}
