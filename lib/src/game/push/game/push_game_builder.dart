import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/model/data/flutter_mini_game_builder.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/game/push/game/logic/push_game_controller.dart';
import 'package:flutter_mini_games/src/game/push/screen/push_screen.dart';
import 'package:flutter_mini_games/src/game/push/style/push_theme.dart';

class PushGameBuilder extends FlutterMiniGameBuilder {
  @override
  String get id => PushGameController.id;

  @override
  bool get isMultiPlayer => true;

  /// Overrides the core theme of `FlutterMiniGames` for this game
  final CoreGameTheme? coreTheme;

  /// Tweaks the default theme, e.g. `(theme) => theme.copyWith(...)`
  final GameThemeOverride<PushTheme>? theme;

  const PushGameBuilder({
    super.name = 'Push',
    super.description = 'Sumo ring for two players: tap to push the other disc out of the shrinking ring',
    this.coreTheme,
    this.theme,
  });

  @override
  Widget build(BuildContext context) => PushScreen(
    coreTheme: coreTheme,
    theme: theme,
  );
}
