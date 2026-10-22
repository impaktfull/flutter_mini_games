import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/core/widget/provider/game_controller_provider.dart';
import 'package:flutter_mini_games/src/game/twenty_forty_eight/game/logic/twenty_forty_eight_game_controller.dart';
import 'package:flutter_mini_games/src/game/twenty_forty_eight/style/twenty_forty_eight_theme.dart';
import 'package:flutter_mini_games/src/game/twenty_forty_eight/widget/twenty_forty_eight_board.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a long drag makes one move', (tester) async {
    late TwentyFortyEightGameController controller;
    await tester.pumpWidget(
      MaterialApp(
        home: GameControllerProvider(
          create: () => controller = TwentyFortyEightGameController(
            random: Random(1),
            // A second swipe to the left would merge the two 4s
            initialBoard: const [
              [2, 2, 4, 8],
              [0, 0, 0, 0],
              [0, 0, 0, 0],
              [0, 0, 0, 0],
            ],
          ),
          coreTheme: CoreGameTheme.light(),
          theme: TwentyFortyEightTheme.fromCore,
          builder: (context, controller, theme, core) => Scaffold(body: TwentyFortyEightBoard(controller: controller)),
        ),
      ),
    );

    final gesture = await tester.startGesture(tester.getCenter(find.byType(TwentyFortyEightBoard)));
    for (var i = 0; i < 6; i++) {
      await gesture.moveBy(const Offset(-50, 0));
      await tester.pump();
    }
    await gesture.up();
    await tester.pumpAndSettle();

    expect(controller.moves, equals(1));
    expect(controller.board[0].sublist(0, 3), equals([4, 4, 8]));
  });
}
