import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/game/whack/game/logic/whack_game_controller.dart';
import 'package:flutter_mini_games/src/game/whack/style/whack_theme.dart';

/// Score, remaining time and a bar with the remaining time
class WhackHeader extends StatelessWidget {
  final WhackGameController controller;

  const WhackHeader({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WhackTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 24,
          runSpacing: 8,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                Icon(Icons.star_rounded, color: theme.colors.critter),
                Text('${controller.score}', style: theme.textStyles.score),
              ],
            ),
            _frame(
              (barColor, remaining) => Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  Icon(Icons.timer_outlined, size: 20, color: barColor),
                  Text('${remaining.ceil()} s', style: theme.textStyles.time),
                ],
              ),
            ),
          ],
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(theme.dimens.timeBarHeight / 2),
            child: SizedBox(
              height: theme.dimens.timeBarHeight,
              width: double.infinity,
              child: ColoredBox(
                color: theme.colors.timeBarTrack,
                child: _frame(
                  (barColor, remaining) => FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: remaining / WhackGameController.roundDuration,
                    child: ColoredBox(color: barColor),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// The time changes every frame: only the parts that show it rebuild and repaint
  Widget _frame(Widget Function(Color barColor, double remaining) builder) {
    return RepaintBoundary(
      child: ListenableBuilder(
        listenable: controller.frame,
        builder: (context, child) {
          final theme = WhackTheme.of(context);
          final remaining = controller.remaining;
          final isLow = remaining <= theme.dimens.lowTimeSeconds && controller.isRunning;
          return builder(isLow ? theme.colors.timeBarLow : theme.colors.timeBar, remaining);
        },
      ),
    );
  }
}
