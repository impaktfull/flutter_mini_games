import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/core/widget/components/button.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_stats_bar.dart';
import 'package:flutter_mini_games/src/core/widget/components/how_to_play.dart';
import 'package:flutter_mini_games/src/core/widget/provider/game_controller_provider.dart';
import 'package:flutter_mini_games/src/core/widget/screen/game_screen_layout.dart';
import 'package:flutter_mini_games/src/core/widget/screen/screen.dart';
import 'package:flutter_mini_games/src/game/echo/game/logic/echo_game_controller.dart';
import 'package:flutter_mini_games/src/game/echo/screen/echo_header.dart';
import 'package:flutter_mini_games/src/game/echo/style/echo_theme.dart';
import 'package:flutter_mini_games/src/game/echo/widget/echo_board.dart';

class EchoScreen extends StatelessWidget {
  final CoreGameTheme? coreTheme;
  final GameThemeOverride<EchoTheme>? theme;

  const EchoScreen({
    this.coreTheme,
    this.theme,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GameControllerProvider(
      create: EchoGameController.new,
      coreTheme: coreTheme,
      theme: (core) {
        final defaults = EchoTheme.fromCore(core);
        return theme?.call(defaults) ?? defaults;
      },
      builder: (context, controller, theme, coreTheme) => FlutterMiniGamesScreen(
        title: 'Echo',
        child: GameScreenLayout(
          header: Column(
            spacing: 8,
            children: [
              EchoHeader(controller: controller),
              GameStatsBar(controller: controller),
            ],
          ),
          board: EchoBoard(controller: controller),
          controls: _buildControls(controller),
          footer: const GameHowToPlay(
            items: [
              GameHowToPlayItem(icon: Icons.visibility, text: 'Watch the pads\nlight up'),
              GameHowToPlayItem(icon: Icons.touch_app, text: 'Tap them in the\nsame order'),
              GameHowToPlayItem(icon: Icons.trending_up, text: 'One more pad\nevery round'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControls(EchoGameController controller) {
    if (controller.isReady) {
      return GameButton(onTap: controller.start, icon: Icons.play_arrow, label: 'Start');
    }
    if (controller.isGameOver) {
      return GameButton(onTap: controller.resetGame, icon: Icons.replay, label: 'Play again');
    }
    return GameButton(onTap: controller.resetGame, icon: Icons.refresh, label: 'Restart');
  }
}
