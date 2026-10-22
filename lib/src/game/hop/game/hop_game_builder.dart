import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/model/data/flutter_mini_game_builder.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/game/hop/game/logic/hop_game_controller.dart';
import 'package:flutter_mini_games/src/game/hop/screen/hop_screen.dart';
import 'package:flutter_mini_games/src/game/hop/style/hop_theme.dart';

class HopGameBuilder extends FlutterMiniGameBuilder {
  @override
  String get id => HopGameController.id;

  @override
  bool get isMultiPlayer => false;

  /// Overrides the core theme of `FlutterMiniGames` for this game
  final CoreGameTheme? coreTheme;

  /// Tweaks the default theme, e.g. `(theme) => theme.copyWith(...)`
  final GameThemeOverride<HopTheme>? theme;

  const HopGameBuilder({
    super.name = 'Hop',
    super.description = 'Bounce from platform to platform and climb as high as you can',
    this.coreTheme,
    this.theme,
  });

  @override
  Widget build(BuildContext context) => HopScreen(coreTheme: coreTheme, theme: theme);
}
