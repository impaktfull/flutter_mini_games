import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/model/data/flutter_mini_game_builder.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/game/puck/game/logic/puck_game_controller.dart';
import 'package:flutter_mini_games/src/game/puck/screen/puck_screen.dart';
import 'package:flutter_mini_games/src/game/puck/style/puck_theme.dart';

class PuckGameBuilder extends FlutterMiniGameBuilder {
  @override
  String get id => PuckGameController.id;

  @override
  bool get isMultiPlayer => true;

  /// Overrides the core theme of `FlutterMiniGames` for this game
  final CoreGameTheme? coreTheme;

  /// Tweaks the default theme, e.g. `(theme) => theme.copyWith(...)`
  final GameThemeOverride<PuckTheme>? theme;

  /// Goals a player needs to win the match
  final int goalsToWin;

  const PuckGameBuilder({
    super.name = 'Puck',
    super.description = 'Air hockey for two: shoot the puck into the other goal',
    this.coreTheme,
    this.theme,
    this.goalsToWin = 5,
  });

  @override
  Widget build(BuildContext context) => PuckScreen(
    coreTheme: coreTheme,
    theme: theme,
    goalsToWin: goalsToWin,
  );
}
