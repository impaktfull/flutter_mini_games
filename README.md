# flutter_mini_games

A Flutter package that makes it easy to embed casual mini games into your app, with a shared scores system and theming that matches your app.

## Games

| Game | Builder | Players |
|---|---|---|
| Tic Tac Toe | `TicTacToeGameBuilder` | 2 |
| Trail: draw one trail through every cell, passing the numbered checkpoints in order | `TrailGameBuilder` | 1 |
| Sudoku: fill the 9x9 grid so every row, column and box contains 1 to 9 | `SudokuGameBuilder` | 1 |
| Stack: drop the sliding blocks to build the highest tower | `StackGameBuilder` | 1 |
| Dash: endless runner, jump over blocks and duck under flyers | `DashGameBuilder` | 1 |
| Flit: tap to flap and fly through the gaps between the columns | `FlitGameBuilder` | 1 |
| Hop: bounce from platform to platform and climb as high as you can | `HopGameBuilder` | 1 |
| Minesweeper: reveal every safe cell without hitting a mine | `MinesweeperGameBuilder` | 1 |
| Snake: eat the food to grow, without hitting the walls or yourself | `SnakeGameBuilder` | 1 |
| 2048: slide the tiles and merge equal numbers until you reach 2048 | `TwentyFortyEightGameBuilder` | 1 |
| Code: crack the hidden code of 4 symbols in 8 tries | `CodeGameBuilder` | 1 |

Only the games you reference are compiled into your app.

## Getting started

```yaml
dependencies:
  flutter_mini_games: ^0.0.1
```

Requires Flutter 3.32 or newer.

## Usage

Launch a game from anywhere:

```dart
import 'package:flutter_mini_games/flutter_mini_games.dart';

final result = await FlutterMiniGames.launch(context, const TrailGameBuilder());
print(result?.score);
```

Using your own router? `game.build(context)` returns the game screen as a widget.

### Configuration (optional)

Wrap your app once to configure all games:

```dart
FlutterMiniGames(
  theme: CoreGameTheme.light(),          // or CoreGameTheme.fromMaterial(myThemeData)
  darkTheme: CoreGameTheme.dark(),
  scoreStore: MyPersistentScoreStore(),  // defaults to an in-memory store
  onGameFinished: (result) => analytics.log(result.toJson()),
  child: MaterialApp(...),
)
```

### Scores

Every game reports a `GameResult`: game id, outcome (`won`, `lost`, `draw`, `abandoned`), optional score, duration, moves and game-specific data. Results go to the score store and `onGameFinished`.

Persist results by implementing `GameScoreStore`:

```dart
class MyPersistentScoreStore extends GameScoreStore {
  @override
  Future<void> save(GameResult result) async => /* store result.toJson() */;

  @override
  Future<List<GameResult>> results(String gameId) async => /* read with GameResult.fromJson */;
}

final stats = await store.stats('trail'); // played, won, bestScore, fastestWin, ...
```

### Theming

All games derive their look from one `CoreGameTheme`. Every game theme has the same shape (`colors`, `textStyles`, `dimens`) and can be tweaked per game:

```dart
TrailGameBuilder(
  theme: (theme) => theme.copyWith(
    colors: theme.colors.copyWith(pathLine: Colors.teal),
  ),
)

TicTacToeGameBuilder(
  coreTheme: CoreGameTheme.dark(), // a different core theme for this game only
)
```

See the [`/example`](example/) app for a complete setup.

## Additional information

- Issues and feedback: [GitHub issue tracker](https://github.com/impaktfull/flutter_mini_games/issues)
- Licensed under the BSD 3-Clause License.
