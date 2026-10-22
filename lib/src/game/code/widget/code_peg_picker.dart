import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/game/code/game/logic/code_game_controller.dart';
import 'package:flutter_mini_games/src/game/code/game/model/code_peg.dart';
import 'package:flutter_mini_games/src/game/code/style/code_theme.dart';
import 'package:flutter_mini_games/src/game/code/widget/code_peg_shape.dart';

/// One key per symbol: a tap puts it in the next empty slot of the current guess
class CodePegPicker extends StatelessWidget {
  final CodeGameController controller;

  const CodePegPicker({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CodeTheme.of(context);
    final isEnabled = !controller.isFinished && !controller.isCurrentGuessComplete;
    return Row(
      spacing: theme.dimens.keySpacing,
      children: [
        for (final peg in CodePeg.values)
          Expanded(
            child: Opacity(
              opacity: isEnabled ? 1 : 0.4,
              child: GestureDetector(
                key: ValueKey('code_key_${peg.name}'),
                behavior: HitTestBehavior.opaque,
                onTap: isEnabled ? () => controller.addPeg(peg) : null,
                child: Container(
                  height: theme.dimens.keyHeight,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colors.key,
                    borderRadius: BorderRadius.circular(theme.dimens.keyRadius),
                  ),
                  child: CodePegShape(peg: peg, color: theme.colors.peg(peg)),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
