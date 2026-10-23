import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Counts the widgets that are built and the render objects that are painted while frames
/// are pumped.
///
/// Uses the framework's debug hooks, [measure] unsets them again before it returns.
class FrameCounter {
  final List<Widget> built = [];
  int painted = 0;

  /// Pumps [frames] frames of [frameDuration] while counting
  Future<void> measure(WidgetTester tester, {int frames = 10, Duration frameDuration = const Duration(milliseconds: 16)}) async {
    built.clear();
    painted = 0;
    debugOnRebuildDirtyWidget = (element, builtOnce) => built.add(element.widget);
    debugOnProfilePaint = (renderObject) => painted++;
    try {
      for (var i = 0; i < frames; i++) {
        await tester.pump(frameDuration);
      }
    } finally {
      debugOnRebuildDirtyWidget = null;
      debugOnProfilePaint = null;
    }
  }

  /// Number of builds of widgets of type [T]
  int buildsOf<T extends Widget>() => built.whereType<T>().length;
}
