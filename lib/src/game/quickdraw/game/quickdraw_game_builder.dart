import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/model/data/flutter_mini_game_builder.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/game/quickdraw/game/logic/quickdraw_game_controller.dart';
import 'package:flutter_mini_games/src/game/quickdraw/screen/quickdraw_screen.dart';
import 'package:flutter_mini_games/src/game/quickdraw/style/quickdraw_theme.dart';

class QuickdrawGameBuilder extends FlutterMiniGameBuilder {
  @override
  String get id => QuickdrawGameController.id;

  @override
  bool get isMultiPlayer => true;

  /// Overrides the core theme of `FlutterMiniGames` for this game
  final CoreGameTheme? coreTheme;

  /// Tweaks the default theme, e.g. `(theme) => theme.copyWith(...)`
  final GameThemeOverride<QuickdrawTheme>? theme;

  const QuickdrawGameBuilder({
    super.name = 'Quickdraw',
    super.description = 'Wait for the signal, then tap your half before your opponent',
    this.coreTheme,
    this.theme,
  });

  @override
  Widget build(BuildContext context) => QuickdrawScreen(coreTheme: coreTheme, theme: theme);
}
