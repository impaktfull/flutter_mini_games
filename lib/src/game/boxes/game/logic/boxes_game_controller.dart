import 'package:flutter_mini_games/src/core/controller/game_controller.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/core/model/data/game_result.dart';
import 'package:flutter_mini_games/src/game/boxes/game/model/boxes_edge.dart';

/// Dots and boxes for two players on one device, turn based.
///
/// Players take turns drawing a line between two adjacent dots. Completing the fourth
/// side of a box claims it and gives the same player another turn. When every box is
/// claimed the player with the most boxes wins, equal is a draw.
class BoxesGameController extends GameController {
  static const id = 'boxes';

  /// Default number of boxes per row and column (5x5 dots)
  static const defaultSize = 4;

  final int rows;
  final int cols;

  /// Drawn lines and the player who drew them
  final Map<BoxesEdge, DuelPlayer> _lines = {};

  /// Owner per box (row * cols + col), null while unclaimed
  late final List<DuelPlayer?> _boxes = List.filled(rows * cols, null);
  DuelPlayer _currentPlayer = DuelPlayer.bottom;
  BoxesEdge? _lastLine;

  BoxesGameController({this.rows = defaultSize, this.cols = defaultSize}) : super(gameId: id);

  /// The player who draws the next line
  DuelPlayer get currentPlayer => _currentPlayer;

  Map<BoxesEdge, DuelPlayer> get lines => Map.unmodifiable(_lines);

  /// The most recently drawn line, highlighted on the board
  BoxesEdge? get lastLine => _lastLine;

  int get boxCount => rows * cols;

  int get claimedCount => _boxes.where((owner) => owner != null).length;

  bool get isGameOver => isFinished;

  /// The player with the most boxes once the game is over, null while playing or on a draw
  DuelPlayer? get winner => isGameOver ? _leader : null;

  /// The player with the most boxes right now, null when equal
  DuelPlayer? get _leader {
    final bottom = boxesOf(DuelPlayer.bottom);
    final top = boxesOf(DuelPlayer.top);
    if (bottom == top) return null;
    return bottom > top ? DuelPlayer.bottom : DuelPlayer.top;
  }

  bool get isDraw => isGameOver && winner == null;

  bool isDrawn(BoxesEdge edge) => _lines.containsKey(edge);

  DuelPlayer? lineOwner(BoxesEdge edge) => _lines[edge];

  DuelPlayer? boxOwner(int row, int col) => _boxes[row * cols + col];

  /// Number of boxes claimed by [player]
  int boxesOf(DuelPlayer player) => _boxes.where((owner) => owner == player).length;

  /// Draws [edge] for the current player. Returns false when the line can't be drawn
  /// (already drawn, outside the grid or the game is over).
  bool drawLine(BoxesEdge edge) {
    if (isGameOver || isDrawn(edge) || !edge.isInside(rows: rows, cols: cols)) return false;
    final player = _currentPlayer;
    _lines[edge] = player;
    _lastLine = edge;
    registerMove();

    var claimed = 0;
    for (final (row, col) in edge.adjacentBoxes(rows: rows, cols: cols)) {
      if (BoxesEdge.sidesOf(row, col).every(isDrawn)) {
        _boxes[row * cols + col] = player;
        claimed++;
      }
    }
    // Claiming a box gives another turn
    if (claimed == 0) _currentPlayer = player.opponent;

    if (claimedCount == boxCount) _finishGame();
    notifyListeners();
    return true;
  }

  void _finishGame() {
    final boxes = {
      DuelPlayer.bottom.name: boxesOf(DuelPlayer.bottom),
      DuelPlayer.top.name: boxesOf(DuelPlayer.top),
    };
    final winner = _leader;
    if (winner == null) {
      finish(GameOutcome.draw, data: {'boxes': boxes});
    } else {
      finish(GameOutcome.won, data: {'winner': winner.name, 'boxes': boxes});
    }
  }

  void resetGame() {
    _lines.clear();
    _boxes.fillRange(0, _boxes.length, null);
    _currentPlayer = DuelPlayer.bottom;
    _lastLine = null;
    restartSession();
    notifyListeners();
  }
}
