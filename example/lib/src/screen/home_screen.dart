import 'package:flutter/material.dart';
import 'package:impaktfull_ui/impaktfull_ui.dart';
import 'package:flutter_mini_games/flutter_mini_games.dart';

class HomeScreen extends StatelessWidget {
  // Only the games referenced here are compiled into the app
  static const List<FlutterMiniGameBuilder> _games = [
    TicTacToeGameBuilder(),
    TrailGameBuilder(),
    SudokuGameBuilder(),
    StackGameBuilder(),
    DashGameBuilder(),
    FlitGameBuilder(),
    HopGameBuilder(),
    MinesweeperGameBuilder(),
    SnakeGameBuilder(),
    TwentyFortyEightGameBuilder(),
    EchoGameBuilder(),
  ];
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ImpaktfullUiScreen(
      title: 'Flutter Mini Games',
      child: ImpaktfullUiListView(
        padding: const EdgeInsets.all(16),
        spacing: 8,
        children: [
          for (final game in _games) ...[
            ImpaktfullUiCard(
              padding: EdgeInsets.zero,
              child: ImpaktfullUiListItem(
                title: game.name,
                subtitle: game.description,
                onTap: () => FlutterMiniGames.launch(context, game),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
