import 'package:flutter/material.dart';
import 'package:flutter_mini_games/flutter_mini_games.dart';
import 'package:flutter_mini_games/src/game/tic_tac_toe/widget/tic_tac_toe_cell.dart';
import 'package:flutter_mini_games/src/game/trail/game/logic/trail_game_controller.dart';
import 'package:flutter_mini_games/src/game/trail/widget/trail_grid.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

const _tutorial = TrailGameBuilder(puzzles: [TrailPuzzles.tutorial]);
const _snakeSolution = [(0, 1), (0, 2), (1, 2), (1, 1), (1, 0), (2, 0), (2, 1), (2, 2)];

Widget _app({
  required Widget Function(BuildContext context) home,
  GameScoreStore? scoreStore,
  ValueChanged<GameResult>? onGameFinished,
  CoreGameTheme? theme,
  CoreGameTheme? darkTheme,
  Brightness brightness = Brightness.light,
}) => FlutterMiniGames(
  scoreStore: scoreStore,
  onGameFinished: onGameFinished,
  theme: theme,
  darkTheme: darkTheme,
  child: MaterialApp(
    theme: ThemeData(brightness: brightness),
    home: Builder(builder: home),
  ),
);

TrailGameController _trailController(WidgetTester tester) => Provider.of<TrailGameController>(tester.element(find.byType(TrailGrid)), listen: false);

void main() {
  setUp(() => TestWidgetsFlutterBinding.ensureInitialized());

  testWidgets('launch returns the result and reports it to the store and callback', (tester) async {
    // Small phone
    tester.view
      ..physicalSize = const Size(360, 1200)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final store = InMemoryGameScoreStore();
    final reported = <GameResult>[];
    late Future<GameResult?> launched;

    await tester.pumpWidget(
      _app(
        scoreStore: store,
        onGameFinished: reported.add,
        home: (context) => TextButton(
          onPressed: () => launched = FlutterMiniGames.launch(context, _tutorial),
          child: const Text('Play'),
        ),
      ),
    );
    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();

    final controller = _trailController(tester);
    for (final (row, col) in _snakeSolution) {
      controller.moveTo(row, col);
    }
    await tester.pump();
    expect(find.text('🎉 Puzzle Complete!'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    final result = await launched;
    expect(result?.gameId, equals('trail'));
    expect(result?.outcome, equals(GameOutcome.won));
    expect(reported.single, same(result));
    expect((await store.stats('trail')).won, equals(1));
  });

  testWidgets('leaving a game while playing saves an abandoned result', (tester) async {
    final store = InMemoryGameScoreStore();

    await tester.pumpWidget(
      _app(
        scoreStore: store,
        home: (context) => TextButton(
          onPressed: () => FlutterMiniGames.launch(context, _tutorial),
          child: const Text('Play'),
        ),
      ),
    );
    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();
    _trailController(tester).moveTo(0, 1);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect((await store.stats('trail')).abandoned, equals(1));
  });

  testWidgets('game themes derive from the configured core theme and can be overridden', (tester) async {
    final core = CoreGameTheme.light().copyWith(colors: CoreGameColors.light().copyWith(primary: Colors.green));
    final game = TrailGameBuilder(
      puzzles: const [TrailPuzzles.tutorial],
      theme: (theme) => theme.copyWith(colors: theme.colors.copyWith(pathLine: Colors.orange)),
    );

    await tester.pumpWidget(_app(theme: core, home: game.build));

    final theme = Provider.of<TrailTheme>(tester.element(find.byType(TrailGrid)), listen: false);
    expect(theme.colors.progress, equals(Colors.green));
    expect(theme.colors.pathLine, equals(Colors.orange));
  });

  testWidgets('uses the dark theme when the app is dark', (tester) async {
    await tester.pumpWidget(_app(brightness: Brightness.dark, home: _tutorial.build));

    final core = Provider.of<CoreGameTheme>(tester.element(find.byType(TrailGrid)), listen: false);
    expect(core.colors.background, equals(CoreGameColors.dark().background));
  });

  testWidgets('a core theme on the game builder wins over the app-wide one', (tester) async {
    final gameCore = CoreGameTheme.light().copyWith(colors: CoreGameColors.light().copyWith(secondary: Colors.red));

    await tester.pumpWidget(
      _app(
        theme: CoreGameTheme.dark(),
        home: TicTacToeGameBuilder(coreTheme: gameCore).build,
      ),
    );

    final theme = Provider.of<TicTacToeTheme>(tester.element(find.byType(TicTacToeCell).first), listen: false);
    expect(theme.colors.topPlayer, equals(Colors.red));
  });
}
