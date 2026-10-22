import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/model/data/flutter_mini_game_builder.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';
import 'package:flutter_mini_games/src/core/score/game_score_store.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';

/// Optional configuration for all games. Place it above your `MaterialApp`:
///
/// ```dart
/// FlutterMiniGames(
///   theme: CoreGameTheme.light(),
///   darkTheme: CoreGameTheme.dark(),
///   scoreStore: MyPersistentScoreStore(),
///   onGameFinished: (result) => analytics.log(result.toJson()),
///   child: MaterialApp(...),
/// )
/// ```
///
/// Without it, games use [CoreGameTheme.light] / [CoreGameTheme.dark] (following the
/// app brightness) and [FlutterMiniGames.defaultScoreStore].
class FlutterMiniGames extends InheritedWidget {
  /// Store used when no [scoreStore] is configured. Results are kept in memory.
  static final GameScoreStore defaultScoreStore = InMemoryGameScoreStore();

  final CoreGameTheme? theme;

  /// Used when the app brightness is dark. Falls back to [theme], then to [CoreGameTheme.dark].
  final CoreGameTheme? darkTheme;
  final GameScoreStore? scoreStore;

  /// Called for every finished or abandoned game, after it is saved in the score store
  final ValueChanged<GameResult>? onGameFinished;

  const FlutterMiniGames({
    required super.child,
    this.theme,
    this.darkTheme,
    this.scoreStore,
    this.onGameFinished,
    super.key,
  });

  static FlutterMiniGames? maybeOf(BuildContext context) => context.dependOnInheritedWidgetOfExactType<FlutterMiniGames>();

  /// Core theme for the current brightness
  static CoreGameTheme coreThemeOf(BuildContext context) {
    final config = maybeOf(context);
    if (Theme.of(context).brightness == Brightness.dark) {
      return config?.darkTheme ?? config?.theme ?? CoreGameTheme.dark();
    }
    return config?.theme ?? CoreGameTheme.light();
  }

  static GameScoreStore scoreStoreOf(BuildContext context) => maybeOf(context)?.scoreStore ?? defaultScoreStore;

  /// Opens [game] full screen and returns the result of the last game played in it.
  ///
  /// Every result (also abandoned games) is saved in the score store and passed to
  /// [onGameFinished].
  static Future<GameResult?> launch(BuildContext context, FlutterMiniGameBuilder game) async {
    GameResult? lastResult;
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (context) => GameResultListener(
          onResult: (result) => lastResult = result,
          child: game.build(context),
        ),
      ),
    );
    return lastResult;
  }

  /// Saves [result] and notifies the host app. Called by the game controllers.
  static ValueChanged<GameResult> resultReporterOf(BuildContext context) {
    // Resolve everything now: the controller may report after this context is unmounted
    final config = context.getInheritedWidgetOfExactType<FlutterMiniGames>();
    final store = config?.scoreStore ?? defaultScoreStore;
    final listener = context.getInheritedWidgetOfExactType<GameResultListener>();
    return (result) {
      store.save(result);
      config?.onGameFinished?.call(result);
      listener?.onResult(result);
    };
  }

  @override
  bool updateShouldNotify(FlutterMiniGames oldWidget) =>
      theme != oldWidget.theme || darkTheme != oldWidget.darkTheme || scoreStore != oldWidget.scoreStore || onGameFinished != oldWidget.onGameFinished;
}

/// Receives the results of the games below it
class GameResultListener extends InheritedWidget {
  final ValueChanged<GameResult> onResult;

  const GameResultListener({
    required this.onResult,
    required super.child,
    super.key,
  });

  @override
  bool updateShouldNotify(GameResultListener oldWidget) => false;
}
