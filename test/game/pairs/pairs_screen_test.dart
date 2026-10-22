import 'package:flutter/material.dart';
import 'package:flutter_mini_games/flutter_mini_games.dart';
import 'package:flutter_mini_games/src/game/pairs/game/logic/pairs_game_controller.dart';
import 'package:flutter_mini_games/src/game/pairs/widget/pairs_grid.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  Future<PairsGameController> pump(WidgetTester tester, {Brightness brightness = Brightness.light, Size size = const Size(360, 640)}) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: brightness),
        home: Builder(builder: const PairsGameBuilder().build),
      ),
    );
    return Provider.of<PairsGameController>(tester.element(find.byType(PairsGrid)), listen: false);
  }

  Finder card(int index) => find.byKey(ValueKey('pairs_card_$index'));

  /// Index of the other card with the same value as [index], and a card that doesn't match it
  (int, int) partnerAndOther(PairsGameController controller, int index) {
    final value = controller.valueAt(index);
    final partner = [for (var i = 0; i < controller.cardCount; i++) i].firstWhere((i) => i != index && controller.valueAt(i) == value);
    final other = [for (var i = 0; i < controller.cardCount; i++) i].firstWhere((i) => controller.valueAt(i) != value);
    return (partner, other);
  }

  testWidgets('tapping cards flips them, mismatches turn back and pairs stay open', (tester) async {
    final controller = await pump(tester);
    final (partner, other) = partnerAndOther(controller, 0);

    await tester.tap(card(0));
    await tester.tap(card(other));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(controller.isShowingMismatch, isTrue);

    // Input is blocked while the mismatch is shown
    await tester.tap(card(partner));
    await tester.pump();
    expect(controller.cardAt(partner).isFaceUp, isFalse);

    await tester.pump(PairsGameController.defaultMismatchDelay);
    await tester.pumpAndSettle();
    expect(controller.isShowingMismatch, isFalse);
    expect(controller.cardAt(0).isFaceUp, isFalse);

    await tester.tap(card(0));
    await tester.tap(card(partner));
    await tester.pumpAndSettle();
    expect(controller.pairsFound, 1);
    expect(controller.moves, 2);
    expect(find.text('1 / 8'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the score and play again after winning, without overflow in dark mode', (tester) async {
    final controller = await pump(tester, brightness: Brightness.dark, size: const Size(320, 568));
    final done = <int>{};
    for (var i = 0; i < controller.cardCount; i++) {
      if (done.contains(i)) continue;
      final (partner, _) = partnerAndOther(controller, i);
      done.addAll([i, partner]);
      await tester.tap(card(i));
      await tester.tap(card(partner));
      await tester.pump();
    }
    await tester.pumpAndSettle();

    expect(controller.isWon, isTrue);
    expect(find.textContaining('All pairs found'), findsOneWidget);
    expect(find.text('Play again'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text('Play again'));
    await tester.tap(find.text('Play again'));
    await tester.pumpAndSettle();
    expect(controller.isWon, isFalse);
    expect(controller.pairsFound, 0);
  });

  testWidgets('switches the difficulty', (tester) async {
    final controller = await pump(tester);
    await tester.tap(find.byKey(const ValueKey('pairs_difficulty_hard')));
    await tester.pumpAndSettle();
    expect(controller.cardCount, 30);
    expect(card(29), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('theme copyWith overrides single tokens', () {
    final theme = PairsTheme.fromCore(CoreGameTheme.light());
    final custom = theme.copyWith(
      colors: theme.colors.copyWith(cardBack: theme.colors.cardMismatch),
      textStyles: theme.textStyles.copyWith(status: theme.textStyles.header),
      dimens: theme.dimens.copyWith(cardSpacing: 10),
    );

    expect(custom.colors.cardBack, theme.colors.cardMismatch);
    expect(custom.colors.cardFace, theme.colors.cardFace);
    expect(custom.textStyles.status, theme.textStyles.header);
    expect(custom.dimens.cardSpacing, 10);
    expect(custom.dimens.cardRadius, theme.dimens.cardRadius);
  });
}
