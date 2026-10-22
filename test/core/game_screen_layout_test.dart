import 'package:flutter/material.dart';
import 'package:flutter_mini_games/flutter_mini_games.dart';
import 'package:flutter_mini_games/src/core/widget/provider/game_theme_provider.dart';
import 'package:flutter_mini_games/src/core/widget/screen/game_screen_layout.dart';
import 'package:flutter_test/flutter_test.dart';

const _boardKey = Key('board');
const _footerKey = Key('footer');

Future<void> _pump(WidgetTester tester, Size size, {double aspectRatio = 1}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: GameThemeProvider<CoreGameTheme>(
        theme: CoreGameTheme.light(),
        builder: (context, theme) => Scaffold(
          body: GameScreenLayout(
            header: const SizedBox(height: 80),
            boardAspectRatio: aspectRatio,
            board: const ColoredBox(key: _boardKey, color: Colors.black),
            controls: const SizedBox(height: 48),
            footer: const SizedBox(key: _footerKey, height: 200),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('GameScreenLayout', () {
    testWidgets('gives a square board the full width on a short phone', (tester) async {
      await _pump(tester, const Size(360, 640));

      expect(tester.getSize(find.byKey(_boardKey)), equals(const Size(360, 360)));
    });

    testWidgets('puts the footer below the first screen height', (tester) async {
      await _pump(tester, const Size(360, 640));

      expect(tester.getTopLeft(find.byKey(_footerKey)).dy, greaterThanOrEqualTo(640));
    });

    testWidgets('keeps the aspect ratio when the height is the limit', (tester) async {
      await _pump(tester, const Size(800, 600), aspectRatio: 3 / 4);

      final size = tester.getSize(find.byKey(_boardKey));
      expect(size.width / size.height, closeTo(3 / 4, 0.001));
      expect(size.height, lessThan(600));
    });

    testWidgets('caps the board width on wide screens', (tester) async {
      await _pump(tester, const Size(1200, 1600));

      expect(tester.getSize(find.byKey(_boardKey)).width, equals(GameScreenLayout.maxBoardWidth));
    });

    testWidgets('scrolls instead of overflowing on very small screens', (tester) async {
      await _pump(tester, const Size(320, 400));

      expect(tester.takeException(), isNull);
      // The page keeps its minimum height: header 80, controls 48 and 2 x 16 spacing
      expect(tester.getSize(find.byKey(_boardKey)).height, equals(GameScreenLayout.minPageHeight - 80 - 48 - 32));
    });
  });
}
