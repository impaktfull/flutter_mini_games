import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/model/data/flutter_mini_game_builder.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/game/flit/game/logic/flit_game_controller.dart';
import 'package:flutter_mini_games/src/game/flit/screen/flit_screen.dart';
import 'package:flutter_mini_games/src/game/flit/style/flit_theme.dart';

class FlitGameBuilder extends FlutterMiniGameBuilder {
  @override
  String get id => FlitGameController.id;

  @override
  bool get isMultiPlayer => false;

  /// Overrides the core theme of `FlutterMiniGames` for this game
  final CoreGameTheme? coreTheme;

  /// Tweaks the default theme, e.g. `(theme) => theme.copyWith(...)`
  final GameThemeOverride<FlitTheme>? theme;

  const FlitGameBuilder({
    super.name = 'Flit',
    super.description = 'Tap to flap and fly through the gaps between the columns',
    this.coreTheme,
    this.theme,
  });

  @override
  Widget build(BuildContext context) => FlitScreen(
    coreTheme: coreTheme,
    theme: theme,
  );
}
