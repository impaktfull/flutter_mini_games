import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mini_games/flutter_mini_games.dart';
import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/game/breaker/game/logic/breaker_game_controller.dart';
import 'package:flutter_mini_games/src/game/breaker/game/model/breaker_phase.dart';
import 'package:flutter_mini_games/src/game/breaker/game/model/breaker_steer.dart';
import 'package:flutter_mini_games/src/game/breaker/screen/breaker_header.dart';
import 'package:flutter_mini_games/src/game/breaker/widget/breaker_playfield.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../helpers/frame_counter.dart';

BreakerGameController _controller(WidgetTester tester) => Provider.of<BreakerGameController>(tester.element(find.byType(BreakerPlayfield)), listen: false);

Rect _board(WidgetTester tester) => tester.getRect(find.descendant(of: find.byType(BreakerPlayfield), matching: find.byType(AspectRatio)));

Future<void> _pumpGame(WidgetTester tester) async {
  tester.view
    ..physicalSize = const Size(360, 740)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: Builder(builder: const BreakerGameBuilder().build)));
}

void main() {
  testWidgets('a tap launches the ball on release and the loop moves it', (tester) async {
    await _pumpGame(tester);
    final controller = _controller(tester);
    expect(find.text('Tap to start'), findsOneWidget);
    expect(find.text('Level 1 / 5'), findsOneWidget);

    final gesture = await tester.startGesture(_board(tester).center);
    await tester.pump();
    expect(controller.phase, equals(BreakerPhase.ready));
    await gesture.up();
    await tester.pump();
    expect(controller.phase, equals(BreakerPhase.playing));
    expect(controller.status, equals(GameStatus.playing));
    expect(controller.moves, equals(1));
    expect(find.text('Tap to start'), findsNothing);

    final startY = controller.ballY;
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(controller.ballY, lessThan(startY));

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('dragging moves the paddle with the finger', (tester) async {
    await _pumpGame(tester);
    final controller = _controller(tester);
    final board = _board(tester);

    final gesture = await tester.startGesture(board.center);
    await tester.pump();
    for (var i = 0; i < 10; i++) {
      await gesture.moveBy(Offset(board.width / 40, 0));
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(controller.isDragging, isTrue);
    // A quarter of the board to the right (the board is the world width), plus the short hold before the drag
    expect(controller.paddleX, closeTo(0.75, 0.04));
    expect(controller.ballX, equals(controller.paddleX));

    // Releasing a drag does not launch, so the paddle can be positioned first
    await gesture.up();
    await tester.pump();
    expect(controller.isDragging, isFalse);
    expect(controller.steer, equals(BreakerSteer.none));
    expect(controller.phase, equals(BreakerPhase.ready));
    expect(controller.status, equals(GameStatus.ready));

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('arrow keys move the paddle and space launches', (tester) async {
    await _pumpGame(tester);
    final controller = _controller(tester);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(controller.steer, equals(BreakerSteer.left));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(controller.paddleX, lessThan(0.5));
    await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(controller.steer, equals(BreakerSteer.none));
    expect(controller.status, equals(GameStatus.ready));

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(controller.phase, equals(BreakerPhase.playing));

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('shows a lost ball, game over and plays again', (tester) async {
    await _pumpGame(tester);
    final controller = _controller(tester);

    for (var life = 0; life < BreakerGameController.startLives; life++) {
      controller
        ..launch()
        ..debugPlacePaddle(0.9)
        ..debugPlaceBall(x: 0.1, y: 1.3, directionX: 0, directionY: 1);
      for (var i = 0; i < 20 && controller.phase == BreakerPhase.playing; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      if (life == 0) expect(find.text('Ball lost'), findsOneWidget);
    }
    expect(find.text('Game over'), findsOneWidget);

    await tester.tap(find.text('Play again'));
    await tester.pump();
    expect(controller.phase, equals(BreakerPhase.ready));
    expect(find.text('Tap to start'), findsOneWidget);
  });

  testWidgets('a running frame rebuilds nothing, a broken brick updates the header', (tester) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: Builder(builder: const BreakerGameBuilder().build)));
    final controller = _controller(tester)
      ..launch()
      // Far from the bricks, so no brick breaks during the measured frames
      ..debugPlaceBall(y: BreakerGameController.paddleTop - 0.2, directionX: 0, directionY: 1, speed: 0.1);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    final counter = FrameCounter();
    await counter.measure(tester);

    expect(controller.phase, equals(BreakerPhase.playing));
    expect(counter.built, isEmpty);

    // Breaking a brick changes the score: the header rebuilds once
    final brick = controller.bricks.last;
    controller.debugPlaceBall(x: brick.left + brick.width / 2, y: brick.bottom + BreakerGameController.ballRadius + 0.001, directionX: 0, directionY: -1, speed: 0.5);
    await counter.measure(tester, frames: 3);

    expect(controller.score, equals(BreakerGameController.pointsPerBrick));
    expect(counter.buildsOf<BreakerHeader>(), equals(1));
    expect(find.text('${controller.score}'), findsOneWidget);
  });
}
