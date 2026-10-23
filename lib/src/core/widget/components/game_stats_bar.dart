import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/model/data/game_stats.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/flutter_mini_games.dart';

/// Shows the time, the number of moves and the best score of a game. Shared by all games.
class GameStatsBar extends StatefulWidget {
  final GameController controller;

  const GameStatsBar({
    required this.controller,
    super.key,
  });

  @override
  State<GameStatsBar> createState() => _GameStatsBarState();
}

class _GameStatsBarState extends State<GameStatsBar> {
  Timer? _timer;
  Future<GameStats>? _stats;
  Object? _statsFor;

  @override
  void initState() {
    super.initState();
    // Only ticks the elapsed time, the controller rebuilds this widget on every move
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (widget.controller.status == GameStatus.playing) setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadStats();
  }

  @override
  void didUpdateWidget(covariant GameStatsBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadStats();
  }

  /// Reloads the stats when a session finished
  void _loadStats() {
    final key = widget.controller.result;
    if (_stats != null && identical(key, _statsFor)) return;
    _statsFor = key;
    _stats = FlutterMiniGames.scoreStoreOf(context).stats(widget.controller.gameId);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CoreGameTheme.of(context);
    // The timer repaints the bar every second, not the screen
    return RepaintBoundary(
      child: FutureBuilder<GameStats>(
        future: _stats,
        builder: (context, snapshot) {
          final bestScore = snapshot.data?.bestScore;
          return Wrap(
            alignment: WrapAlignment.center,
            spacing: 24,
            runSpacing: 8,
            children: [
              _buildItem(theme, Icons.timer_outlined, _formatDuration(widget.controller.elapsed)),
              _buildItem(theme, Icons.touch_app_outlined, '${widget.controller.moves}'),
              if (bestScore != null) _buildItem(theme, Icons.emoji_events_outlined, '$bestScore'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildItem(CoreGameTheme theme, IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        Icon(icon, size: 16, color: theme.colors.textMuted),
        Text(value, style: theme.textStyles.caption),
      ],
    );
  }

  static String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
