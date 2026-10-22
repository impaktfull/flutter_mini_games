# Flutter Mini Games Library

This document provides guidance for AI assistants working on this codebase.

## Project Overview

A Flutter library providing reusable mini games. Each game follows a consistent architecture with controllers, themes, builders, and widgets.

## Principles

Every change must keep these four goals intact:

1. **Minimal game code in the host app.** A host only creates game builders and calls `FlutterMiniGames.launch(context, game)`. The optional `FlutterMiniGames` root widget configures theme, score store and `onGameFinished` for all games at once. Never require per-game setup in the host beyond the builder.
2. **Unused games are never shipped.** Dart removes games the host does not reference. Keep it that way:
   - Never add a list, registry, enum or picker that references all games inside the library.
   - Shared (core) code must never import anything from `lib/src/game/`.
   - Never declare assets or fonts in the package `pubspec.yaml`: they are always bundled. A game that needs assets or heavy dependencies gets its own package.
   - `tool/check_tree_shaking.sh` (runs on CI) builds one app per game and fails when another game is compiled in.
3. **One scores system for all games.** Games report results through `GameController` (`registerMove()`, `finish()`, `restartSession()`). Results go to the `GameScoreStore` and the host callback; never build game-specific score storage.
4. **Theming is easy and identical between games.** Every game theme has the same shape (see below) and is customised with `theme: (theme) => theme.copyWith(...)` on the builder.

## Architecture

### Directory Structure for Games

Each game lives under `lib/src/game/{game_name}/` with this structure:

```
lib/src/game/{game_name}/
├── game/
│   ├── logic/
│   │   └── {game}_game_controller.dart    # Game logic & state
│   ├── model/                              # (optional) Game-specific models
│   │   └── {game}_*.dart
│   └── {game}_game_builder.dart           # Builder implementing FlutterMiniGameBuilder
├── screen/
│   ├── {game}_screen.dart                 # Main screen widget
│   └── {game}_header.dart                 # Header showing game status
├── style/
│   └── {game}_theme.dart                  # Game-specific theme
└── widget/
    └── {game}_*.dart                      # Game-specific widgets
```

Shared code lives in `lib/src/core/` and `lib/src/flutter_mini_games.dart` (the `FlutterMiniGames` root widget).

### Core Patterns

#### 1. Game Controller

- Extends `GameController` (which extends `ChangeNotifier`) and passes a stable `static const id`
- Contains all game state as private fields with public getters
- Calls `registerMove()` for every move: it counts moves and starts the timer
- Calls `finish(outcome, score: ..., data: ...)` when the game ends: the result is stored and reported to the host
- Calls `restartSession()` in `resetGame()` / `nextPuzzle()`
- Calls `startSession()` to start the timer without counting a move (e.g. "Tap to start")
- Leaving a game while playing is reported as `GameOutcome.abandoned` automatically
- Calls `notifyListeners()` after state changes

```dart
import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';

class MyGameController extends GameController {
  static const id = 'my_game';

  MyGameController() : super(gameId: id);

  bool get isWon => result?.outcome == GameOutcome.won;

  void makeMove() {
    registerMove();
    if (_isSolved()) {
      finish(GameOutcome.won, score: 100);
    }
    notifyListeners();
  }

  void resetGame() {
    restartSession();
    notifyListeners();
  }
}
```

- Score: higher is better, `null` when the game has no score (e.g. multiplayer)
- Endless games (Snake, Flit, ...) finish with `GameOutcome.lost` and their score; the best score counts every non-abandoned result
- Multiplayer games put the winner in `data` (e.g. `{'winner': 'X'}`)

#### 2. Game Theme

Every game theme has exactly this shape:

- Extends `GameTheme`
- Fields `colors`, `textStyles`, `dimens` ({Game}Colors, {Game}TextStyles, {Game}Dimens)
- `factory {Game}Theme.fromCore(CoreGameTheme core)` derives all defaults from the core theme
- `copyWith` on the theme and on each of `colors`, `textStyles`, `dimens`
- Static `of(BuildContext context)` for retrieval
- **IMPORTANT**: Only use values from `CoreGameTheme` - no hardcoded colors
- Shared UI (screen, buttons, stats bar, how to play) uses `CoreGameTheme` directly; game themes only contain tokens for the game board

