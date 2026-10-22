# Flutter Mini Games Library

This document provides guidance for AI assistants working on this codebase.

## Project Overview

A Flutter library providing reusable mini games. Each game follows a consistent architecture with controllers, themes, builders, and widgets.

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

### Core Patterns

#### 1. Game Controller

- Extends `GameController` (which extends `ChangeNotifier`)
- Contains all game state as private fields with public getters
- Calls `notifyListeners()` after state changes
- Provides methods for game actions (e.g., `makeMove()`, `resetGame()`, `nextPuzzle()`)

```dart
import 'package:flutter_mini_games/src/core/controller/game_controller.dart';

class MyGameController extends GameController {
  // Private state
  bool _isGameOver = false;

  // Public getters
  bool get isGameOver => _isGameOver;

  // Actions
  void makeMove() {
    // Update state
    _isGameOver = true;
    notifyListeners();
  }

  void resetGame() {
    _isGameOver = false;
    notifyListeners();
  }
}
```

#### 2. Game Theme

- Extends `GameTheme`
- Contains `{Game}Colors` and `{Game}TextStyles` classes
- Static `getDefault({required CoreGameTheme coreTheme})` factory
- Static `of(BuildContext context)` for retrieval
- **IMPORTANT**: Only use colors from `CoreGameTheme` - do NOT invent new colors

```dart
import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';

class MyGameTheme extends GameTheme {
  final MyGameColors colors;
  final MyGameTextStyles textStyles;

  static MyGameTheme of(BuildContext context) => GameTheme.of<MyGameTheme>(context);

  MyGameTheme({required this.colors, required this.textStyles});

  static MyGameTheme getDefault({required CoreGameTheme coreTheme}) {
    // Use ONLY colors from coreTheme - no hardcoded colors!
    return MyGameTheme(
      colors: MyGameColors(
        background: coreTheme.colors.background,
        primary: coreTheme.colors.primary,
        secondary: coreTheme.colors.secondary,
      ),
      textStyles: MyGameTextStyles(
        header: coreTheme.textStyles.title,
        body: coreTheme.textStyles.body,
      ),
    );
  }
}
```

**CoreGameTheme available colors:**

- `primary` - Main accent color (purple by default)
- `secondary` - Secondary color (dark by default)
- `background` - Background color
- `card` / `card2` - Card background colors
- `text` - Primary text color
- `textInverted` - Inverted text color (for dark backgrounds)
- `onPrimaryText` - Text on primary color

**CoreGameTheme available text styles:**

- `title` - Bold 24px title text
- `body` - Regular 16px body text

#### 3. Game Builder

- Extends `FlutterMiniGameBuilder`
- Implements `isMultiPlayer` getter
- Implements `build(BuildContext context)` returning the screen widget
- Accepts optional `theme` and `coreTheme` parameters
- Can accept puzzle lists or difficulty for procedural generation

```dart
class MyGameBuilder extends FlutterMiniGameBuilder {
  @override
  bool get isMultiPlayer => false;

  final CoreGameTheme? coreTheme;
  final MyGameTheme? theme;
  final List<MyPuzzle>? puzzles;  // Optional puzzle list
  final int difficulty;            // For procedural generation

  MyGameBuilder({
    super.name = 'My Game',
    super.description = 'Description of the game',
    this.theme,
    this.coreTheme,
    this.puzzles,
    this.difficulty = 3,
  });

  @override
  Future<Widget> build(BuildContext context) async {
    return MyGameScreen(
      coreTheme: coreTheme ?? CoreGameTheme.getDefault(),
      themeBuilder: (coreTheme) => theme ?? MyGameTheme.getDefault(coreTheme: coreTheme),
      puzzles: puzzles,
      difficulty: difficulty,
    );
  }
}
```

#### 4. Game Screen

- Stateless widget
- Wraps content in `GameControllerProvider`
- Uses `FlutterMiniGamesScreen` for consistent layout
- Builder pattern provides controller and themes
- Show different buttons based on game state (e.g., "Next Puzzle" when won, "Reset" otherwise)

