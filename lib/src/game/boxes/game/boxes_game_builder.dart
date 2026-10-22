import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/model/data/flutter_mini_game_builder.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/game/boxes/game/logic/boxes_game_controller.dart';
import 'package:flutter_mini_games/src/game/boxes/screen/boxes_screen.dart';
import 'package:flutter_mini_games/src/game/boxes/style/boxes_theme.dart';

class BoxesGameBuilder extends FlutterMiniGameBuilder {
  @override
  String get id => BoxesGameController.id;

  @override
  bool get isMultiPlayer => true;

  /// Overrides the core theme of `FlutterMiniGames` for this game
  final CoreGameTheme? coreTheme;

  /// Tweaks the default theme, e.g. `(theme) => theme.copyWith(...)`
  final GameThemeOverride<BoxesTheme>? theme;

  const BoxesGameBuilder({
    super.name = 'Boxes',
    super.description = 'Dots and boxes for two players: close a box to claim it',
    this.coreTheme,
    this.theme,
  });

  @override
  Widget build(BuildContext context) => BoxesScreen(
    coreTheme: coreTheme,
    theme: theme,
  );
}