```dart
class MyGameTheme extends GameTheme {
  final MyGameColors colors;
  final MyGameTextStyles textStyles;
  final MyGameDimens dimens;

  static MyGameTheme of(BuildContext context) => GameTheme.of<MyGameTheme>(context);

  const MyGameTheme({required this.colors, required this.textStyles, required this.dimens});

  factory MyGameTheme.fromCore(CoreGameTheme core) => MyGameTheme(
    colors: MyGameColors(cell: core.colors.surface, highlight: core.colors.primary),
    textStyles: MyGameTextStyles(header: core.textStyles.title),
    dimens: MyGameDimens(cellRadius: core.dimens.radiusSmall),
  );

  MyGameTheme copyWith({MyGameColors? colors, MyGameTextStyles? textStyles, MyGameDimens? dimens}) => MyGameTheme(
    colors: colors ?? this.colors,
    textStyles: textStyles ?? this.textStyles,
    dimens: dimens ?? this.dimens,
  );
}
// + MyGameColors, MyGameTextStyles, MyGameDimens, each with copyWith
```

**CoreGameTheme** (`CoreGameTheme.light()`, `.dark()`, `.fromMaterial(ThemeData)`, `.fromColors(...)`, `copyWith`):

- Colors: `primary` / `onPrimary`, `secondary` / `onSecondary`, `background` (screen), `surface` (cells, panels), `text`, `textMuted`, `error` / `onError` (mistakes), `shadow` (use with alpha)
- Text styles: `title` (bold 24), `body` (16), `label` (bold 16), `caption` (12, muted)
- Dimens: `radiusLarge`, `radiusSmall`, `padding`

#### 3. Game Builder

