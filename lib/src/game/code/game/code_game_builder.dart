import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/model/data/flutter_mini_game_builder.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/game/code/game/logic/code_game_controller.dart';
import 'package:flutter_mini_games/src/game/code/screen/code_screen.dart';
import 'package:flutter_mini_games/src/game/code/style/code_theme.dart';

class CodeGameBuilder extends FlutterMiniGameBuilder {
  @override
  String get id => CodeGameController.id;

  @override
  bool get isMultiPlayer => false;

  /// Overrides the core theme of `FlutterMiniGames` for this game
  final CoreGameTheme? coreTheme;

  /// Tweaks the default theme, e.g. `(theme) => theme.copyWith(...)`
  final GameThemeOverride<CodeTheme>? theme;

  /// Picks the hidden codes, e.g. a seeded `Random` for reproducible codes
  final Random? random;

  const CodeGameBuilder({
    super.name = 'Code',
    super.description = 'Crack the hidden code of 4 symbols in 8 tries',
    this.coreTheme,
    this.theme,
    this.random,
  });

  @override
  Widget build(BuildContext context) => CodeScreen(
    coreTheme: coreTheme,
    theme: theme,
    random: random,
  );
}
