import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_layout.dart';
import 'package:flutter_mini_games/src/core/duel/duel_phase_overlay.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/core/widget/game_loop.dart';
import 'package:flutter_mini_games/src/core/widget/provider/game_controller_provider.dart';
import 'package:flutter_mini_games/src/core/widget/screen/screen.dart';
import 'package:flutter_mini_games/src/game/quickdraw/game/logic/quickdraw_game_controller.dart';
import 'package:flutter_mini_games/src/game/quickdraw/style/quickdraw_theme.dart';
import 'package:flutter_mini_games/src/game/quickdraw/widget/quickdraw_half.dart';
import 'package:flutter_mini_games/src/game/quickdraw/widget/quickdraw_result_banner.dart';

class QuickdrawScreen extends StatelessWidget {
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
                DuelPhaseOverlay(controller: controller, player: player),
                QuickdrawResultBanner(controller: controller, player: player),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
