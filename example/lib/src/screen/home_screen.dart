import 'package:flutter/material.dart';
import 'package:impaktfull_ui/impaktfull_ui.dart';
import 'package:flutter_mini_games/flutter_mini_games.dart';

class HomeScreen extends StatelessWidget {
  static final List<FlutterMiniGameBuilder> _games = [
    TicTacToeGameBuilder(),
  ];
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ImpaktfullUiScreen(
      title: 'Flutter Mini Games',
      child: ImpaktfullUiListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final game in _games) ...[
            ImpaktfullUiCard(
              padding: EdgeInsets.zero,
              child: ImpaktfullUiListItem(
                title: game.name,
                subtitle: game.description,
                onTap: () => FlutterMiniGamesController().launchGameBuilder(context, game),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
