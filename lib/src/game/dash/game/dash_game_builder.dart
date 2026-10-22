import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/model/data/flutter_mini_game_builder.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/game/dash/game/logic/dash_game_controller.dart';
import 'package:flutter_mini_games/src/game/dash/screen/dash_screen.dart';
import 'package:flutter_mini_games/src/game/dash/style/dash_theme.dart';

class DashGameBuilder extends FlutterMiniGameBuilder {
  @override
  String get id => DashGameController.id;

  @override
  bool get isMultiPlayer => false;

  /// Overrides the core theme of `FlutterMiniGames` for this game
  final CoreGameTheme? coreTheme;

  /// Tweaks the default theme, e.g. `(theme) => theme.copyWith(...)`
  final GameThemeOverride<DashTheme>? theme;

  const DashGameBuilder({
    super.name = 'Dash',
    super.description = 'Run as far as you can: jump over blocks and duck under flyers',
    this.coreTheme,
    this.theme,
  });

  @override
  Widget build(BuildContext context) => DashScreen(coreTheme: coreTheme, theme: theme);
}
