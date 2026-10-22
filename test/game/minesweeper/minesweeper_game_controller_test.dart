import 'dart:math';

import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';
import 'package:flutter_mini_games/src/game/minesweeper/game/logic/minesweeper_game_controller.dart';
import 'package:flutter_mini_games/src/game/minesweeper/game/model/minesweeper_difficulty.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  List<(int, int)> minesOf(MinesweeperGameController controller) => [
    for (var row = 0; row < controller.rows; row++)
      for (var col = 0; col < controller.cols; col++)
        if (controller.cellAt(row, col).isMine) (row, col),
  ];

  /// Easy board (8x8) with the given mines
  MinesweeperGameController withMines(List<(int, int)> mines) {
    return MinesweeperGameController(difficulty: MinesweeperDifficulty.easy, random: Random(42))..setMines(mines);
  }

  group('MinesweeperDifficulty', () {
    test('fits a portrait phone and has fewer mines than cells', () {
      for (final difficulty in MinesweeperDifficulty.values) {
        expect(difficulty.cols, lessThanOrEqualTo(12));
        expect(difficulty.rows, greaterThanOrEqualTo(difficulty.cols));
        expect(difficulty.safeCells, greaterThan(9));
      }
    });
  });

  group('mine placement', () {
    test('places no mines before the first reveal', () {
      final controller = MinesweeperGameController(random: Random(42));
      expect(controller.minesPlaced, isFalse);
      expect(minesOf(controller), isEmpty);
      expect(controller.status, GameStatus.ready);
    });

    for (final difficulty in MinesweeperDifficulty.values) {
      test('places ${difficulty.mines} mines away from the first tap on ${difficulty.name}', () {
        for (var seed = 0; seed < 20; seed++) {
          final random = Random(seed);
          final controller = MinesweeperGameController(difficulty: difficulty, random: Random(seed));
          final row = random.nextInt(difficulty.rows);
          final col = random.nextInt(difficulty.cols);
          controller.reveal(row, col);

          final mines = minesOf(controller);
          expect(mines, hasLength(difficulty.mines));
          for (final (r, c) in mines) {
            expect((r - row).abs() > 1 || (c - col).abs() > 1, isTrue, reason: 'mine at ($r, $c) next to first tap ($row, $col)');
          }
          expect(controller.isLost, isFalse);
          // The first tap is a zero, so it opens an area
          expect(controller.cellAt(row, col).adjacentMines, 0);
          expect(controller.revealedCount, greaterThan(1));
        }
      });
    }

    test('is reproducible with a seeded Random', () {
      final a = MinesweeperGameController(random: Random(7))..reveal(5, 5);
      final b = MinesweeperGameController(random: Random(7))..reveal(5, 5);
      expect(minesOf(a), equals(minesOf(b)));
    });
  });

  group('neighbour counts', () {
    test('counts mines in all 8 neighbours, also on edges and corners', () {
      final controller = withMines([(0, 0), (0, 1), (1, 0), (2, 2), (7, 7)]);
      expect(controller.cellAt(1, 1).adjacentMines, 4);
      expect(controller.cellAt(0, 2).adjacentMines, 1);
      expect(controller.cellAt(6, 6).adjacentMines, 1);
      expect(controller.cellAt(7, 6).adjacentMines, 1);
      expect(controller.cellAt(4, 4).adjacentMines, 0);
      // A mine counts its neighbouring mines too
      expect(controller.cellAt(0, 0).adjacentMines, 2);
    });
  });

  group('reveal', () {
    test('reveals only the cell when it has adjacent mines', () {
      final controller = withMines([(0, 0)]);
      controller.reveal(1, 1);
      expect(controller.cellAt(1, 1).isRevealed, isTrue);
      expect(controller.revealedCount, 1);
      expect(controller.moves, 1);
    });

    test('flood fills cells without adjacent mines and stops at numbers', () {
      // Wall of mines in column 3: the left side is 3 columns wide
      final controller = withMines([for (var row = 0; row < 8; row++) (row, 3)]);
      controller.reveal(0, 0);

      for (var row = 0; row < 8; row++) {
        expect(controller.cellAt(row, 0).isRevealed, isTrue);
        expect(controller.cellAt(row, 1).isRevealed, isTrue);
        expect(controller.cellAt(row, 2).isRevealed, isTrue);
        expect(controller.cellAt(row, 2).adjacentMines, greaterThan(0));
        expect(controller.cellAt(row, 4).isRevealed, isFalse);
      }
      expect(controller.revealedCount, 24);
      expect(controller.isFinished, isFalse);
    });

    test('flood fill does not reveal flagged cells', () {
      final controller = withMines([(7, 7)]);
      controller.toggleFlag(0, 1);
      controller.reveal(0, 0);
      expect(controller.cellAt(0, 1).isRevealed, isFalse);
      expect(controller.cellAt(0, 1).isFlagged, isTrue);
    });

    test('ignores flagged and revealed cells', () {
      final controller = withMines([(0, 0)]);
      controller.toggleFlag(1, 1);
      controller.reveal(1, 1);
      expect(controller.cellAt(1, 1).isRevealed, isFalse);
      expect(controller.moves, 1);
    });
  });

  group('flagging', () {
    test('toggles flags on hidden cells and updates the remaining mines', () {
      final controller = withMines([(0, 0)]);
      expect(controller.remainingMines, 1);

      controller.toggleFlag(0, 0);
      expect(controller.cellAt(0, 0).isFlagged, isTrue);
      expect(controller.flagCount, 1);
      expect(controller.remainingMines, 0);
      expect(controller.moves, 1);

      controller.toggleFlag(0, 0);
      expect(controller.cellAt(0, 0).isFlagged, isFalse);
      expect(controller.remainingMines, 1);
    });

    test('cannot flag revealed cells', () {
      final controller = withMines([(0, 0)]);
      controller.reveal(1, 1);
      controller.toggleFlag(1, 1);
      expect(controller.cellAt(1, 1).isFlagged, isFalse);
    });

    test('flag mode makes a tap flag instead of reveal', () {
      final controller = withMines([(0, 0)]);
      controller.toggleFlagMode();
      expect(controller.isFlagMode, isTrue);
      controller.tap(0, 0);
      expect(controller.cellAt(0, 0).isFlagged, isTrue);
      expect(controller.isLost, isFalse);

      controller.toggleFlagMode();
      controller.tap(1, 1);
      expect(controller.cellAt(1, 1).isRevealed, isTrue);
    });
  });

  group('chord', () {
    test('reveals the neighbours when the flags match the number', () {
      final controller = withMines([(0, 0), (7, 7)]);
      controller.reveal(1, 1);
      controller.toggleFlag(0, 0);
      controller.tap(1, 1);

      for (final (row, col) in [(0, 1), (0, 2), (1, 0), (1, 2), (2, 0), (2, 1), (2, 2)]) {
        expect(controller.cellAt(row, col).isRevealed, isTrue, reason: '($row, $col)');
      }
      expect(controller.isLost, isFalse);
    });

    test('does nothing when the flags do not match the number', () {
      final controller = withMines([(0, 0), (7, 7)]);
      controller.reveal(1, 1);
      controller.chord(1, 1);
      expect(controller.revealedCount, 1);
      expect(controller.moves, 1);
    });

    test('loses when a flag is wrong', () {
      final controller = withMines([(0, 0), (7, 7)]);
      controller.reveal(1, 1);
      controller.toggleFlag(0, 1);
      controller.chord(1, 1);

      expect(controller.isLost, isTrue);
      expect(controller.cellAt(0, 0).isExploded, isTrue);
    });
  });

  group('lose', () {
    test('revealing a mine loses the game and reports the result', () {
      GameResult? reported;
      final controller = withMines([(0, 0), (0, 2), (7, 7)])..resultListener = (result) => reported = result;
      controller.reveal(4, 4); // opens everything except (0, 1)
      controller.reveal(0, 0);

      expect(controller.isLost, isTrue);
      expect(controller.isFinished, isTrue);
      expect(controller.cellAt(0, 0).isExploded, isTrue);
      expect(controller.cellAt(0, 0).isRevealed, isTrue);
      expect(reported?.gameId, MinesweeperGameController.id);
      expect(reported?.outcome, GameOutcome.lost);
      expect(reported?.score, isNull);
      expect(reported?.moves, 2);
      expect(reported?.data['difficulty'], 'easy');
    });

    test('ignores input after the game is finished', () {
      final controller = withMines([(0, 0)]);
      controller.reveal(0, 0);
      controller.reveal(5, 5);
      controller.toggleFlag(6, 6);
      expect(controller.cellAt(5, 5).isRevealed, isFalse);
      expect(controller.cellAt(6, 6).isFlagged, isFalse);
      expect(controller.moves, 1);
    });
  });

  group('win', () {
    test('revealing all safe cells wins, flags the mines and reports a score', () {
      GameResult? reported;
      final controller = withMines([(0, 0), (0, 2), (7, 7)])..resultListener = (result) => reported = result;
      controller.reveal(4, 4);
      expect(controller.isWon, isFalse);
      // (0, 1) is only surrounded by numbers, so the flood fill does not open it
      for (var row = 0; row < 8; row++) {
        for (var col = 0; col < 8; col++) {
          if (!controller.cellAt(row, col).isMine) controller.reveal(row, col);
        }
      }

      expect(controller.isWon, isTrue);
      expect(controller.revealedCount, 61);
      expect(controller.cellAt(0, 0).isFlagged, isTrue);
      expect(controller.cellAt(7, 7).isFlagged, isTrue);
      expect(reported?.outcome, GameOutcome.won);
      expect(reported?.score, MinesweeperGameController.calculateScore(MinesweeperDifficulty.easy, reported!.duration));
      expect(reported?.score, greaterThan(0));
    });

    test('wins a randomly generated board by revealing every safe cell', () {
      final controller = MinesweeperGameController(difficulty: MinesweeperDifficulty.hard, random: Random(3));
      controller.reveal(8, 6);
      for (var row = 0; row < controller.rows; row++) {
        for (var col = 0; col < controller.cols; col++) {
          if (!controller.cellAt(row, col).isMine) controller.reveal(row, col);
        }
      }
      expect(controller.isWon, isTrue);
      expect(controller.result?.data['mines'], 40);
    });
  });

  group('scoring', () {
    test('rewards difficulty and speed, with a minimum', () {
      int score(MinesweeperDifficulty difficulty, int seconds) => MinesweeperGameController.calculateScore(difficulty, Duration(seconds: seconds));

      expect(score(MinesweeperDifficulty.easy, 0), 1000);
      expect(score(MinesweeperDifficulty.easy, 60), 700);
      expect(score(MinesweeperDifficulty.easy, 10000), 100);
      expect(score(MinesweeperDifficulty.medium, 60), 1700);
      expect(score(MinesweeperDifficulty.hard, 60), 3700);
      expect(score(MinesweeperDifficulty.hard, 60), greaterThan(score(MinesweeperDifficulty.medium, 60)));
      expect(score(MinesweeperDifficulty.medium, 30), greaterThan(score(MinesweeperDifficulty.medium, 60)));
    });
  });

  group('new game', () {
    test('reset starts a new board with new mines', () {
      final controller = withMines([(0, 0)]);
      controller.reveal(0, 0);
      controller.resetGame();

      expect(controller.isFinished, isFalse);
      expect(controller.result, isNull);
      expect(controller.minesPlaced, isFalse);
      expect(controller.revealedCount, 0);
      expect(controller.flagCount, 0);
      expect(controller.moves, 0);
    });

    test('can switch difficulty', () {
      final controller = MinesweeperGameController(difficulty: MinesweeperDifficulty.easy);
      controller.newGame(difficulty: MinesweeperDifficulty.hard);
      expect(controller.difficulty, MinesweeperDifficulty.hard);
      expect(controller.rows, 16);
      expect(controller.cols, 12);
      expect(controller.remainingMines, 40);
    });
  });
}
