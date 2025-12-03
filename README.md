# flutter_mini_games

A Flutter package that makes it easy to embed fun, casual mini games into your app. Enhance engagement and retention by offering users a library of simple games—seamlessly integrated into your user experience.

## Features

- Plug-and-play library of mini games for Flutter apps
- Easy-to-use widgets to embed games anywhere in your app
- Customizable UI to match your app’s theme
- Supports both Android and iOS
- Lightweight and modular design
- Designed for rapid integration and extensibility

> _More mini games, customization options, and features coming soon!_

## Getting started

### Prerequisites

- Flutter SDK `>=1.17.0` (tested with Dart 3.8.1+)
- Works with Android and iOS out of the box

### Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_mini_games: ^0.0.1
```

Then run:

```bash
flutter pub get
```

## Usage

Import the package and use the available widgets to add games anywhere in your app.

```dart
import 'package:flutter_mini_games/flutter_mini_games.dart';

class MyMiniGameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mini Game')),
      body: Center(
        child: MiniGameWidget(
          gameType: MiniGameType.ticTacToe,
        ),
      ),
    );
  }
}
```

For more advanced examples and a list of all available games and configuration options, check out the [`/example`](example/) directory.

## Additional information

- [Package homepage](https://pub.dev/packages/flutter_mini_games) (coming soon)
- Issues and feedback: Please file issues or feature requests via the [GitHub issue tracker](https://github.com/impaktfull/flutter_mini_games/issues)
- Contributions welcome! See `CONTRIBUTING.md` for guidelines.
- Licensed under the BSD 3-Clause License.
- Author: Koen Van Looveren

If you have questions, suggestions, or want to contribute additional mini games, feel free to submit a pull request or start a discussion!
