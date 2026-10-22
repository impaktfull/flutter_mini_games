import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/core/widget/components/button.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_board.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_stats_bar.dart';
import 'package:flutter_mini_games/src/core/widget/components/how_to_play.dart';
import 'package:flutter_mini_games/src/core/widget/provider/game_controller_provider.dart';
import 'package:flutter_mini_games/src/core/widget/screen/game_screen_layout.dart';
import 'package:flutter_mini_games/src/core/widget/screen/screen.dart';
import 'package:flutter_mini_games/src/game/code/game/logic/code_game_controller.dart';
import 'package:flutter_mini_games/src/game/code/screen/code_header.dart';
import 'package:flutter_mini_games/src/game/code/style/code_theme.dart';
import 'package:flutter_mini_games/src/game/code/widget/code_board.dart';
import 'package:flutter_mini_games/src/game/code/widget/code_peg_picker.dart';

class CodeScreen extends StatelessWidget {
  final CoreGameTheme? coreTheme;
  final GameThemeOverride<CodeTheme>? theme;
  final Random? random;

  const CodeScreen({
    this.coreTheme,
    this.theme,
    this.random,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GameControllerProvider(
      create: () => CodeGameController(random: random),
      coreTheme: coreTheme,
      theme: (core) {
        final defaults = CodeTheme.fromCore(core);
        return theme?.call(defaults) ?? defaults;
      },
      builder: (context, controller, theme, coreTheme) => FlutterMiniGamesScreen(
        title: 'Code',
        child: GameScreenLayout(
          header: Column(
            spacing: 8,
            children: [
              CodeHeader(controller: controller),
              GameStatsBar(controller: controller),
            ],
          ),
          boardAspectRatio: CodeBoard.aspectRatio,
          board: GameBoard(
            aspectRatio: CodeBoard.aspectRatio,
            padding: EdgeInsets.all(theme.dimens.boardPadding),
            child: CodeBoard(controller: controller),
          ),
          controls: Column(
            spacing: theme.dimens.keySpacing * 2,
            children: [
              CodePegPicker(controller: controller),
              _buildButtons(controller),
            ],
          ),
          footer: const GameHowToPlay(
            items: [
              GameHowToPlayItem(icon: Icons.touch_app, text: 'Tap a symbol to fill\nthe next slot'),
              GameHowToPlayItem(icon: Icons.backspace_outlined, text: 'Tap a slot\nto clear it'),
              GameHowToPlayItem(icon: Icons.circle, text: 'Right symbol,\nright place'),
              GameHowToPlayItem(icon: Icons.circle_outlined, text: 'Right symbol,\nwrong place'),
              GameHowToPlayItem(icon: Icons.repeat, text: 'Symbols can repeat,\n8 tries to crack it'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtons(CodeGameController controller) {
    if (controller.isFinished) {
      return GameButton(
        onTap: controller.resetGame,
        icon: Icons.replay,
        label: 'New code',
      );
    }
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: [
        GameButton(
          key: const ValueKey('code_clear'),
          onTap: controller.isCurrentGuessEmpty ? null : controller.clearGuess,
          icon: Icons.backspace_outlined,
          label: 'Clear',
        ),
        GameButton(
          key: const ValueKey('code_submit'),
          onTap: controller.canSubmit ? controller.submit : null,
          icon: Icons.check,
          label: 'Submit',
        ),
      ],
    );
  }
}
