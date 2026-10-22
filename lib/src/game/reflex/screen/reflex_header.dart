import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/game/reflex/game/logic/reflex_game_controller.dart';
import 'package:flutter_mini_games/src/game/reflex/game/model/reflex_phase.dart';
import 'package:flutter_mini_games/src/game/reflex/style/reflex_theme.dart';

/// Average and the time of every try
class ReflexHeader extends StatelessWidget {
  final ReflexGameController controller;

  const ReflexHeader({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ReflexTheme.of(context);
    final average = controller.averageMs;
    return Column(
      spacing: 4,
      children: [
        // Fixed lines so the board keeps its size when the average appears
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(average == null ? 'Average: -' : 'Average: $average ms', style: theme.textStyles.header),
        ),
        Text(_status(), style: theme.textStyles.status, maxLines: 1, overflow: TextOverflow.ellipsis),
        Row(
          spacing: 6,
          children: [
            for (var i = 0; i < ReflexGameController.tries; i++) Expanded(child: _buildAttempt(theme, i)),
          ],
        ),
      ],
    );
  }

  String _status() {
    if (controller.isGameOver) return 'Score: ${controller.score}';
    if (controller.isReady) return '${ReflexGameController.tries} tries';
    return 'Try ${controller.currentTry} of ${ReflexGameController.tries}';
  }

  Widget _buildAttempt(ReflexTheme theme, int index) {
    final times = controller.times;
    final time = index < times.length ? times[index] : null;
    final isCurrent = controller.isRunning || controller.phase == ReflexPhase.tooEarly ? index == times.length : false;
    final colors = theme.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        color: colors.attempt,
        borderRadius: BorderRadius.circular(theme.dimens.attemptRadius),
        border: Border.all(
          color: isCurrent ? colors.attemptCurrent : colors.attempt,
          width: theme.dimens.attemptBorderWidth,
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('#${index + 1} ms', style: theme.textStyles.attemptLabel),
            Text(
              time == null ? '-' : '$time',
              style: theme.textStyles.attemptValue.copyWith(color: time == null ? colors.attemptEmpty : colors.onAttempt),
            ),
          ],
        ),
      ),
    );
  }
}
