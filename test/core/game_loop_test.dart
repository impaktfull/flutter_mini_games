import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/controller/realtime_game_controller.dart';
import 'package:flutter_mini_games/src/core/widget/game_loop.dart';
import 'package:flutter_mini_games/src/core/widget/input/game_input_detector.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestRealtimeController extends GameController with RealtimeGameController {
  _TestRealtimeController() : super(gameId: 'test');

  bool _isRunning = false;
  final List<Duration> deltas = [];

  @override
  bool get isRunning => _isRunning;

  set running(bool value) {
    _isRunning = value;
    notifyListeners();
  }

  @override
  void tick(Duration delta) => deltas.add(delta);
}

void main() {
  group('GameLoop', () {
    testWidgets('ticks only while the controller is running', (tester) async {
      final controller = _TestRealtimeController();
      await tester.pumpWidget(GameLoop(controller: controller, child: const SizedBox()));

      await tester.pump(const Duration(milliseconds: 16));
      expect(controller.deltas, isEmpty);

      controller.running = true;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 16));
      expect(controller.deltas, equals([const Duration(milliseconds: 16), const Duration(milliseconds: 16)]));

      controller.running = false;
      await tester.pump(const Duration(milliseconds: 16));
      expect(controller.deltas, hasLength(2));
    });

    testWidgets('clamps long frames to maxDelta', (tester) async {
      final controller = _TestRealtimeController()..running = true;
      await tester.pumpWidget(GameLoop(controller: controller, child: const SizedBox()));

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(controller.deltas.single, equals(GameLoop.maxDelta));
    });

    testWidgets('pauses while the app is in the background', (tester) async {
      final controller = _TestRealtimeController()..running = true;
      await tester.pumpWidget(GameLoop(controller: controller, child: const SizedBox()));
      await tester.pump();

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump(const Duration(milliseconds: 16));
      expect(controller.deltas, isEmpty);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      expect(controller.deltas, hasLength(1));
    });
  });

  group('GameInputDetector', () {
    Widget detector({VoidCallback? onTap, ValueChanged<GameDirection>? onSwipe}) => MaterialApp(
      home: GameInputDetector(onTap: onTap, onSwipe: onSwipe, child: const SizedBox.expand()),
    );

    testWidgets('reports swipes in the dominant direction', (tester) async {
      final swipes = <GameDirection>[];
      await tester.pumpWidget(detector(onSwipe: swipes.add));

      await tester.dragFrom(const Offset(200, 200), const Offset(60, 10));
      await tester.dragFrom(const Offset(200, 200), const Offset(-5, -60));

      expect(swipes, equals([GameDirection.right, GameDirection.up]));
    });

    testWidgets('reports several swipes in one drag', (tester) async {
      final swipes = <GameDirection>[];
      await tester.pumpWidget(detector(onSwipe: swipes.add));

      final gesture = await tester.startGesture(const Offset(200, 200));
      await gesture.moveBy(const Offset(40, 0));
      await gesture.moveBy(const Offset(0, 40));
      await gesture.up();

      expect(swipes, equals([GameDirection.right, GameDirection.down]));
    });

    testWidgets('reports taps and keyboard input', (tester) async {
      var taps = 0;
      await tester.pumpWidget(detector(onTap: () => taps++));

      await tester.tapAt(const Offset(200, 200));
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);

      expect(taps, equals(3));
    });

    testWidgets('reports only the first swipe of a drag when repeatSwipes is false', (tester) async {
      final swipes = <GameDirection>[];
      await tester.pumpWidget(
        MaterialApp(
          home: GameInputDetector(onSwipe: swipes.add, repeatSwipes: false, child: const SizedBox.expand()),
        ),
      );

      final gesture = await tester.startGesture(const Offset(200, 200));
      await gesture.moveBy(const Offset(40, 0));
      await gesture.moveBy(const Offset(40, 0));
      await gesture.up();
      await tester.dragFrom(const Offset(200, 200), const Offset(0, 60));

      expect(swipes, equals([GameDirection.right, GameDirection.down]));
    });

    testWidgets('reports the release of a tap and of the space key', (tester) async {
      final events = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          home: GameInputDetector(
            onTap: () => events.add('down'),
            onRelease: () => events.add('up'),
            child: const SizedBox.expand(),
          ),
        ),
      );

      await tester.tapAt(const Offset(200, 200));
      await tester.sendKeyDownEvent(LogicalKeyboardKey.space);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.space);

      expect(events, equals(['down', 'up', 'down', 'up']));
    });

    testWidgets('reports horizontal holds per half and per key, the last press wins', (tester) async {
      final holds = <GameDirection?>[];
      await tester.pumpWidget(
        MaterialApp(
          home: GameInputDetector(onHorizontalHold: holds.add, child: const SizedBox.expand()),
        ),
      );
      final width = tester.getSize(find.byType(GameInputDetector)).width;

      final left = await tester.startGesture(Offset(width * 0.25, 200));
      final right = await tester.startGesture(Offset(width * 0.75, 200), pointer: 7);
      await right.up();
      await left.up();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowRight);

      expect(
        holds,
        equals([GameDirection.left, GameDirection.right, GameDirection.left, null, GameDirection.right, null]),
      );
    });

    testWidgets('reports where a tap landed', (tester) async {
      final positions = <Offset>[];
      await tester.pumpWidget(
        MaterialApp(
          home: GameInputDetector(onTapAt: positions.add, child: const SizedBox.expand()),
        ),
      );

      await tester.tapAt(const Offset(120, 80));

      expect(positions, equals([const Offset(120, 80)]));
    });

    testWidgets('maps arrow keys to swipes', (tester) async {
      final swipes = <GameDirection>[];
      await tester.pumpWidget(detector(onSwipe: swipes.add));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyS);

      expect(swipes, equals([GameDirection.left, GameDirection.down]));
    });
  });
}
