import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/model/data/flutter_mini_game_builder.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/game/four_up/game/logic/four_up_game_controller.dart';
import 'package:flutter_mini_games/src/game/four_up/screen/four_up_screen.dart';
import 'package:flutter_mini_games/src/game/four_up/style/four_up_theme.dart';

class FourUpGameBuilder extends FlutterMiniGameBuilder {
  @override
  String get id => FourUpGameController.id;

  @override
  bool get isMultiPlayer => true;

  /// Overrides the core theme of `FlutterMiniGames` for this game
  final CoreGameTheme? coreTheme;

  /// Tweaks the default theme, e.g. `(theme) => theme.copyWith(...)`
  final GameThemeOverride<FourUpTheme>? theme;

  const FourUpGameBuilder({
    super.name = 'Four Up',
    super.description = 'Drop your discs and get four in a row, for two players',
    this.coreTheme,
    this.theme,
  });

  @override
  Widget build(BuildContext context) => FourUpScreen(
    coreTheme: coreTheme,
    theme: theme,
  );
}
