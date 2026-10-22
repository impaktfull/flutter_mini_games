import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/model/data/flutter_mini_game_builder.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/game/flip/game/logic/flip_game_controller.dart';
import 'package:flutter_mini_games/src/game/flip/screen/flip_screen.dart';
import 'package:flutter_mini_games/src/game/flip/style/flip_theme.dart';

class FlipGameBuilder extends FlutterMiniGameBuilder {
  @override
  String get id => FlipGameController.id;

  @override
  bool get isMultiPlayer => true;

  /// Overrides the core theme of `FlutterMiniGames` for this game
  final CoreGameTheme? coreTheme;

  /// Tweaks the default theme, e.g. `(theme) => theme.copyWith(...)`
  final GameThemeOverride<FlipTheme>? theme;

  const FlipGameBuilder({
    super.name = 'Flip',
    super.description = 'Reversi for two players: outflank and flip the discs of your opponent',
    this.coreTheme,
    this.theme,
  });

  @override
  Widget build(BuildContext context) => FlipScreen(
    coreTheme: coreTheme,
    theme: theme,
  );
}
