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

    testWidgets('opens the footer in a bottom sheet', (tester) async {
      await _pump(tester, const Size(360, 640));
      expect(find.byKey(_footerKey), findsNothing);

      await tester.tap(find.text('How to play'));
      await tester.pumpAndSettle();

      expect(find.byKey(_footerKey), findsOneWidget);
    });

    testWidgets('does not scroll, so vertical drags reach the board', (tester) async {
      var dragged = 0.0;
      tester.view
        ..physicalSize = const Size(360, 640)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          home: GameThemeProvider<CoreGameTheme>(
            theme: CoreGameTheme.light(),
            builder: (context, theme) => Scaffold(
              body: GameScreenLayout(
                board: GestureDetector(
                  onPanUpdate: (details) => dragged += details.delta.dy,
                  child: const ColoredBox(key: _boardKey, color: Colors.black),
                ),
                footer: const SizedBox(key: _footerKey, height: 200),
              ),
            ),
          ),
        ),
      );

      await tester.drag(find.byKey(_boardKey), const Offset(0, -100));

      expect(dragged, lessThan(-50));
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
      expect(tester.getSize(find.byKey(_boardKey)).height, greaterThan(200));
    });
  });
}
