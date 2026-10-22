import 'package:flutter/material.dart';
import 'package:flutter_mini_games/flutter_mini_games.dart';
import 'package:flutter_mini_games/src/game/switch/game/logic/switch_game_controller.dart';
import 'package:flutter_mini_games/src/game/switch/widget/switch_grid.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  final twoCrosses = SwitchPuzzle.fromString('.#... ###.. .#.#. ..### ...#.', name: 'Two crosses');

  Future<SwitchGameController> pump(
    WidgetTester tester, {
    SwitchGameBuilder builder = const SwitchGameBuilder(),
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
        home: Builder(builder: builder.build),
      ),
    );
    return Provider.of<SwitchGameController>(tester.element(find.byType(SwitchGrid)), listen: false);
  }

  testWidgets('tapping the lights solves the puzzle and shows the next puzzle button', (tester) async {
    final controller = await pump(tester, builder: SwitchGameBuilder(puzzles: [twoCrosses]));
    expect(find.text('Two crosses'), findsOneWidget);
    expect(find.text('10'), findsOneWidget); // lights on

    await tester.tap(find.byKey(const ValueKey('switch_cell_1_1')));
    await tester.pumpAndSettle();
    expect(controller.litCount, 5);

    await tester.tap(find.text('Hint'));
    await tester.pumpAndSettle();
    expect(controller.hint, (3, 3));

    await tester.tap(find.byKey(const ValueKey('switch_cell_3_3')));
    await tester.pumpAndSettle();
    expect(controller.isWon, isTrue);
    expect(find.text('Lights out!'), findsOneWidget);
    expect(find.textContaining('solved at par'), findsOneWidget);
    expect(find.text('Next Puzzle'), findsOneWidget);

    await tester.tap(find.text('Next Puzzle'));
    await tester.pumpAndSettle();
    expect(controller.isFinished, isFalse);
    expect(controller.lights, twoCrosses.lights);
    expect(tester.takeException(), isNull);
  });

  testWidgets('switches difficulty with the chips, without overflow on a small dark phone', (tester) async {
    final controller = await pump(tester, brightness: Brightness.dark, size: const Size(320, 568));
    expect(controller.difficulty, SwitchDifficulty.medium);

    await tester.tap(find.byKey(const ValueKey('switch_difficulty_hard')));
    await tester.pumpAndSettle();
    expect(controller.difficulty, SwitchDifficulty.hard);
    expect(tester.takeException(), isNull);
  });

  test('theme copyWith overrides single tokens', () {
    final theme = SwitchGameTheme.fromCore(CoreGameTheme.light());
    final custom = theme.copyWith(
      colors: theme.colors.copyWith(lightOn: theme.colors.hint),
      textStyles: theme.textStyles.copyWith(header: theme.textStyles.status),
      dimens: theme.dimens.copyWith(cellSpacing: 2),
    );

    expect(custom.colors.lightOn, theme.colors.hint);
    expect(custom.colors.lightOff, theme.colors.lightOff);
    expect(custom.textStyles.header, theme.textStyles.status);
    expect(custom.dimens.cellSpacing, 2);
    expect(custom.dimens.glowRadius, theme.dimens.glowRadius);
  });
}
