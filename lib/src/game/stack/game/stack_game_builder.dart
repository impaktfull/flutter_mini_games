import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/model/data/flutter_mini_game_builder.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/game/stack/game/logic/stack_game_controller.dart';
import 'package:flutter_mini_games/src/game/stack/screen/stack_screen.dart';
import 'package:flutter_mini_games/src/game/stack/style/stack_theme.dart';

class StackGameBuilder extends FlutterMiniGameBuilder {
  @override
  String get id => StackGameController.id;

  @override
  bool get isMultiPlayer => false;

  /// Overrides the core theme of `FlutterMiniGames` for this game
  final CoreGameTheme? coreTheme;

  /// Tweaks the default theme, e.g. `(theme) => theme.copyWith(...)`
  final GameThemeOverride<StackTheme>? theme;

  const StackGameBuilder({
    super.name = 'Stack',
    super.description = 'Drop the sliding blocks to build the highest tower',
    this.coreTheme,
    this.theme,
  });

  @override
  Widget build(BuildContext context) => StackScreen(coreTheme: coreTheme, theme: theme);
}
