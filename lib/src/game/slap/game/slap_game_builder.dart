import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/model/data/flutter_mini_game_builder.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/game/slap/game/logic/slap_game_controller.dart';
import 'package:flutter_mini_games/src/game/slap/screen/slap_screen.dart';
import 'package:flutter_mini_games/src/game/slap/style/slap_theme.dart';

class SlapGameBuilder extends FlutterMiniGameBuilder {
  @override
  String get id => SlapGameController.id;

  @override
  bool get isMultiPlayer => true;

  /// Overrides the core theme of `FlutterMiniGames` for this game
  final CoreGameTheme? coreTheme;

  /// Tweaks the default theme, e.g. `(theme) => theme.copyWith(...)`
  final GameThemeOverride<SlapTheme>? theme;

  const SlapGameBuilder({
    super.name = 'Slap',
    super.description = 'One player slaps, the other pulls their finger away in time',
    this.coreTheme,
    this.theme,
  });

  @override
  Widget build(BuildContext context) => SlapScreen(coreTheme: coreTheme, theme: theme);
}
