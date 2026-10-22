import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/model/data/flutter_mini_game_builder.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/game/twenty_forty_eight/game/logic/twenty_forty_eight_game_controller.dart';
import 'package:flutter_mini_games/src/game/twenty_forty_eight/screen/twenty_forty_eight_screen.dart';
import 'package:flutter_mini_games/src/game/twenty_forty_eight/style/twenty_forty_eight_theme.dart';

class TwentyFortyEightGameBuilder extends FlutterMiniGameBuilder {
  @override
  String get id => TwentyFortyEightGameController.id;

  @override
  bool get isMultiPlayer => false;

  /// Overrides the core theme of `FlutterMiniGames` for this game
  final CoreGameTheme? coreTheme;

  /// Tweaks the default theme, e.g. `(theme) => theme.copyWith(...)`
  final GameThemeOverride<TwentyFortyEightTheme>? theme;

  const TwentyFortyEightGameBuilder({
    super.name = '2048',
    super.description = 'Slide the tiles and merge equal numbers until you reach 2048',
    this.coreTheme,
    this.theme,
  });

  @override
  Widget build(BuildContext context) => TwentyFortyEightScreen(coreTheme: coreTheme, theme: theme);
}
