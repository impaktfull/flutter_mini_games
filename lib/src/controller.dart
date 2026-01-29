import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/model/data/flutter_mini_game_builder.dart';

class FlutterMiniGamesController {
  Future<void> launchGameBuilder(
    BuildContext context,
    FlutterMiniGameBuilder gameBuilder,
  ) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    final widget = await gameBuilder.build(context);
    await navigator.push(MaterialPageRoute(builder: (context) => widget));
  }
}
