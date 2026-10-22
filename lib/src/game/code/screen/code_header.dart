import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/game/code/game/logic/code_game_controller.dart';
import 'package:flutter_mini_games/src/game/code/style/code_theme.dart';

class CodeHeader extends StatelessWidget {
  final CodeGameController controller;

  const CodeHeader({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CodeTheme.of(context);
    final tries = controller.triesUsed;
    final triesLabel = '$tries ${tries == 1 ? 'try' : 'tries'}';

    final (String title, TextStyle titleStyle, String info) = switch (controller) {
      CodeGameController(isWon: true) => ('Code cracked!', theme.textStyles.headerWin, 'Score: ${controller.result?.score ?? 0} · $triesLabel'),
      CodeGameController(isLost: true) => ('Out of tries', theme.textStyles.headerLost, 'The code is shown on top'),
      _ => ('Crack the code', theme.textStyles.header, '${controller.triesLeft} of ${CodeGameController.maxTries} tries left'),
    };

    return Column(
      spacing: 4,
      children: [
        Text(title, textAlign: TextAlign.center, style: titleStyle),
        Text(info, textAlign: TextAlign.center, style: theme.textStyles.info),
      ],
    );
  }
}
