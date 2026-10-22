import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/model/data/flutter_mini_game_builder.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/game/breaker/game/logic/breaker_game_controller.dart';
import 'package:flutter_mini_games/src/game/breaker/screen/breaker_screen.dart';
import 'package:flutter_mini_games/src/game/breaker/style/breaker_theme.dart';

class BreakerGameBuilder extends FlutterMiniGameBuilder {
  @override
  String get id => BreakerGameController.id;

  @override
  bool get isMultiPlayer => false;

  /// Overrides the core theme of `FlutterMiniGames` for this game
  final CoreGameTheme? coreTheme;

  /// Tweaks the default theme, e.g. `(theme) => theme.copyWith(...)`
  final GameThemeOverride<BreakerTheme>? theme;

  const BreakerGameBuilder({
    super.name = 'Breaker',
    super.description = 'Bounce the ball off the paddle and break all the bricks',
    this.coreTheme,
    this.theme,
  });

  @override
  Widget build(BuildContext context) => BreakerScreen(coreTheme: coreTheme, theme: theme);
}
