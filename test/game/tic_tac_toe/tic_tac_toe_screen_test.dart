import 'package:flutter/material.dart';
import 'package:flutter_mini_games/flutter_mini_games.dart';
import 'package:flutter_mini_games/src/game/tic_tac_toe/game/logic/tic_tac_toe_game_controller.dart';
import 'package:flutter_mini_games/src/game/tic_tac_toe/widget/tic_tac_toe_board.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  Future<TicTacToeGameController> pump(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
    Size size = const Size(360, 640),
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: brightness),
        home: Builder(builder: const TicTacToeGameBuilder().build),
      ),
    );
    return Provider.of<TicTacToeGameController>(tester.element(find.byType(TicTacToeBoard)), listen: false);
  }

  Future<void> tapCell(WidgetTester tester, int row, int col) async {
    await tester.tap(find.byKey(ValueKey('tic_tac_toe_cell_${row}_$col')));
    await tester.pump();
  }

  testWidgets('taps map to cells, banners follow the turns and the winner', (tester) async {
    final controller = await pump(tester);
    expect(find.text('Player 1 · Your turn'), findsOneWidget);
    expect(find.text('Player 2 · Waiting…'), findsOneWidget);

    await tapCell(tester, 2, 1);
    expect(controller.cellAt(2, 1), DuelPlayer.bottom);
    expect(find.text('Player 2 · Your turn'), findsOneWidget);

    // Bottom takes the first column, top the second
    for (final (row, col) in [(0, 1), (0, 0), (1, 1)]) {
      await tapCell(tester, row, col);
    }
    expect(controller.cellAt(1, 1), DuelPlayer.top);
    await tapCell(tester, 1, 0);
    await tapCell(tester, 2, 2);
    await tapCell(tester, 2, 0);

    expect(controller.winner, DuelPlayer.bottom);
    expect(controller.result?.data['winner'], 'bottom');
    expect(find.text('Player 1 · You win!'), findsOneWidget);
    expect(find.text('Player 2 · You lose'), findsOneWidget);

    await tester.tap(find.text('Play Again'));
    await tester.pump();
    expect(controller.moves, 0);
    expect(find.text('Player 1 · Your turn'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits on a small dark phone', (tester) async {
    final controller = await pump(tester, brightness: Brightness.dark, size: const Size(320, 568));

    await tapCell(tester, 0, 2);
    expect(controller.cellAt(0, 2), DuelPlayer.bottom);
    expect(tester.takeException(), isNull);
  });

  test('theme copyWith overrides single tokens', () {
    final theme = TicTacToeTheme.fromCore(CoreGameTheme.light());
    final custom = theme.copyWith(colors: theme.colors.copyWith(topPlayer: theme.colors.cellBackground));

    expect(custom.colors.topPlayer, theme.colors.cellBackground);
    expect(custom.colors.playerColor(DuelPlayer.top), theme.colors.cellBackground);
    expect(custom.colors.bottomPlayer, theme.colors.bottomPlayer);
  });
}
