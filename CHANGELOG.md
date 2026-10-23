# Changelog

## 0.0.1

First public release.

- 27 games: Tic Tac Toe, Trail, Sudoku, Stack, Dash, Flit, Hop, Minesweeper, Snake, 2048, Switch, Code, Echo, Pairs, Whack, Reflex, Boxes, Puck, Breaker, Four Up, Quickdraw, Push, Slap, Tiles, Flip, Snatch and Tug
- `FlutterMiniGames.launch` to open a game, `FlutterMiniGames` root widget for app-wide theme, scores and `onGameFinished`
- One scores system for every game: `GameResult`, `GameStats`, `GameScoreStore`
- Theming from your app: `CoreGameTheme` (light, dark, from Material) and a per-game `theme: (theme) => theme.copyWith(...)`
- Unused games are tree-shaken from your app
