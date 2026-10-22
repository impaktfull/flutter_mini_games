import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/model/data/flutter_mini_game_builder.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/game/pairs/game/logic/pairs_game_controller.dart';
import 'package:flutter_mini_games/src/game/pairs/game/model/pairs_difficulty.dart';
import 'package:flutter_mini_games/src/game/pairs/screen/pairs_screen.dart';
import 'package:flutter_mini_games/src/game/pairs/style/pairs_theme.dart';

class PairsGameBuilder extends FlutterMiniGameBuilder {
  @override
  String get id => PairsGameController.id;

  @override
  bool get isMultiPlayer => false;

  /// Overrides the core theme of `FlutterMiniGames` for this game
  final CoreGameTheme? coreTheme;

  /// Tweaks the default theme, e.g. `(theme) => theme.copyWith(...)`
  final GameThemeOverride<PairsTheme>? theme;

  /// Board size of the first game, the player can switch in the game
  final PairsDifficulty difficulty;

  const PairsGameBuilder({
    super.name = 'Pairs',
    super.description = 'Flip two cards at a time and find all matching pairs',
    this.coreTheme,
    this.theme,
    this.difficulty = PairsDifficulty.easy,
  });

  @override
  Widget build(BuildContext context) => PairsScreen(
    coreTheme: coreTheme,
    theme: theme,
    difficulty: difficulty,
  );
}
