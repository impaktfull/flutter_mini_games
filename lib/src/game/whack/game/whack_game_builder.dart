import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/model/data/flutter_mini_game_builder.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/game/whack/game/logic/whack_game_controller.dart';
import 'package:flutter_mini_games/src/game/whack/screen/whack_screen.dart';
import 'package:flutter_mini_games/src/game/whack/style/whack_theme.dart';

class WhackGameBuilder extends FlutterMiniGameBuilder {
  @override
  String get id => WhackGameController.id;

  @override
  bool get isMultiPlayer => false;

  /// Overrides the core theme of `FlutterMiniGames` for this game
  final CoreGameTheme? coreTheme;

  /// Tweaks the default theme, e.g. `(theme) => theme.copyWith(...)`
  final GameThemeOverride<WhackTheme>? theme;

  const WhackGameBuilder({
    super.name = 'Whack',
    super.description = 'Tap the critters before they hide, skip the spiky decoys',
    this.coreTheme,
    this.theme,
  });

  @override
  Widget build(BuildContext context) => WhackScreen(coreTheme: coreTheme, theme: theme);
}
