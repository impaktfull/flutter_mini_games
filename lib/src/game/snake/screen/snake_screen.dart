import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/core/widget/components/button.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_board.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_overlay.dart';
import 'package:flutter_mini_games/src/core/widget/components/game_stats_bar.dart';
import 'package:flutter_mini_games/src/core/widget/components/how_to_play.dart';
import 'package:flutter_mini_games/src/core/widget/game_loop.dart';
import 'package:flutter_mini_games/src/core/widget/input/game_input_detector.dart';
import 'package:flutter_mini_games/src/core/widget/provider/game_controller_provider.dart';
import 'package:flutter_mini_games/src/core/widget/screen/screen.dart';
import 'package:flutter_mini_games/src/game/snake/game/logic/snake_game_controller.dart';
import 'package:flutter_mini_games/src/game/snake/screen/snake_header.dart';
import 'package:flutter_mini_games/src/game/snake/style/snake_theme.dart';
import 'package:flutter_mini_games/src/game/snake/widget/snake_board.dart';

class SnakeScreen extends StatelessWidget {
  final CoreGameTheme? coreTheme;
  final GameThemeOverride<SnakeTheme>? theme;
  final int gridSize;

  const SnakeScreen({
    required this.gridSize,
    this.coreTheme,
    this.theme,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GameControllerProvider(
      create: () => SnakeGameController(gridSize: gridSize),
      coreTheme: coreTheme,
      theme: (core) {
        final defaults = SnakeTheme.fromCore(core);
        return theme?.call(defaults) ?? defaults;
      },
      builder: (context, controller, theme, coreTheme) => FlutterMiniGamesScreen(
        title: 'Snake',
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16,
          children: [
            SnakeHeader(controller: controller),
            GameStatsBar(controller: controller),
            Flexible(
              child: GameBoard(
                child: GameLoop(
                  controller: controller,
                  child: GameInputDetector(
                    onSwipe: controller.changeDirection,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        SnakeBoard(controller: controller),
                        ?_buildOverlay(controller),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            GameButton(
              onTap: controller.status == GameStatus.ready ? null : controller.resetGame,
              icon: Icons.refresh,
              label: controller.isFinished ? 'Play again' : 'Restart',
            ),
            const GameHowToPlay(
              items: [
                GameHowToPlayItem(icon: Icons.swipe, text: 'Swipe or use the\narrow keys to turn'),
                GameHowToPlayItem(icon: Icons.restaurant, text: 'Eat to grow,\navoid walls and yourself'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildOverlay(SnakeGameController controller) {
    if (controller.status == GameStatus.ready) {
      return const GameOverlay(title: 'Swipe to start', subtitle: 'or press an arrow key');
    }
    if (controller.isWon) {
      return GameOverlay(title: 'You filled the board!', subtitle: 'Score: ${controller.score}');
    }
    if (controller.isLost) {
      return GameOverlay(title: 'Game over', subtitle: 'Score: ${controller.score}');
    }
    return null;
  }
}
