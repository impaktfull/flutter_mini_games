import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/controller/realtime_game_controller.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_board.dart';
import 'package:flutter_mini_games/src/core/widget/game_loop.dart';
import 'package:flutter_mini_games/src/core/widget/provider/game_controller_provider.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestTheme extends GameTheme {
  const _TestTheme();
}

class _TestController extends GameController with RealtimeGameController {
  /// Whether every frame is reported as a state change (the old behaviour)
  final bool notifyStateEveryFrame;
  double position = 0;
  int score = 0;

  _TestController({required this.notifyStateEveryFrame}) : super(gameId: 'test');

  @override
  bool get isRunning => status == GameStatus.playing;

  void start() {
    startSession();
    notifyListeners();
  }

  void stop() {
    restartSession();
    notifyListeners();
  }

  void addPoint() {
    score++;
    notifyListeners();
  }

  @override
  void tick(Duration delta) {
    position += delta.inMicroseconds / Duration.microsecondsPerSecond;
    if (notifyStateEveryFrame) {
      notifyListeners();
    } else {
      notifyFrame();
    }
  }
}

class _Counts {
  int screen = 0;
  int header = 0;
  int liveValue = 0;
  int paints = 0;
}

class _Painter extends CustomPainter {
  final _TestController controller;
  final _Counts counts;

  _Painter({required this.controller, required this.counts}) : super(repaint: controller.frame);

  @override
  void paint(Canvas canvas, Size size) {
    counts.paints++;
    canvas.drawCircle(Offset(controller.position * 10, size.height / 2), 4, Paint());
  }

  @override
  bool shouldRepaint(covariant _Painter oldDelegate) => oldDelegate.controller != controller;
}

class _Header extends StatelessWidget {
  final _TestController controller;
  final _Counts counts;

  const _Header({required this.controller, required this.counts});

  @override
  Widget build(BuildContext context) {
    counts.header++;
    return Column(
      children: [
        Text('Score ${controller.score}'),
        // A value that changes every frame, scoped to the frame notifications
        ListenableBuilder(
          listenable: controller.frame,
          builder: (context, child) {
            counts.liveValue++;
            return Text('Position ${controller.position.toStringAsFixed(2)}');
          },
        ),
      ],
    );
  }
}

Future<(_TestController, _Counts)> _pump(WidgetTester tester, {required bool notifyStateEveryFrame}) async {
  final counts = _Counts();
  late _TestController controller;
  await tester.pumpWidget(
    MaterialApp(
      home: GameControllerProvider<_TestController, _TestTheme>(
        create: () => controller = _TestController(notifyStateEveryFrame: notifyStateEveryFrame),
        theme: (core) => const _TestTheme(),
        builder: (context, controller, theme, coreTheme) {
          counts.screen++;
          return Column(
            children: [
              _Header(controller: controller, counts: counts),
              Expanded(
                child: GameBoard(
                  child: GameLoop(
                    controller: controller,
                    child: CustomPaint(
                      painter: _Painter(controller: controller, counts: counts),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
  return (controller, counts);
}

void main() {
  group('RealtimeGameController frame notifications', () {
    testWidgets('a frame repaints the board without rebuilding the screen', (tester) async {
      final (controller, counts) = await _pump(tester, notifyStateEveryFrame: false);
      controller.start();
      await tester.pump();
      final screen = counts.screen;
      final header = counts.header;
      final liveValue = counts.liveValue;
      final paints = counts.paints;

      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      expect(controller.position, greaterThan(0));
      expect(counts.screen, equals(screen));
      expect(counts.header, equals(header));
      expect(counts.liveValue, equals(liveValue + 10));
      expect(counts.paints, equals(paints + 10));
      expect(find.text('Position ${controller.position.toStringAsFixed(2)}'), findsOneWidget);
    });

    testWidgets('notifyListeners rebuilds the screen and repaints the board', (tester) async {
      final (controller, counts) = await _pump(tester, notifyStateEveryFrame: false);
      controller.start();
      await tester.pump();
      final screen = counts.screen;
      final paints = counts.paints;

      controller.addPoint();
      await tester.pump();

      expect(counts.screen, equals(screen + 1));
      expect(counts.paints, equals(paints + 1));
      expect(find.text('Score 1'), findsOneWidget);
    });

    testWidgets('notifying state every frame rebuilds the whole screen every frame', (tester) async {
      final (controller, counts) = await _pump(tester, notifyStateEveryFrame: true);
      controller.start();
      await tester.pump();
      final screen = counts.screen;
      final header = counts.header;

      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      expect(counts.screen, equals(screen + 10));
      expect(counts.header, equals(header + 10));
    });

    testWidgets('the game loop still stops on a state change', (tester) async {
      final (controller, _) = await _pump(tester, notifyStateEveryFrame: false);
      controller.start();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      expect(tester.binding.hasScheduledFrame, isTrue);

      controller.stop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    test('the frame notifier is disposed with the controller', () {
      final controller = _TestController(notifyStateEveryFrame: false);
      var frames = 0;
      controller.frame.addListener(() => frames++);
      controller.start();
      expect(frames, equals(1));

      controller.dispose();
      expect(() => controller.frame.addListener(() {}), throwsFlutterError);
    });
  });
}
