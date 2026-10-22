import 'package:flutter/material.dart';
import 'package:flutter_mini_games/flutter_mini_games.dart';
import 'package:flutter_mini_games_example/src/router.dart';
import 'package:impaktfull_ui/impaktfull_ui.dart';

void main() {
  runApp(
    // Optional: shared theme, score store and result callback for all games
    FlutterMiniGames(
      onGameFinished: (result) => debugPrint('Game finished: ${result.toJson()}'),
      child: const ImpaktfullUiApp(
        title: 'Flutter Mini Games',
        onGenerateRoute: onGenerateRoute,
      ),
    ),
  );
}
