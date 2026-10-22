import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mini_games/flutter_mini_games.dart';
import 'package:flutter_mini_games/src/game/code/game/logic/code_game_controller.dart';
import 'package:flutter_mini_games/src/game/code/widget/code_board.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  Future<CodeGameController> pump(WidgetTester tester, {Size size = const Size(360, 640), Brightness brightness = Brightness.light}) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: brightness),
        home: Builder(builder: CodeGameBuilder(random: Random(42)).build),
      ),
    );
    return Provider.of<CodeGameController>(tester.element(find.byType(CodeBoard)), listen: false);
  }

  Future<void> submit(WidgetTester tester) async {
    final button = find.byKey(const ValueKey('code_submit'));
    // On short screens the page scrolls (GameScreenLayout.minPageHeight)
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();
  }

  Future<void> tapPegs(WidgetTester tester, List<CodePeg> pegs) async {
    for (final peg in pegs) {
      final key = find.byKey(ValueKey('code_key_${peg.name}'));
      await tester.ensureVisible(key);
      await tester.tap(key);
      await tester.pump();
    }
  }

  testWidgets('picking symbols, clearing a slot and submitting a guess', (tester) async {
    final controller = await pump(tester);
    expect(find.text('Crack the code'), findsOneWidget);
    expect(find.text('8 of 8 tries left'), findsOneWidget);

    await tapPegs(tester, [CodePeg.circle, CodePeg.square, CodePeg.star]);
    expect(controller.currentGuess, equals([CodePeg.circle, CodePeg.square, CodePeg.star, null]));

    // Tap a slot to clear it, the next symbol fills it again
    await tester.ensureVisible(find.byKey(const ValueKey('code_slot_1')));
    await tester.tap(find.byKey(const ValueKey('code_slot_1')));
    await tester.pump();
    expect(controller.currentGuess, equals([CodePeg.circle, null, CodePeg.star, null]));

    await tapPegs(tester, [CodePeg.hexagon, CodePeg.diamond]);
    expect(controller.currentGuess, equals([CodePeg.circle, CodePeg.hexagon, CodePeg.star, CodePeg.diamond]));

    await submit(tester);
    expect(controller.guesses, hasLength(1));
    expect(find.text('7 of 8 tries left'), findsOneWidget);

    await tapPegs(tester, [CodePeg.circle, CodePeg.circle]);
    await tester.ensureVisible(find.byKey(const ValueKey('code_clear')));
    await tester.tap(find.byKey(const ValueKey('code_clear')));
    await tester.pump();
    expect(controller.isCurrentGuessEmpty, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a complete guess can be submitted from its row', (tester) async {
    final controller = await pump(tester, size: const Size(320, 568));
    expect(find.byKey(const ValueKey('code_row_submit')), findsNothing);

    await tapPegs(tester, [CodePeg.triangle, CodePeg.triangle, CodePeg.square, CodePeg.star]);
    final submit = find.byKey(const ValueKey('code_row_submit'));
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pump();

    expect(controller.guesses, hasLength(1));
    expect(find.byKey(const ValueKey('code_row_submit')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cracking the code shows the score and a new code button', (tester) async {
    final controller = await pump(tester, brightness: Brightness.dark);
    await tapPegs(tester, controller.secret);
    await submit(tester);

    expect(controller.isWon, isTrue);
    expect(find.text('Code cracked!'), findsOneWidget);
    expect(find.text('Score: 800 · 1 try'), findsOneWidget);

    await tester.ensureVisible(find.text('New code'));
    await tester.tap(find.text('New code'));
    await tester.pump();
    expect(controller.guesses, isEmpty);
    expect(find.text('Crack the code'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('running out of tries reveals the code, without overflow on a small phone', (tester) async {
    final controller = await pump(tester, size: const Size(320, 568));
    final wrong = [for (final peg in controller.secret) CodePeg.values[(peg.index + 1) % CodePeg.values.length]];
    for (var i = 0; i < CodeGameController.maxTries; i++) {
      await tapPegs(tester, wrong);
      await submit(tester);
    }

    expect(controller.isLost, isTrue);
    expect(find.text('Out of tries'), findsOneWidget);
    expect(find.text('?'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  test('theme copyWith overrides single tokens', () {
    final theme = CodeTheme.fromCore(CoreGameTheme.light());
    final custom = theme.copyWith(
      colors: theme.colors.copyWith(currentRow: theme.colors.row),
      textStyles: theme.textStyles.copyWith(header: theme.textStyles.info),
      dimens: theme.dimens.copyWith(keyHeight: 56),
    );

    expect(custom.colors.currentRow, equals(theme.colors.row));
    expect(custom.colors.pegs, equals(theme.colors.pegs));
    expect(custom.textStyles.header, equals(theme.textStyles.info));
    expect(custom.dimens.keyHeight, equals(56));
    expect(custom.dimens.rowSpacing, equals(theme.dimens.rowSpacing));
  });

  test('peg colors are distinct in light and dark', () {
    for (final core in [CoreGameTheme.light(), CoreGameTheme.dark()]) {
      final pegs = CodeTheme.fromCore(core).colors.pegs;
      expect(pegs, hasLength(CodePeg.values.length));
      expect(pegs.toSet(), hasLength(CodePeg.values.length));
    }
  });
}
