import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/core/widget/provider/game_theme_provider.dart';
import 'package:flutter_mini_games/src/flutter_mini_games.dart';
import 'package:provider/provider.dart';

/// Provides the controller, the core theme and the game theme to a game screen
/// and reports the results of the controller to the host app.
class GameControllerProvider<T extends GameController, E extends GameTheme> extends StatelessWidget {
  final T Function() create;

  /// Overrides the core theme of [FlutterMiniGames] for this game
  final CoreGameTheme? coreTheme;

  /// Builds the game theme from the core theme
  final E Function(CoreGameTheme coreTheme) theme;
  final Widget Function(
    BuildContext context,
    T controller,
    E theme,
    CoreGameTheme coreTheme,
  )
  builder;

  const GameControllerProvider({
    required this.create,
    required this.theme,
    required this.builder,
    this.coreTheme,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final core = coreTheme ?? FlutterMiniGames.coreThemeOf(context);
    return ChangeNotifierProvider<T>(
      create: (context) => create()..resultListener = FlutterMiniGames.resultReporterOf(context),
      child: GameThemeProvider<CoreGameTheme>(
        theme: core,
        builder: (context, core) => GameThemeProvider<E>(
          theme: theme(core),
          builder: (context, theme) => Consumer<T>(
            builder: (context, controller, child) => builder(context, controller, theme, core),
          ),
        ),
      ),
    );
  }
}
