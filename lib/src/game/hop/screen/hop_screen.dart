import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/core/widget/components/button.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_stats_bar.dart';
import 'package:flutter_mini_games/src/core/widget/components/how_to_play.dart';
import 'package:flutter_mini_games/src/core/widget/provider/game_controller_provider.dart';
import 'package:flutter_mini_games/src/core/widget/screen/game_screen_layout.dart';
import 'package:flutter_mini_games/src/core/widget/screen/screen.dart';
import 'package:flutter_mini_games/src/game/hop/game/logic/hop_game_controller.dart';
import 'package:flutter_mini_games/src/game/hop/screen/hop_header.dart';
import 'package:flutter_mini_games/src/game/hop/style/hop_theme.dart';
import 'package:flutter_mini_games/src/game/hop/widget/hop_playfield.dart';

class HopScreen extends StatelessWidget {
  final CoreGameTheme? coreTheme;
  final GameThemeOverride<HopTheme>? theme;

  const HopScreen({
    this.coreTheme,
    this.theme,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GameControllerProvider(
      create: HopGameController.new,
      coreTheme: coreTheme,
      theme: (core) {
        final defaults = HopTheme.fromCore(core);
        return theme?.call(defaults) ?? defaults;
      },
      builder: (context, controller, theme, coreTheme) => FlutterMiniGamesScreen(
        title: 'Hop',
        child: GameScreenLayout(
          header: Column(
            spacing: 8,
            children: [
              HopHeader(controller: controller),
              GameStatsBar(controller: controller),
            ],
          ),
          boardAspectRatio: HopPlayfield.aspectRatio,
          board: HopPlayfield(controller: controller),
          controls: controller.isGameOver
              ? GameButton(onTap: controller.resetGame, icon: Icons.replay, label: 'Play again')
              : GameButton(onTap: controller.isReady ? null : controller.resetGame, icon: Icons.refresh, label: 'Restart'),
          footer: const GameHowToPlay(
            items: [
              GameHowToPlayItem(icon: Icons.touch_app, text: 'Hold left or right\nto steer'),
              GameHowToPlayItem(icon: Icons.arrow_upward, text: 'Bounce on platforms\nand climb high'),
            ],
          ),
        ),
      ),
    );
  }
}
