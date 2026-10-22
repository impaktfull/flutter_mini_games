import 'package:flutter/material.dart';
import 'package:flutter_mini_games_example/src/router.dart';
import 'package:flutter_mini_games_example/src/screen/home_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every game has a route', () {
    for (final game in HomeScreen.games) {
      final route = onGenerateRoute(RouteSettings(name: '/${game.id}')) as MaterialPageRoute<void>;
      expect(route.settings.name, equals('/${game.id}'));
    }
  });

  test('unknown routes show the game list', () {
    final route = onGenerateRoute(const RouteSettings(name: '/unknown')) as MaterialPageRoute<void>;
    expect(route.settings.name, equals('/'));
  });

  test('game ids are unique', () {
    final ids = HomeScreen.games.map((game) => game.id).toList();
    expect(ids.toSet(), hasLength(ids.length));
  });
}
