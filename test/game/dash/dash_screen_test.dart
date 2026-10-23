import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mini_games/flutter_mini_games.dart';
import 'package:flutter_mini_games/src/core/widget/components/button.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_stats_bar.dart';
import 'package:flutter_mini_games/src/core/widget/input/game_input_detector.dart';
import 'package:flutter_mini_games/src/core/widget/screen/game_screen_layout.dart';
import 'package:flutter_mini_games/src/core/widget/screen/screen.dart';
import 'package:flutter_mini_games/src/game/dash/game/logic/dash_game_controller.dart';
import 'package:flutter_mini_games/src/game/dash/screen/dash_header.dart';
import 'package:flutter_mini_games/src/game/dash/widget/dash_field.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../helpers/frame_counter.dart';

DashGameController _controller(WidgetTester tester) => Provider.of<DashGameController>(tester.element(find.byType(DashField)), listen: false);

Future<void> _pumpGame(WidgetTester tester) async {
  // Small phone
  tester.view
    ..physicalSize = const Size(360, 740)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: Builder(builder: const DashGameBuilder().build)));
}

void main() {
  testWidgets('a tap starts the game and the game loop advances it', (tester) async {
    await _pumpGame(tester);
    expect(find.text('Tap to start'), findsOneWidget);
    expect(_controller(tester).isReady, isTrue);

    await tester.tap(find.byType(GameInputDetector));
    await tester.pump();
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    final controller = _controller(tester);
    expect(controller.isRunning, isTrue);
    expect(controller.moves, equals(1));
    expect(controller.distance, greaterThan(0));
    expect(find.text('Tap to start'), findsNothing);
    expect(find.text('${controller.score}'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the keyboard starts the game', (tester) async {
    await _pumpGame(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();

    expect(_controller(tester).isRunning, isTrue);
  });

  testWidgets('game over shows the score and play again restarts', (tester) async {
    await _pumpGame(tester);
    final controller = _controller(tester)..jump();
    // Run into the first obstacle without jumping
    while (!controller.isFinished) {
      controller.tick(const Duration(milliseconds: 16));
    }
    await tester.pump();

    expect(find.text('Game over'), findsWidgets);
    expect(find.text('Score: ${controller.score}'), findsOneWidget);

    await tester.tap(find.text('Play again'));
    await tester.pump();

    expect(controller.isReady, isTrue);
    expect(find.text('Tap to start'), findsOneWidget);
  });

  testWidgets('a running frame only rebuilds the live score, not the screen', (tester) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: Builder(builder: const DashGameBuilder().build)));
    await tester.tap(find.byType(GameInputDetector));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    final controller = _controller(tester);
    final scoreBefore = controller.score;

    final counter = FrameCounter();
    await counter.measure(tester);

    expect(controller.isRunning, isTrue);
    expect(counter.buildsOf<FlutterMiniGamesScreen>(), equals(0));
    expect(counter.buildsOf<GameScreenLayout>(), equals(0));
    expect(counter.buildsOf<DashHeader>(), equals(0));
    expect(counter.buildsOf<GameStatsBar>(), equals(0));
    expect(counter.buildsOf<GameButton>(), equals(0));
    expect(counter.buildsOf<DashField>(), equals(0));
    // Only the score and speed texts: ListenableBuilder + 2 Texts per frame
    expect(counter.built.length, lessThanOrEqualTo(10 * 3));
    // The score in the header still follows the game
    expect(controller.score, greaterThan(scoreBefore));
    expect(find.text('${controller.score}'), findsOneWidget);
  });
}
