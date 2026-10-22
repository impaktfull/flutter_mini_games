import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/model/data/flutter_mini_game_builder.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/game/switch/game/logic/switch_game_controller.dart';
import 'package:flutter_mini_games/src/game/switch/game/model/switch_difficulty.dart';
import 'package:flutter_mini_games/src/game/switch/game/model/switch_puzzle.dart';
import 'package:flutter_mini_games/src/game/switch/screen/switch_screen.dart';
import 'package:flutter_mini_games/src/game/switch/style/switch_theme.dart';

class SwitchGameBuilder extends FlutterMiniGameBuilder {
  @override
  String get id => SwitchGameController.id;

  @override
  bool get isMultiPlayer => false;

  /// Overrides the core theme of `FlutterMiniGames` for this game
  final CoreGameTheme? coreTheme;

  /// Tweaks the default theme, e.g. `(theme) => theme.copyWith(...)`
  final GameThemeOverride<SwitchGameTheme>? theme;

  /// Difficulty of the generated puzzles, the player can switch in the game
  final SwitchDifficulty difficulty;

  /// Custom puzzles played in order; puzzles are generated when null or empty
  final List<SwitchPuzzle>? puzzles;

  const SwitchGameBuilder({
    super.name = 'Switch',
    super.description = 'Turn off all the lights, a tap toggles a light and its neighbours',
    this.coreTheme,
    this.theme,
    this.difficulty = SwitchDifficulty.medium,
    this.puzzles,
  });

  @override
  Widget build(BuildContext context) => SwitchScreen(
    coreTheme: coreTheme,
    theme: theme,
    difficulty: difficulty,
    puzzles: puzzles,
  );
}
