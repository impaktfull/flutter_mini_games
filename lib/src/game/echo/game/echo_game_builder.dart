import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/model/data/flutter_mini_game_builder.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/game/echo/game/logic/echo_game_controller.dart';
import 'package:flutter_mini_games/src/game/echo/screen/echo_screen.dart';
import 'package:flutter_mini_games/src/game/echo/style/echo_theme.dart';

class EchoGameBuilder extends FlutterMiniGameBuilder {
  @override
  String get id => EchoGameController.id;

  @override
  bool get isMultiPlayer => false;

  /// Overrides the core theme of `FlutterMiniGames` for this game
  final CoreGameTheme? coreTheme;

  /// Tweaks the default theme, e.g. `(theme) => theme.copyWith(...)`
  final GameThemeOverride<EchoTheme>? theme;

  const EchoGameBuilder({
    super.name = 'Echo',
    super.description = 'Repeat the growing sequence of flashing pads',
    this.coreTheme,
    this.theme,
  });

  @override
  Widget build(BuildContext context) => EchoScreen(coreTheme: coreTheme, theme: theme);
}
