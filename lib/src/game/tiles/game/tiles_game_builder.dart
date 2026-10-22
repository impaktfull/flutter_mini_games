import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/model/data/flutter_mini_game_builder.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/game/tiles/game/logic/tiles_game_controller.dart';
import 'package:flutter_mini_games/src/game/tiles/screen/tiles_screen.dart';
import 'package:flutter_mini_games/src/game/tiles/style/tiles_theme.dart';

class TilesGameBuilder extends FlutterMiniGameBuilder {
  @override
  String get id => TilesGameController.id;

  @override
  bool get isMultiPlayer => false;

  /// Overrides the core theme of `FlutterMiniGames` for this game
  final CoreGameTheme? coreTheme;

  /// Tweaks the default theme, e.g. `(theme) => theme.copyWith(...)`
  final GameThemeOverride<TilesTheme>? theme;

  const TilesGameBuilder({
    super.name = 'Tiles',
    super.description = 'Tap the dark tile in every row before it scrolls away',
    this.coreTheme,
    this.theme,
  });

  @override
  Widget build(BuildContext context) => TilesScreen(coreTheme: coreTheme, theme: theme);
}
