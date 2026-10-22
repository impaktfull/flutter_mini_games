import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_layout.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/core/widget/game_loop.dart';
import 'package:flutter_mini_games/src/core/widget/provider/game_controller_provider.dart';
import 'package:flutter_mini_games/src/core/widget/screen/screen.dart';
import 'package:flutter_mini_games/src/game/tug/game/logic/tug_game_controller.dart';
import 'package:flutter_mini_games/src/game/tug/style/tug_theme.dart';
import 'package:flutter_mini_games/src/game/tug/widget/tug_rope.dart';
import 'package:flutter_mini_games/src/game/tug/widget/tug_side.dart';

class TugScreen extends StatelessWidget {
  final CoreGameTheme? coreTheme;
  final GameThemeOverride<TugTheme>? theme;

  const TugScreen({
    this.coreTheme,
    this.theme,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GameControllerProvider(
      create: TugGameController.new,
      coreTheme: coreTheme,
      theme: (core) {
        final defaults = TugTheme.fromCore(core);
        return theme?.call(defaults) ?? defaults;
      },
      builder: (context, controller, theme, coreTheme) => FlutterMiniGamesScreen(
        title: 'Tug',
        // Both halves fill the screen up to the edges
        padding: EdgeInsets.zero,
        child: GameLoop(
          controller: controller,
          child: LayoutBuilder(
            builder: (context, constraints) => DuelLayout(
              side: (context, player) => TugSide(controller: controller, player: player),
              center: SizedBox(
                height: constraints.maxHeight * theme.dimens.ropeLengthFraction,
                child: ColoredBox(
                  color: coreTheme.colors.background,
                  child: TugRope(controller: controller),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
