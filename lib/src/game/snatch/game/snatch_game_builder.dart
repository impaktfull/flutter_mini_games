import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/model/data/flutter_mini_game_builder.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/game/snatch/game/logic/snatch_game_controller.dart';
import 'package:flutter_mini_games/src/game/snatch/screen/snatch_screen.dart';
import 'package:flutter_mini_games/src/game/snatch/style/snatch_theme.dart';

class SnatchGameBuilder extends FlutterMiniGameBuilder {
  @override
  String get id => SnatchGameController.id;

  @override
  bool get isMultiPlayer => true;

  /// Overrides the core theme of `FlutterMiniGames` for this game
  final CoreGameTheme? coreTheme;

  /// Tweaks the default theme, e.g. `(theme) => theme.copyWith(...)`
  final GameThemeOverride<SnatchTheme>? theme;

  const SnatchGameBuilder({
    super.name = 'Snatch',
    super.description = 'Two players: be the first to tap the symbol shown in the middle',
    this.coreTheme,
    this.theme,
  });

  @override
  Widget build(BuildContext context) => SnatchScreen(coreTheme: coreTheme, theme: theme);
}
