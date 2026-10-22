import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_layout.dart';
import 'package:flutter_mini_games/src/core/duel/duel_phase_overlay.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/core/widget/game_loop.dart';
import 'package:flutter_mini_games/src/core/widget/provider/game_controller_provider.dart';
import 'package:flutter_mini_games/src/core/widget/screen/screen.dart';
import 'package:flutter_mini_games/src/game/slap/game/logic/slap_game_controller.dart';
import 'package:flutter_mini_games/src/game/slap/style/slap_theme.dart';
import 'package:flutter_mini_games/src/game/slap/widget/slap_side.dart';

class SlapScreen extends StatelessWidget {
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
                DuelPhaseOverlay(controller: controller, player: player),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