```dart
class MyGameScreen extends StatelessWidget {
  final MyGameTheme Function(CoreGameTheme) themeBuilder;
  final CoreGameTheme coreTheme;

  @override
  Widget build(BuildContext context) {
    return GameControllerProvider(
      controller: MyGameController(),
      themeBuilder: themeBuilder,
      coreTheme: coreTheme,
      builder: (context, controller, theme, coreTheme) => FlutterMiniGamesScreen(
        title: 'My Game',
        child: Column(
          children: [
            // Game UI here
            // Show contextual buttons based on state
            if (controller.isWon)
              GameButton(onTap: controller.nextPuzzle, icon: Icons.arrow_forward, label: 'Next Puzzle')
            else
              GameButton(onTap: controller.resetGame, icon: Icons.refresh, label: 'Reset'),
          ],
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
      ..strokeWidth = 16
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

## Adding a New Game - Checklist

1. **Create directory structure** under `lib/src/game/{game_name}/`

2. **Create game controller** (`game/logic/{game}_game_controller.dart`)
   - Extend `GameController`
   - Add state management with `notifyListeners()`
   - Include `resetGame()` and optionally `nextPuzzle()` methods

3. **Create game models** (optional, `game/model/`)
   - Data classes for game-specific structures
   - Puzzle generator if procedural content is needed

4. **Create theme** (`style/{game}_theme.dart`)
   - Extend `GameTheme`
   - **Only use colors from CoreGameTheme** - no hardcoded colors!

5. **Create game builder** (`game/{game}_game_builder.dart`)
   - Extend `FlutterMiniGameBuilder`
   - Set `name`, `description`, `isMultiPlayer`
   - Support both custom puzzles and procedural generation

6. **Create screen** (`screen/{game}_screen.dart`)
   - Use `GameControllerProvider` wrapper
   - Use `FlutterMiniGamesScreen` for layout

7. **Create header** (`screen/{game}_header.dart`)
   - Display game status/progress

8. **Create widgets** (`widget/{game}_*.dart`)
   - Game-specific UI components

9. **Export from library** (`lib/flutter_mini_games.dart`)

   ```dart
   export 'src/game/{game_name}/game/{game}_game_builder.dart';
   // Also export any public models users might need
   ```

10. **Add to example app** (`example/lib/src/screen/home_screen.dart`)
    ```dart
    static final List<FlutterMiniGameBuilder> _games = [
      TicTacToeGameBuilder(),
      TrailGameBuilder(),
      MyGameBuilder(),  // Add new game here
    ];
    ```

## Available Core Components

- `GameController` - Base class for game controllers (extends ChangeNotifier)
- `GameTheme` / `CoreGameTheme` - Theme system with colors and text styles
- `GameThemeBuilder<T>` - Widget for accessing themes
- `GameControllerProvider` - Provider wrapper for controllers and themes
- `FlutterMiniGamesScreen` - Standard screen layout with app bar
- `GameButton` - Styled button component

## Existing Games

### Tic Tac Toe (`lib/src/game/tic_tac_toe/`)

- Two-player classic game
- Simple state: board, current turn, winner

### Trail (`lib/src/game/trail/`)

- Single-player puzzle: draw one trail through every cell, passing the numbered checkpoints in order
- Trail must START at checkpoint 1 and END at the last checkpoint
- Features:
  - `TrailPuzzleGenerator` for random solvable puzzle generation
  - Hamiltonian path algorithm with Warnsdorff's heuristic
  - 5 difficulty levels (3x3 to 7x7 grids)
  - Support for custom puzzle lists OR auto-generation
  - `nextPuzzle()` method for progression, `undo()` to step back (also when stuck)
- Visual style: Snake-pattern path lines on light background (not filled cells)

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
```

### Writing Tests for Games

When adding a new game with procedural content generation:

1. Create tests in `test/game/{game_name}/`
2. Test that generated content is valid
3. Test that generated content is solvable/playable
4. Use seeded random for reproducible tests: `Random(42)`
5. Test edge cases (min/max sizes, boundary conditions)
6. Verify win conditions (e.g., path starts AND ends at correct positions)

## Code Style

- Use `super.key` in widget constructors
- Use `spacing` parameter in `Column`/`Row` instead of `SizedBox` between children (Flutter 3.10+)
- Prefer `const` constructors where possible
- Run `dart analyze` before committing
- **No hardcoded colors** - always use CoreGameTheme
- **No alpha on overlapping paint** - use solid colors to avoid artifacts
