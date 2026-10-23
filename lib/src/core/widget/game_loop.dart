import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mini_games/src/core/controller/realtime_game_controller.dart';

/// Calls [RealtimeGameController.tick] every frame while the controller is running
/// and the app is in the foreground.
class GameLoop extends StatefulWidget {
  /// Longest step passed to `tick`, avoids objects jumping after a hitch
  static const maxDelta = Duration(milliseconds: 50);

  final RealtimeGameController controller;
  final Widget child;

  const GameLoop({
    required this.controller,
    required this.child,
    super.key,
  });

  @override
  State<GameLoop> createState() => _GameLoopState();
}

class _GameLoopState extends State<GameLoop> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final Ticker _ticker = createTicker(_onTick);
  Duration _lastElapsed = Duration.zero;
  bool _isAppActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.controller.addListener(_sync);
    _sync();
  }

  @override
  void didUpdateWidget(covariant GameLoop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller.removeListener(_sync);
    widget.controller.addListener(_sync);
    _sync();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isAppActive = state == AppLifecycleState.resumed;
    _sync();
  }

  /// Starts or stops the ticker so no frames are scheduled while nothing moves
  void _sync() {
    final shouldRun = widget.controller.isRunning && _isAppActive;
    if (shouldRun && !_ticker.isActive) {
      _lastElapsed = Duration.zero;
      unawaited(_ticker.start());
    } else if (!shouldRun && _ticker.isActive) {
      _ticker.stop();
    }
  }

  void _onTick(Duration elapsed) {
    final delta = elapsed - _lastElapsed;
    _lastElapsed = elapsed;
    if (delta <= Duration.zero) return;
    widget.controller.tick(delta > GameLoop.maxDelta ? GameLoop.maxDelta : delta);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.controller.removeListener(_sync);
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
