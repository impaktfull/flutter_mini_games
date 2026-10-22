import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/core/widget/provider/game_controller_provider.dart';
import 'package:flutter_mini_games/src/core/widget/screen/screen.dart';
import 'package:flutter_mini_games/src/game/puck/game/logic/puck_game_controller.dart';
import 'package:flutter_mini_games/src/game/puck/style/puck_theme.dart';
import 'package:flutter_mini_games/src/game/puck/widget/puck_table.dart';

class PuckScreen extends StatelessWidget {
  final CoreGameTheme? coreTheme;
  final GameThemeOverride<PuckTheme>? theme;
  final int goalsToWin;

  const PuckScreen({
    this.coreTheme,
    this.theme,
    this.goalsToWin = 5,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GameControllerProvider(
      create: () => PuckGameController(goalsToWin: goalsToWin),
      coreTheme: coreTheme,
      theme: (core) {
        final defaults = PuckTheme.fromCore(core);
        return theme?.call(defaults) ?? defaults;
      },
      // The table fills the screen, the match flow is shown on each player's half
      builder: (context, controller, theme, coreTheme) => FlutterMiniGamesScreen(
        title: 'Puck',
        child: PuckTable(controller: controller),
      ),
    );
  }
}
