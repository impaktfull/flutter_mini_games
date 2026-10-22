import 'package:flutter/material.dart';
import 'package:flutter_mini_games/flutter_mini_games.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/game/flip/game/logic/flip_game_controller.dart';
import 'package:flutter_mini_games/src/game/flip/widget/flip_board.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  Future<FlipGameController> pump(
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
        home: Builder(builder: const FlipGameBuilder().build),
      ),
    );
    return Provider.of<FlipGameController>(tester.element(find.byType(FlipBoard)), listen: false);
  }

  Future<void> tapCell(WidgetTester tester, int row, int col) async {
    await tester.tap(find.byKey(ValueKey('flip_cell_${row}_$col')));
    await tester.pumpAndSettle();
  }

  testWidgets('plays a few moves by tapping cells and resets', (tester) async {
    final controller = await pump(tester);
    expect(find.byKey(const ValueKey('flip_hint_2_3')), findsOneWidget);
    expect(find.text('Your turn'), findsOneWidget);
    expect(find.text('Waiting'), findsOneWidget);

    await tapCell(tester, 0, 0); // illegal, ignored
    expect(controller.moves, 0);

    await tapCell(tester, 2, 3);
    expect(controller.cellAt(3, 3), DuelPlayer.bottom);
    expect(controller.currentPlayer, DuelPlayer.top);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('1'), findsWidgets);

    await tapCell(tester, 2, 2);
    expect(controller.cellAt(3, 3), DuelPlayer.top);
    expect(controller.currentPlayer, DuelPlayer.bottom);
    expect(controller.moves, 2);

    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    expect(controller.moves, 0);
    expect(controller.board, FlipGameController.startBoard());
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits a small dark phone without overflow', (tester) async {
    final controller = await pump(tester, brightness: Brightness.dark, size: const Size(320, 568));
    await tapCell(tester, 4, 5);
    expect(controller.moves, 1);
    expect(tester.takeException(), isNull);
  });

  test('theme copyWith overrides single tokens', () {
    final theme = FlipTheme.fromCore(CoreGameTheme.light());
    final custom = theme.copyWith(
      colors: theme.colors.copyWith(topPlayer: theme.colors.cell),
      textStyles: theme.textStyles.copyWith(count: theme.textStyles.status),
      dimens: theme.dimens.copyWith(cellSpacing: 1),
    );

    expect(custom.colors.topPlayer, theme.colors.cell);
    expect(custom.colors.bottomPlayer, theme.colors.bottomPlayer);
    expect(custom.textStyles.count, theme.textStyles.status);
    expect(custom.dimens.cellSpacing, 1);
    expect(custom.dimens.ringWidth, theme.dimens.ringWidth);
  });
}
