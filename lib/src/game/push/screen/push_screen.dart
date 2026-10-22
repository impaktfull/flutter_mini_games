import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/core/widget/provider/game_controller_provider.dart';
import 'package:flutter_mini_games/src/core/widget/screen/screen.dart';
import 'package:flutter_mini_games/src/game/push/game/logic/push_game_controller.dart';
import 'package:flutter_mini_games/src/game/push/style/push_theme.dart';
import 'package:flutter_mini_games/src/game/push/widget/push_arena.dart';

class PushScreen extends StatelessWidget {
  final CoreGameTheme? coreTheme;
  final GameThemeOverride<PushTheme>? theme;

  const PushScreen({
    this.coreTheme,
    this.theme,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GameControllerProvider(
      create: PushGameController.new,
      coreTheme: coreTheme,
      theme: (core) {
        final defaults = PushTheme.fromCore(core);
        return theme?.call(defaults) ?? defaults;
      },
      builder: (context, controller, theme, coreTheme) => FlutterMiniGamesScreen(
        title: 'Push',
        padding: EdgeInsets.zero,
        child: PushArena(controller: controller),
      ),
    );
  }
}
