import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:provider/provider.dart';

class GameThemeProvider<T extends GameTheme> extends StatelessWidget {
  final T theme;
  final Widget Function(BuildContext context, T theme) builder;

  const GameThemeProvider({
    required this.theme,
    required this.builder,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Provider<T>(
      create: (context) => theme,
      child: builder(context, theme),
    );
  }
}
