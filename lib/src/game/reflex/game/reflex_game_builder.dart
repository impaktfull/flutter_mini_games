import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/model/data/flutter_mini_game_builder.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/game/reflex/game/logic/reflex_game_controller.dart';
import 'package:flutter_mini_games/src/game/reflex/screen/reflex_screen.dart';
import 'package:flutter_mini_games/src/game/reflex/style/reflex_theme.dart';

class ReflexGameBuilder extends FlutterMiniGameBuilder {
  @override
  String get id => ReflexGameController.id;

  @override
  bool get isMultiPlayer => false;

  /// Overrides the core theme of `FlutterMiniGames` for this game
  final CoreGameTheme? coreTheme;

  /// Tweaks the default theme, e.g. `(theme) => theme.copyWith(...)`
  final GameThemeOverride<ReflexTheme>? theme;

  const ReflexGameBuilder({
    super.name = 'Reflex',
    super.description = 'Tap as soon as the color changes and measure your reaction time',
    this.coreTheme,
    this.theme,
  });

  @override
  Widget build(BuildContext context) => ReflexScreen(coreTheme: coreTheme, theme: theme);
}
