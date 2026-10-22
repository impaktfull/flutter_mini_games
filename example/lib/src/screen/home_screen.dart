import 'package:flutter/material.dart';
import 'package:flutter_mini_games/flutter_mini_games.dart';
import 'package:impaktfull_ui/impaktfull_ui.dart';

class HomeScreen extends StatefulWidget {
  // Only the games referenced here are compiled into the app
  static const List<FlutterMiniGameBuilder> games = [
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
    SwitchGameBuilder(),
    CodeGameBuilder(),
    EchoGameBuilder(),
    PairsGameBuilder(),
    WhackGameBuilder(),
    ReflexGameBuilder(),
    PuckGameBuilder(),
  ];

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _play(FlutterMiniGameBuilder game) async {
    // Named route, so every game has its own link (e.g. #/snake)
    await Navigator.of(context).pushNamed('/${game.id}');
    // Refresh the best scores
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final singlePlayer = HomeScreen.games.where((game) => !game.isMultiPlayer);
    final twoPlayers = HomeScreen.games.where((game) => game.isMultiPlayer);
    return ImpaktfullUiScreen(
      title: 'Flutter Mini Games',
      child: ImpaktfullUiListView(
        padding: const EdgeInsets.all(16),
        spacing: 8,
        children: [
          const ImpaktfullUiSectionTitle(title: 'Single player'),
          for (final game in singlePlayer) _GameItem(game: game, onTap: () => _play(game)),
          const ImpaktfullUiSectionTitle(title: 'Two players on one device'),
          for (final game in twoPlayers) _GameItem(game: game, onTap: () => _play(game)),
        ],
      ),
    );
  }
}

class _GameItem extends StatelessWidget {
  final FlutterMiniGameBuilder game;
  final VoidCallback onTap;

  const _GameItem({
    required this.game,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GameStats>(
      future: FlutterMiniGames.scoreStoreOf(context).stats(game.id),
      builder: (context, snapshot) {
        final stats = snapshot.data;
        final bestScore = stats?.bestScore;
        final details = [
          if (bestScore != null) 'Best: $bestScore',
          if (stats != null && stats.played > 0) 'Played: ${stats.played}',
        ].join(' · ');
        return ImpaktfullUiCard(
          padding: EdgeInsets.zero,
          child: ImpaktfullUiListItem(
            title: game.name,
            subtitle: details.isEmpty ? game.description : '${game.description}\n$details',
            onTap: onTap,
          ),
        );
      },
    );
  }
}
