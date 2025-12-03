import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/core/widget/provider/game_theme_provider.dart';
import 'package:provider/provider.dart';

class GameControllerProvider<T extends GameController, E extends GameTheme> extends StatelessWidget {
  final T controller;
  final E theme;
  final Widget Function(BuildContext context, T controller, E theme) builder;

  const GameControllerProvider({
    required this.controller,
    required this.theme,
    required this.builder,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<T>(
      create: (context) => controller,
      child: Consumer<T>(
        builder: (context, controller, child) => GameThemeProvider(
          theme: theme,
          builder: (context, theme) => builder(context, controller, theme),
        ),
      ),
    );
  }
}
