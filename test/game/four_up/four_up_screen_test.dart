import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mini_games/flutter_mini_games.dart';
import 'package:flutter_mini_games/src/game/four_up/game/logic/four_up_game_controller.dart';
import 'package:flutter_mini_games/src/game/four_up/widget/four_up_board.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  Future<FourUpGameController> pump(
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
        home: Builder(builder: const FourUpGameBuilder().build),
      ),
    );
    return Provider.of<FourUpGameController>(tester.element(find.byType(FourUpBoard)), listen: false);
  }

  /// Taps the middle of [col] on the board
  Future<void> tapColumn(WidgetTester tester, int col) async {
    final board = tester.getRect(find.byType(FourUpBoard));
    final x = board.left + board.width * (col + 0.5) / FourUpGameController.columns;
    await tester.tapAt(Offset(x, board.center.dy));
    await tester.pumpAndSettle();
  }

  testWidgets('tapping columns drops discs until four in a row wins', (tester) async {
    final controller = await pump(tester);
    expect(find.text('Player 1 · Your turn'), findsOneWidget);
    expect(find.text('Player 2 · Waiting…'), findsOneWidget);

    await tapColumn(tester, 2);
    expect(controller.cellAt(2, FourUpGameController.rows - 1), DuelPlayer.bottom);
    expect(find.text('Player 2 · Your turn'), findsOneWidget);

    for (final col in [6, 2, 6, 2, 6]) {
      await tapColumn(tester, col);
    }
    expect(controller.cellAt(6, FourUpGameController.rows - 3), DuelPlayer.top);

    await tapColumn(tester, 2);
    expect(controller.winner, DuelPlayer.bottom);
    expect(controller.result?.data['winner'], 'bottom');
    expect(find.text('Player 1 · You win!'), findsOneWidget);
    expect(find.text('Player 2 · You lose'), findsOneWidget);

    await tester.tap(find.text('Play Again'));
    await tester.pumpAndSettle();
    expect(controller.moves, 0);
    expect(controller.currentPlayer, DuelPlayer.top);
    expect(find.text('Player 2 · Your turn'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('arrow keys select a column, arrow down / space / enter drop, without overflow on a small dark phone', (tester) async {
    final controller = await pump(tester, brightness: Brightness.dark, size: const Size(320, 568));

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(controller.selectedColumn, 4);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(controller.cellAt(4, FourUpGameController.rows - 1), DuelPlayer.bottom);

    // Space and enter drop in the selected column too
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(controller.cellAt(3, FourUpGameController.rows - 1), DuelPlayer.top);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(controller.cellAt(3, FourUpGameController.rows - 2), DuelPlayer.bottom);
    expect(tester.takeException(), isNull);
  });

  test('theme copyWith overrides single tokens', () {
    final theme = FourUpTheme.fromCore(CoreGameTheme.light());
    final custom = theme.copyWith(
      colors: theme.colors.copyWith(topDisc: theme.colors.winHighlight),
      dimens: theme.dimens.copyWith(boardPadding: 8),
    );

    expect(custom.colors.topDisc, theme.colors.winHighlight);
    expect(custom.colors.bottomDisc, theme.colors.bottomDisc);
    expect(custom.dimens.boardPadding, 8);
    expect(custom.dimens.winRingWidth, theme.dimens.winRingWidth);
  });
}
