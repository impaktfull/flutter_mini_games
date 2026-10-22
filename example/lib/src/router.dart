import 'package:flutter/material.dart';
import 'package:flutter_mini_games_example/src/screen/home_screen.dart';

/// `/` is the game list, `/<game id>` opens a game, so every game has its own link
/// (e.g. https://impaktfull.github.io/flutter_mini_games/#/snake)
Route<void> onGenerateRoute(RouteSettings settings) {
  final id = settings.name?.replaceFirst('/', '');
  for (final game in HomeScreen.games) {
    if (game.id == id) {
      return MaterialPageRoute(settings: settings, builder: game.build);
    }
  }
  return MaterialPageRoute(
    settings: const RouteSettings(name: '/'),
    builder: (context) => const HomeScreen(),
  );
}
