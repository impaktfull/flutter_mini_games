import 'package:flutter/material.dart';
import 'package:flutter_mini_games/flutter_mini_games.dart';
import 'package:flutter_mini_games/src/game/boxes/game/logic/boxes_game_controller.dart';
import 'package:flutter_mini_games/src/game/boxes/game/model/boxes_edge.dart';
import 'package:flutter_mini_games/src/game/boxes/widget/boxes_board.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  Future<BoxesGameController> pump(
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
        home: Builder(builder: const BoxesGameBuilder().build),
      ),
    );
    return Provider.of<BoxesGameController>(tester.element(find.byType(BoxesBoard)), listen: false);
  }

  /// Global position of the middle of [edge] on the board
  Offset edgeCenter(WidgetTester tester, BoxesGameController controller, BoxesEdge edge) {
    final paint = find.descendant(of: find.byType(BoxesBoard), matching: find.byType(CustomPaint));
    final box = tester.renderObject<RenderBox>(paint.first);
    final theme = BoxesTheme.fromCore(CoreGameTheme.light());
    final spacing = (box.size.shortestSide - theme.dimens.boardInset * 2) / controller.cols;
    final origin = Offset((box.size.width - spacing * controller.cols) / 2, (box.size.height - spacing * controller.rows) / 2);
    final local = edge.isHorizontal ? Offset(edge.col + 0.5, edge.row.toDouble()) : Offset(edge.col.toDouble(), edge.row + 0.5);
    return box.localToGlobal(origin + local * spacing);
  }

  testWidgets('tapping between two dots draws lines, closing a box claims it', (tester) async {
    final controller = await pump(tester);
    expect(find.text('Your turn'), findsOneWidget);
    expect(find.text('Waiting'), findsOneWidget);

    for (final edge in const [
      BoxesEdge.horizontal(0, 0), // Player 1
      BoxesEdge.horizontal(1, 0), // Player 2
      BoxesEdge.vertical(0, 0), // Player 1
    ]) {
      await tester.tapAt(edgeCenter(tester, controller, edge));
      await tester.pump();
      expect(controller.isDrawn(edge), isTrue);
    }
    expect(controller.moves, 3);
    expect(controller.currentPlayer, DuelPlayer.top);

    // Tapping a drawn line again does nothing
    await tester.tapAt(edgeCenter(tester, controller, const BoxesEdge.horizontal(0, 0)));
    await tester.pump();
    expect(controller.moves, 3);

    await tester.tapAt(edgeCenter(tester, controller, const BoxesEdge.vertical(0, 1)));
    await tester.pump();
    expect(controller.boxOwner(0, 0), DuelPlayer.top);
    expect(controller.currentPlayer, DuelPlayer.top);
    expect(tester.widget<Text>(find.byKey(const ValueKey('boxes_score_top'))).data, '1');
    expect(tester.widget<Text>(find.byKey(const ValueKey('boxes_score_bottom'))).data, '0');
    expect(tester.takeException(), isNull);
  });

  testWidgets('plays a full game to the end and plays again, without overflow on a small dark phone', (tester) async {
    final controller = await pump(tester, brightness: Brightness.dark, size: const Size(320, 568));
    for (final edge in BoxesEdge.all(rows: controller.rows, cols: controller.cols)) {
      await tester.tapAt(edgeCenter(tester, controller, edge));
      await tester.pump();
    }
    expect(controller.isGameOver, isTrue);
    expect(controller.claimedCount, 16);
    expect(find.text('Play Again'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Play Again'));
    await tester.pump();
    expect(controller.lines, isEmpty);
    expect(controller.isFinished, isFalse);
  });

  test('theme copyWith overrides single tokens', () {
    final theme = BoxesTheme.fromCore(CoreGameTheme.light());
    final custom = theme.copyWith(
      colors: theme.colors.copyWith(guide: theme.colors.dot),
      textStyles: theme.textStyles.copyWith(boxSymbol: theme.textStyles.bannerLabel),
      dimens: theme.dimens.copyWith(lineWidth: 8),
    );

    expect(custom.colors.guide, theme.colors.dot);
    expect(custom.colors.bottomPlayer, theme.colors.bottomPlayer);
    expect(custom.textStyles.boxSymbol, theme.textStyles.bannerLabel);
    expect(custom.dimens.lineWidth, 8);
    expect(custom.dimens.dotRadius, theme.dimens.dotRadius);
  });
}
