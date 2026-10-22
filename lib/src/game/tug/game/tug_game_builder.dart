import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/model/data/flutter_mini_game_builder.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/game/tug/game/logic/tug_game_controller.dart';
import 'package:flutter_mini_games/src/game/tug/screen/tug_screen.dart';
import 'package:flutter_mini_games/src/game/tug/style/tug_theme.dart';

class TugGameBuilder extends FlutterMiniGameBuilder {
  @override
  String get id => TugGameController.id;

  @override
  bool get isMultiPlayer => true;

  /// Overrides the core theme of `FlutterMiniGames` for this game
  final CoreGameTheme? coreTheme;

  /// Tweaks the default theme, e.g. `(theme) => theme.copyWith(...)`
  final GameThemeOverride<TugTheme>? theme;

  const TugGameBuilder({
    super.name = 'Tug',
    super.description = 'Tug of war: mash your half to pull the rope to your side',
    this.coreTheme,
    this.theme,
  });

  @override
  Widget build(BuildContext context) => TugScreen(coreTheme: coreTheme, theme: theme);
}