- Extends `FlutterMiniGameBuilder`, `const` constructor
- Implements `id` (the controller's `id`), `isMultiPlayer` and a synchronous `build(BuildContext context)`
- Accepts optional `coreTheme` (overrides the app-wide one) and `theme` (`GameThemeOverride<{Game}Theme>`)

```dart
class MyGameBuilder extends FlutterMiniGameBuilder {
  @override
  String get id => MyGameController.id;

  @override
  bool get isMultiPlayer => false;

  final CoreGameTheme? coreTheme;
  final GameThemeOverride<MyGameTheme>? theme;

  const MyGameBuilder({
    super.name = 'My Game',
    super.description = 'Description of the game',
    this.coreTheme,
    this.theme,
  });

  @override
  Widget build(BuildContext context) => MyGameScreen(coreTheme: coreTheme, theme: theme);
}
```

#### 4. Game Screen

- Stateless widget wrapping its content in `GameControllerProvider`
- Uses `FlutterMiniGamesScreen` with a `GameScreenLayout` inside: `header` (game header + `GameStatsBar`), `board` (+ `boardAspectRatio`), `controls` (buttons, number pad) and `footer` (`GameHowToPlay`)
- `GameScreenLayout` gives the board the largest size that fits next to header and controls; the footer opens in a bottom sheet from a "How to play" button (it may only use the core theme). The page doesn't scroll, because a scroll view would take drags and swipes from the board. Never build your own screen column or scroll view
- Shows different buttons based on game state (e.g., "Next Puzzle" when won, "Reset" otherwise)
- Rows that can grow use `Wrap` (or `Flexible` text) so they never overflow on small phones
- Check the screen at 360x640 and 390x844 (light and dark) with a temporary golden test before opening a PR

```dart
class MyGameScreen extends StatelessWidget {
  final CoreGameTheme? coreTheme;
  final GameThemeOverride<MyGameTheme>? theme;

  const MyGameScreen({this.coreTheme, this.theme, super.key});

  @override
  Widget build(BuildContext context) {
    return GameControllerProvider(
      create: MyGameController.new,
      coreTheme: coreTheme,
      theme: (core) {
        final defaults = MyGameTheme.fromCore(core);
        return theme?.call(defaults) ?? defaults;
      },
      builder: (context, controller, theme, coreTheme) => FlutterMiniGamesScreen(
        title: 'My Game',
        child: GameScreenLayout(
          header: Column(
            spacing: 8,
            children: [MyGameHeader(controller: controller), GameStatsBar(controller: controller)],
          ),
          boardAspectRatio: 1,
          board: MyGameBoard(controller: controller),
          controls: controller.isWon
              ? GameButton(onTap: controller.nextPuzzle, icon: Icons.arrow_forward, label: 'Next Puzzle')
              : GameButton(onTap: controller.resetGame, icon: Icons.refresh, label: 'Reset'),
          footer: const GameHowToPlay(items: [GameHowToPlayItem(icon: Icons.touch_app, text: 'Tap to play')]),
        ),
      ),
    );
  }
}
```

#### 5. Game Widgets with CustomPaint

When drawing paths/lines that connect across cells:

```dart
class _CellPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor  // Use solid color, NO alpha (avoids overlap artifacts)
      ..strokeWidth = lineThickness  // From the game theme dimens
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);

    // Extend past edges to cover gaps between cells
    const overshoot = 4.0;

    // Draw lines with overshoot for seamless connections
    if (goesUp) {
      canvas.drawLine(center, Offset(center.dx, -overshoot), paint);
    }
    if (goesDown) {
      canvas.drawLine(center, Offset(center.dx, size.height + overshoot), paint);
    }
    // ... etc
  }
}
```

**Key tips for CustomPaint:**

- Use solid colors (no alpha) to avoid overlap artifacts
- Add overshoot (4px) to extend lines past cell boundaries for seamless connections
- Use `StrokeCap.round` for smooth line ends
- Compare sets by content in `shouldRepaint`, a new set is created on every build

#### 6. Real-time Games

Games that move every frame (Snake, Flit, Dash, Hop, Stack) use the shared loop and input instead of their own tickers or gesture code:

- The controller mixes in `RealtimeGameController`: `isRunning` and `tick(Duration delta)`
- The simulation lives in `tick` and is frame-rate independent: move by `speed * seconds`, never per frame
- Wrap the playing field in `GameLoop(controller: ...)`: it only ticks while `isRunning` and the app is in the foreground, and clamps long frames to `GameLoop.maxDelta`
- Use `GameInputDetector` for all input, never your own gesture or key handling:
  - `onTap` / `onRelease` (touch, space/enter; arrow up when there is no `onSwipe`), e.g. hold to jump higher
  - `onTapAt(localPosition)` for grids and pads: one detector for the whole board, map the position to a cell
  - `autofocus: false` when a screen has more than one detector (only one may take the keyboard focus)
  - `onSwipe` (swipes, arrows/WASD); `repeatSwipes: false` for one move per drag (2048)
  - `onHorizontalHold` (hold left/right half, arrow left/right, A/D) for steering
- Use `GameBoard` for the playing field frame and `GameOverlay` for "Tap to start" / "Game over" messages
- Draw with `CustomPaint` using theme colors, use world coordinates (e.g. 0..1 or cells) and scale to the canvas size
- Inject `Random` in the controller so tests are reproducible; test the controller by calling `tick` directly

```dart
class MyRealtimeController extends GameController with RealtimeGameController {
  @override
  bool get isRunning => status == GameStatus.playing && !_isGameOver;

  @override
  void tick(Duration delta) {
    final seconds = delta.inMicroseconds / Duration.microsecondsPerSecond;
    _position += _speed * seconds;
    if (_hitObstacle()) finish(GameOutcome.lost, score: _score);
    notifyListeners();
  }
}
```

#### 7. Two-player Games (one device)

Two players on one phone use the shared duel core (`lib/src/core/duel/`), never their own split screen or match flow:

- `DuelPlayer.bottom` (Player 1, `primary`) and `DuelPlayer.top` (Player 2, `secondary`); colors via `coreTheme.playerColor(player)` / `onPlayerColor(player)`
- `DuelLayout(side: (context, player) => ..., center: ...)`: the top half is rotated 180° for the opposite player (touch positions inside are rotated too)
- `DuelTapArea(onTap: ...)`: every finger counts, also when both players tap at once (raw pointers); use a `Listener` for drags (e.g. mallets), pointers stay with the half they started in
- Matches with rounds mix in `DuelGameController` (`roundsToWin`, `resetRound()`, `onRoundStarted()`, `endRound(winner)`, `rematch()`):
  - Flow: ready (both players tap) → 3-2-1 countdown → playing → round result → ... → winner + rematch
  - Real-time duels: `isRunning => duelIsRunning`, call `tickDuel(delta)` at the start of `tick` and only simulate while `phase == DuelPhase.playing`
  - Ignore player input unless `phase == DuelPhase.playing`
  - The result is `GameOutcome.won` with `data: {'winner': 'top' | 'bottom', 'rounds': {...}}`, no score
- Put `DuelPhaseOverlay(controller: ..., player: ...)` on top of each half: ready buttons, countdown, round result, winner, rematch and the round score
- Turn-based games on a shared board (Four Up, Boxes, Flip) don't need rounds: use `DuelPlayer` and its colors, show whose turn it is on both sides (the top one rotated), and finish with `won` + `data['winner']` or `draw`

## Adding a New Game - Checklist

1. **Create directory structure** under `lib/src/game/{game_name}/`

2. **Create game controller** (`game/logic/{game}_game_controller.dart`)
   - Extend `GameController` with a unique `static const id`
   - Call `registerMove()`, `finish()` and `restartSession()`
   - Include `resetGame()` and optionally `nextPuzzle()` methods

3. **Create game models** (optional, `game/model/`)
   - Data classes for game-specific structures
   - Puzzle generator if procedural content is needed

4. **Create theme** (`style/{game}_theme.dart`)
   - Same shape as every other game theme: `colors`, `textStyles`, `dimens`, `fromCore`, `copyWith`
   - **Only use values from CoreGameTheme** - no hardcoded colors!

5. **Create game builder** (`game/{game}_game_builder.dart`)
   - Extend `FlutterMiniGameBuilder`, `const` constructor
   - Set `id`, `name`, `description`, `isMultiPlayer`, accept `coreTheme` and `theme`
   - Support both custom puzzles and procedural generation where it applies

6. **Create screen** (`screen/{game}_screen.dart`)
   - Use `GameControllerProvider`, `FlutterMiniGamesScreen`, `GameStatsBar`, `GameHowToPlay`

7. **Create header** (`screen/{game}_header.dart`)
   - Display game status/progress

8. **Create widgets** (`widget/{game}_*.dart`)
   - Game-specific UI components

9. **Export from library** (`lib/flutter_mini_games.dart`)

   ```dart
   export 'src/game/{game_name}/game/{game}_game_builder.dart';
   export 'src/game/{game_name}/style/{game}_theme.dart';
   // Also export any public models users might need
   ```

10. **Add to example app** (`example/lib/src/screen/home_screen.dart`)

    ```dart
    static const List<FlutterMiniGameBuilder> _games = [
      TicTacToeGameBuilder(),
      TrailGameBuilder(),
      MyGameBuilder(),  // Add new game here
    ];
    ```

11. **Run `tool/check_tree_shaking.sh <game folder>`** - builds only your game's app and checks with the compiler report (`--dump-info`) that no other game is in it (CI runs it for every game)

## Available Core Components

- `FlutterMiniGames` - Optional root widget: core theme (light/dark), `GameScoreStore`, `onGameFinished`, and `FlutterMiniGames.launch`
- `FlutterMiniGameBuilder` - Entry point of a game (`id`, `name`, `description`, `isMultiPlayer`, `build`)
- `GameController` - Base class for game controllers: status, timer, moves, `finish()`
- `GameResult` / `GameStats` / `GameScoreStore` / `InMemoryGameScoreStore` - Shared scores system
- `GameTheme` / `CoreGameTheme` / `GameThemeOverride<T>` - Theme system
- `GameThemeBuilder<T>` - Widget for accessing themes
- `GameControllerProvider` - Provides controller and themes, reports results
- `FlutterMiniGamesScreen` - Standard screen with app bar
- `GameScreenLayout` - Header, largest-fitting board, controls, and a footer below the fold
- `GameButton` - Styled button component
- `GameStatsBar` - Time, moves and best score
- `GameHowToPlay` - Rules panel
- `GameBoard` - Rounded, elevated frame for the playing field
- `GameOverlay` - Message on top of the playing field ("Tap to start", "Game over")
- `RealtimeGameController` / `GameLoop` - Per-frame updates for real-time games
- `GameInputDetector` / `GameDirection` - Taps, swipes and keyboard input
- `DuelPlayer`, `DuelLayout`, `DuelTapArea`, `DuelGameController`, `DuelPhaseOverlay` - Two players on one device

## Existing Games

### Tic Tac Toe (`lib/src/game/tic_tac_toe/`)

- Two-player classic game, id `tic_tac_toe`
- Simple state: board, current turn, winner
- Reports `won` (winner in `data['winner']`) or `draw`, no score

### Trail (`lib/src/game/trail/`)

- Single-player puzzle, id `trail`: draw one trail through every cell, passing the numbered checkpoints in order
- Trail must START at checkpoint 1 and END at the last checkpoint
- Features:
  - `TrailPuzzleGenerator` for random solvable puzzle generation
  - Hamiltonian path algorithm with Warnsdorff's heuristic
  - 5 difficulty levels (3x3 to 7x7 grids)
  - Support for custom puzzle lists OR auto-generation
  - `nextPuzzle()` method for progression, `undo()` to step back (also when stuck)
  - Score: `cells * 20 - seconds - undos * 5`, never lower than the number of cells
- Visual style: Snake-pattern path lines on light background (not filled cells)

### Sudoku (`lib/src/game/sudoku/`)

- Single-player classic 9x9 sudoku, id `sudoku`, turn based (no game loop)
- Features:
  - `SudokuSolver`: bitmask backtracking (fewest candidates first) that solves and counts solutions
  - `SudokuPuzzleGenerator`: random full grid, then removes givens in random order while the solution stays unique (injectable `Random`)
  - `SudokuDifficulty`: easy / medium / hard / expert (40 / 32 / 28 / 24 target givens)
  - Custom puzzle lists (`SudokuPuzzle.fromString('53..7....')`) OR auto-generation, `nextPuzzle()` for progression
  - Tap a cell, then a digit on the number pad; erase and a notes (pencil marks) toggle
  - Highlights the row/column/box and the same digits as the selected cell; wrong entries are marked and counted as mistakes; correct entries are locked
  - Score: `basePoints - seconds - mistakes * 50`, never lower than `basePoints / 10` (base points 1000 / 1500 / 2000 / 2500 per difficulty)
- Visual style: cells on the board background, thin cell lines and thick 3x3 box lines painted on top with solid colors
### Stack (`lib/src/game/stack/`)

- Single-player real-time game, id `stack`: a block slides back and forth above the tower, tap (or space/enter) drops it
- World is 1 wide and `viewHeight` (4/3) high, blocks are `blockHeight` high; `StackBlock` (level, left, width) and `StackFallingPiece` model blocks and cut off parts
- The overhang is cut off and falls away, the next block gets the remaining width; missing the block below completely is game over
- A drop within `perfectTolerance` snaps to the block below (perfect); speed grows by `speedIncrement` per block up to `maxSpeed`
- The view follows the tower (`cameraY`), block colours cycle between `primary` and `secondary` (`StackTheme.blockColor`)
- Score: 1 per block + `min(streak, 5)` for a streak of perfect drops; finishes with `lost` and the score, `data` holds `blocks` and `perfects`
- The start tap calls `startSession()` (not a move), every drop is a move
### Dash (`lib/src/game/dash/`)

- Single-player endless runner, id `dash`: the runner stays at a fixed x, obstacles scroll in from the right
- Real-time game (`RealtimeGameController`), world of 12 x 8 units (3:2 `GameBoard`), y up from the ground
- Input: tap / space / up / swipe up = jump (no double jump, `registerMove()` per jump), swipe down / arrow down = duck for 0.6 s or fall fast in the air
- Obstacles: ground blocks of 5 sizes, after distance 150 also low flyers (duck under or jump over) and high flyers (run under, do not jump)
- Fairness: the free gap between two obstacles is at least a full jump plus reaction time at the (slightly higher) arrival speed; tests play the game with a simple bot
- Speed starts at 7 units/s and grows by 0.1 units/s per second up to 14; exact kinematics make jumps frame-rate independent
- Forgiving hitboxes, inset from the drawn shapes
- Score: 10 points per world unit of distance; hitting an obstacle finishes with `GameOutcome.lost` (`data['distance']`)
### Flit (`lib/src/game/flit/`)

- Single-player endless side-scroller, id `flit`: tap (or space / arrow up) to flap and fly through the gaps between the columns
- Real-time: `FlitGameController` mixes in `RealtimeGameController`, physics in world units (`worldWidth` 0.75 x height 1.0, board 3:4)
- Gravity pulls the flyer down, a flap sets its vertical velocity; the flyer tilts with its velocity
- Columns scroll at a constant speed and are recycled once they leave the board; gap centers are random (injectable `Random`), within margins and at most `maxGapShift` from the previous gap so every gap is reachable; the gap shrinks slightly per column down to `minGapSize`
- Forgiving circular hitbox (`hitboxRadius` < `flyerRadius`)
- Score: columns passed; hitting a column, the ground or the top finishes with `GameOutcome.lost` and the score
- `registerMove()` per flap; states: ready ("Tap to start", flyer hovers), playing, game over ("Play again")
### Hop (`lib/src/game/hop/`)

- Single-player endless vertical jumper, id `hop`, real-time (`RealtimeGameController` + `GameLoop`)
- The character bounces automatically when it falls onto a platform (passes through from below); hold the left/right half of the board or the arrow keys / A-D to steer, the screen wraps horizontally
- World units: 1.0 wide, y grows upwards, the view is 4/3 high (3:4 `GameBoard`); the camera only moves up
- `HopPlatformGenerator` (injectable `Random`): gaps grow with the height but stay below 75% of the jump height; the reachable platform of every step is never breakable; moving and breakable platforms appear as the height grows
- Input: `GameInputDetector(onTap: start, onHorizontalHold: steer)`; a tap or space starts without counting a move (`startSession()`), every new steering direction is a move
- Score: max height × 100; falling below the view finishes with `GameOutcome.lost` and the score
### Minesweeper (`lib/src/game/minesweeper/`)

- Single-player puzzle, id `minesweeper`: reveal every safe cell without hitting a mine
- `MinesweeperDifficulty` (cols x rows, mines), sized for a portrait phone: easy 8x8/10, medium 10x12/20, hard 12x16/40; switchable in the game
- Mines are placed on the first reveal (injectable `Random`), never on the tapped cell or its neighbours, so the first tap always opens an area
- Tap = reveal (flood fill for cells without adjacent mines), long press = flag, a flag-mode button toggles what a tap does; tapping a revealed number whose flags match reveals its neighbours (chord)
- Header shows the remaining mines counter (mines - flags); number colours come from `MinesweeperColors.numbers` (core tokens only)
- Lose on a mine: all mines are shown, `finish(lost)` without score. Win when all safe cells are revealed: `finish(won)`
  - Score: `mines * 100 - seconds * 5`, never lower than `mines * 10` (`MinesweeperGameController.calculateScore`)
- Turn based, no `GameLoop`
### Snake (`lib/src/game/snake/`)

- Single-player real-time game, id `snake`: steer the snake to the food, it grows with every bite
- Square grid (15x15 by default, `gridSize` on the builder), the snake moves one cell per step
- Step interval starts at 180 ms and gets 5 ms shorter per food, down to 80 ms (time accumulator in `tick`)
- Swipes / arrow keys via `GameInputDetector`; up to 2 direction changes are queued, reversing is ignored
- The first swipe starts the game and takes the first step right away; the snake is drawn one step behind and interpolated with `stepProgress` (head and tail glide, corners stay sharp)
- Food spawns on a random empty cell (injectable `Random`)
- Score: 10 points per food. Hitting a wall or itself finishes with `GameOutcome.lost` and the score; filling the board is `GameOutcome.won`
### 2048 (`lib/src/game/twenty_forty_eight/`)

- Single-player puzzle, id `twenty_forty_eight` (classes `TwentyFortyEight*`, Dart identifiers can't start with a digit)
- 4x4 board, swipe (or arrow keys/WASD via `GameInputDetector`) to slide all tiles; equal tiles merge once per move
- After every move that changed the board a tile spawns on a random empty cell (2 with 90%, 4 with 10%), `Random` is injectable
- Score: sum of the merged tile values. Reaching 2048 finishes as `won`, no moves left finishes as `lost` (both with the score)
- `initialBoard` on the controller sets up a board for tests
- Tiles keep their id while sliding (`AnimatedPositioned`), new and merged tiles pop (`TweenAnimationBuilder`)
- Tile colors blend `surface` → `primary` by log2(value); the text color (`text` or `onPrimary`) is picked by contrast
### Switch (`lib/src/game/switch/`)

- Single-player Lights Out, id `switch_lights`, turn based (no game loop): tapping a light toggles it and its 4 neighbours, turn every light off
- The id is not `switch`: Flutter itself contains the string `"switch"`, so the tree-shaking check would always find it
- Theme classes are `SwitchGame*` (`SwitchGameTheme`, ...) because Flutter's material library already has a `SwitchTheme`
- 5x5 board stored as a bitmask (bit `row * size + col`), sizes up to 5 so the masks stay within the 32-bit web limit
- `SwitchSolver`: Gaussian elimination over GF(2), returns every solution (4 on a 5x5 board), the minimal one gives par and the hint
- `SwitchPuzzleGenerator` (injectable `Random`): taps `SwitchDifficulty.taps` distinct random cells of a dark board (3 / 6 / 9 / 13), so every puzzle is solvable; retries when the taps cancel out
- Custom puzzle lists (`SwitchPuzzle.fromString('.#... ###.. .#... ..... .....')`, unsolvable boards throw) OR generation; `nextPuzzle()`, difficulty chips in the header
- Hint: highlights one tap of the minimal solution from the current board (counted in `data['hints']`, no score penalty)
- Score: `max(100, 1000 - (moves - par) * 50 - seconds)`; all lights off finishes with `won`, `data` holds `difficulty`, `par` and `hints`
- Visual style: lit = `primary` cell + filled bulb + blurred solid glow (own layer below the lights), off = `surface` cell + outlined bulb
### Code (`lib/src/game/code/`)

- Single-player code breaker, id `code`, turn based (no game loop): guess a hidden code of 4 pegs out of 6 symbols in 8 tries, repeats allowed
- `CodePeg` (circle, square, triangle, diamond, star, hexagon): every peg has its own shape, so the game is playable without colors; peg colors are core tokens and `Color.lerp` mixes of them (`CodeColors.pegs`)
- `CodeFeedback.evaluate(secret, guess)`: `exact` (right symbol, right place) and `misplaced` (standard min-count rule with repeats: per symbol `min(count in code, count in guess)` minus the exact hits)
- Feedback is a 2x2 grid of markers: filled = exact, hollow ring = misplaced
- Tap a symbol to fill the next empty slot, tap a slot to clear it, Clear empties the guess, Submit checks a full guess; the hidden code is shown on top of the board when the game ends
- The first peg starts the timer (`startSession()`), every submitted guess is a move; `Random` and the first `secret` are injectable
- Score: `(9 - tries) * 100`. Cracked: `won` with the score, out of tries: `lost` without score; `data['tries']`
### Echo (`lib/src/game/echo/`)

- Single-player memory game, id `echo`: four pads light up in a sequence that grows by one every round, repeat it by tapping the pads in the same order
- Phases (`EchoPhase`): ready → playback (input ignored) → input → playback of the next round ... → game over on the first wrong pad
- Playback runs in `tick` (`RealtimeGameController` + `GameLoop`, so it pauses in the background): `leadIn` 700 ms, then per pad `onDurationFor(length)` lit (600 ms down to 250 ms) and `offDurationFor(length)` dark (250 ms down to 100 ms)
- Pads in a 2x2 grid, colors `primary`, `secondary`, `error`, `textMuted` (`EchoColors.pads`), each with its own shape icon (circle, triangle, square, star) so they never differ by color alone; unlit pads blend towards `background` and scale down, a tapped pad flashes for `pressFlash`
- The sequence uses an injectable `Random`; every pad tap is a move (`registerMove()`), tapping a pad or Start in the ready state starts the session; haptic `selectionClick` per tap
- Score: rounds completed. A wrong pad finishes with `GameOutcome.lost` and the score (`data`: `rounds`, `sequenceLength`); the wrong pad shows a cross and the expected pad lights up
### Pairs (`lib/src/game/pairs/`)

- Single-player memory game, id `pairs`, turn based (no `GameLoop`): flip two cards at a time, matching pairs stay open
- `PairsDifficulty` (cols x rows): easy 4x4 (8 pairs), medium 4x5 (10), hard 5x6 (15); switchable in the game
- Cards are shuffled with an injectable `Random`; faces are Material `Icons` (`PairsCardTile.faceIcons`) colored by `PairsColors.faces`, backs in `cardBack`
- The first card of an attempt starts the timer (`startSession()`), the second counts as a move (`registerMove()`)
- Two cards that don't match get an error border and turn back after `mismatchDelay` (800 ms, a `Timer`); flips are ignored meanwhile. `hideMismatch()` turns them back right away (tests)
- Cards flip with a rotation (`TweenAnimationBuilder`), found pairs fade to `matchedOpacity`
- Score: `1000 - moves * 10 - seconds`, never below 100; all pairs found finishes with `won` and the score (`data`: difficulty, rows, cols, pairs)
### Whack (`lib/src/game/whack/`)

- Single-player real-time game, id `whack`: targets pop up out of a 3x3 grid of holes, tap them before they hide
- 30 second round (`RealtimeGameController` + `GameLoop`); a tap on the board (or space/enter) starts it with `startSession()`, every tap on a hole is a move
- Event-based timing on the round time: every target has a `spawnedAt` and `visibleDuration`, spawns that are due in a frame happen at their own time, so the result does not depend on how `tick` is split
- The visible time shrinks from 1.5 s to 0.65 s and the spawn interval from 0.9 s to 0.45 s over the round, so several targets can be up at once; targets only spawn in empty holes (injectable `Random`)
- 25% of the targets are decoys: a spiky ball with an angry face (critters are round with ears), drawn with `CustomPaint`
- Each hole is its own raw `Listener` (multi-touch); the pop-up (slide out of the hole + scale) comes from `WhackTarget.popAt` on the controller
- Score: hits - decoys tapped (taps on empty holes do not count). The round end finishes with `GameOutcome.won`, the score and `data` with `hits`, `decoys`, `misses`, `escaped`
### Reflex (`lib/src/game/reflex/`)

- Single-player reaction test, id `reflex`, real-time (`RealtimeGameController` + `GameLoop`) for the timing
- 5 tries; each try waits a random delay between 1.5 and 5 s (injectable `Random`), then the board changes color: tap (or space/enter) as fast as possible
- Tapping before the change shows "Too early!" and retries that try with a new delay
- Phases (`ReflexPhase`): ready → waiting → go → measured (tap for the next try) → ... → finished; too early → tap to retry
- The reaction time is game time from `tick`: it starts with the frame that shows the change and stops at the tap event (`GameInputDetector.onTap`, fires on touch down); tests drive `tick` and `onTap` directly
- Every phase has its own theme color plus a big icon and message, so the change is never color-only; the color switches instantly (no animation)
- The start tap calls `startSession()`, every tap during a try (early or measured) is a move
- Score: `max(0, 1000 - average ms)`; finishes with `GameOutcome.won`, `data` holds `averageMs`, `bestMs`, `timesMs` and `earlyTaps`
### Boxes (`lib/src/game/boxes/`)

- Two-player dots and boxes on one device, id `boxes`, turn based (no game loop, no rounds): 4x4 boxes (5x5 dots), `rows` / `cols` on the controller for tests
- `DuelPlayer.bottom` (Player 1, symbol `1`) starts, `DuelPlayer.top` (Player 2, symbol `2`); colors via `coreTheme.playerColor(player)` in `BoxesTheme.fromCore`
- `BoxesEdge` (horizontal / vertical, row, col) is a line between two adjacent dots; every drawn line is a move (`registerMove()`), drawn edges are ignored
- Completing the fourth side of a box claims it (one line can claim two) and gives the same player another turn; otherwise the turn passes
- When every box is claimed: `GameOutcome.won` with `data['winner']` (`bottom` / `top`) and `data['boxes']` (`{'bottom': n, 'top': m}`), or `GameOutcome.draw` with the box counts; no score
- Input: one `GameInputDetector(onTapAt:)` on the board; `BoxesBoardGeometry.edgeAt` maps a tap to the nearest free edge within 0.42 cells (a tap in the middle of a box draws nothing)
- Screen: `GameScreenLayout` with a banner per player (turn / result + box count): Player 2's banner rotated 180° above the board, Player 1's banner below it; the top player's box symbols are rotated too
- Visual style: claimed boxes filled in the player color with the symbol (never color only), lines in the player color, undrawn lines as `surface` guides, a small marker on the last drawn line

## Testing

Tests are located in `test/` and follow the same directory structure as the source.

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/game/trail/trail_puzzle_generator_test.dart

# Run with compact reporter
flutter test --reporter compact

# Verify that unused games are tree-shaken (slow, builds one web app per game)
tool/check_tree_shaking.sh
```

### Writing Tests for Games

1. Create tests in `test/game/{game_name}/`
2. Test the controller: moves, win/lose conditions and the reported `GameResult`
3. For procedural content: test that it is valid and solvable, with seeded random (`Random(42)`)
4. Test edge cases (min/max sizes, boundary conditions)
5. Verify win conditions (e.g., path starts AND ends at correct positions)

## Code Style

- Use `super.key` in widget constructors
- Use `spacing` parameter in `Column`/`Row` instead of `SizedBox` between children
- Prefer `const` constructors where possible
- Run `tool/format.sh` and `dart analyze --fatal-infos` before committing (CI checks both)
- **No hardcoded colors** - always use CoreGameTheme
- **No alpha on overlapping paint** - use solid colors to avoid artifacts
