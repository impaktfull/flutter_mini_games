import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/widget/provider/game_controller_provider.dart';
import 'package:flutter_mini_games/src/core/widget/screen/screen.dart';
import 'package:flutter_mini_games/src/game/tic_tac_toe/game/logic/tic_tac_toe_game_controller.dart';
import 'package:flutter_mini_games/src/game/tic_tac_toe/screen/tic_tac_toe_header.dart';
import 'package:flutter_mini_games/src/game/tic_tac_toe/style/tic_tac_toe_theme.dart';
import 'package:flutter_mini_games/src/game/tic_tac_toe/widget/tic_tac_toe_cell.dart';

class TicTacToeScreen extends StatelessWidget {
  final TicTacToeTheme theme;

  const TicTacToeScreen({
    super.key,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GameControllerProvider(
      controller: TicTacToeGameController(),
      theme: theme,
      builder: (context, controller, theme) => FlutterMiniGamesScreen(
        title: 'Tic Tac Toe',
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 32,
            children: [
              TicTacToeHeader(
                controller: controller,
              ),
              Flexible(
                fit: FlexFit.loose,
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                        width: 4,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                      ),
                      itemCount: 9,
                      itemBuilder: (context, index) {
                        final row = index ~/ 3;
                        final col = index % 3;
                        final value = controller.board[row][col];
                        final isWinningCell = controller.isWinningCell(row, col);

                        return TicTacToeCell(
                          onTap: () => controller.makeMove(row, col),
                          value: value,
                          isWinningCell: isWinningCell,
                        );
                      },
                    ),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: controller.resetGame,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset Game'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
