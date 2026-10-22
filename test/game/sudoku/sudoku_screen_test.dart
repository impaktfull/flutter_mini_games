import 'package:flutter/material.dart';
import 'package:flutter_mini_games/flutter_mini_games.dart';
import 'package:flutter_mini_games/src/game/sudoku/game/logic/sudoku_game_controller.dart';
import 'package:flutter_mini_games/src/game/sudoku/widget/sudoku_board.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

const classic = '53..7....6..195....98....6.8...6...34..8.3..17...2...6.6....28....419..5....8..79';

void main() {
  final puzzle = SudokuPuzzle.fromString(classic, name: 'Classic');

  Future<SudokuGameController> pump(WidgetTester tester, {Brightness brightness = Brightness.light}) async {
    // Small phone
    tester.view
      ..physicalSize = const Size(360, 640)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: brightness),
        home: Builder(builder: SudokuGameBuilder(puzzles: [puzzle]).build),
      ),
    );
    return Provider.of<SudokuGameController>(tester.element(find.byType(SudokuBoard)), listen: false);
  }

  testWidgets('tapping a cell and a digit enters it', (tester) async {
    final controller = await pump(tester);

    await tester.tap(find.byKey(const ValueKey('sudoku_cell_0_2')));
    await tester.pump();
    expect(controller.selected, equals((0, 2)));

    await tester.tap(find.byKey(const ValueKey('sudoku_key_4')));
    await tester.pump();
    expect(controller.valueAt(0, 2), equals(4));

    await tester.tap(find.byKey(const ValueKey('sudoku_cell_0_3')));
    await tester.tap(find.byKey(const ValueKey('sudoku_key_notes')));
    await tester.tap(find.byKey(const ValueKey('sudoku_key_1')));
    await tester.pump();
    expect(controller.notesAt(0, 3), equals({1}));

    await tester.tap(find.byKey(const ValueKey('sudoku_key_erase')));
    await tester.pump();
    expect(controller.notesAt(0, 3), isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows next puzzle after winning, without overflow in dark mode', (tester) async {
    final controller = await pump(tester, brightness: Brightness.dark);
    for (var row = 0; row < 9; row++) {
      for (var col = 0; col < 9; col++) {
        if (controller.valueAt(row, col) != 0) continue;
        controller
          ..select(row, col)
          ..enterDigit(puzzle.solutionAt(row, col));
      }
    }
    await tester.pump();

    expect(controller.isWon, isTrue);
    expect(find.text('Next Puzzle'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('theme copyWith overrides single tokens', () {
    final theme = SudokuTheme.fromCore(CoreGameTheme.light());
    final custom = theme.copyWith(
      colors: theme.colors.copyWith(cellSelected: theme.colors.boxLine),
      textStyles: theme.textStyles.copyWith(given: theme.textStyles.entry),
      dimens: theme.dimens.copyWith(boxLineWidth: 4),
    );

    expect(custom.colors.cellSelected, equals(theme.colors.boxLine));
    expect(custom.colors.cell, equals(theme.colors.cell));
    expect(custom.textStyles.given, equals(theme.textStyles.entry));
    expect(custom.dimens.boxLineWidth, equals(4));
    expect(custom.dimens.gridLineWidth, equals(theme.dimens.gridLineWidth));
  });
}
