import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';

class GameThemeBuilder<T extends GameTheme> extends StatelessWidget {
  final Widget Function(BuildContext context, T theme) builder;

  const GameThemeBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = GameTheme.of<T>(context);
    return builder(context, theme);
  }
}
