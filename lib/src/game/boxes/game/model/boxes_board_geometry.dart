import 'dart:math';
import 'dart:ui';

import 'package:flutter_mini_games/src/game/boxes/game/model/boxes_edge.dart';

/// Positions of the dots on a board of [size] and the mapping of a tap to an edge.
///
/// The dots are spread evenly with [inset] around them, so the outer dots and lines
/// are not cut off by the board edge.
class BoxesBoardGeometry {
  /// A tap counts for an edge when it is at most this far (in cells) from it.
  /// Below 0.5, so a tap in the middle of a box draws nothing instead of a random side.
  static const maxTapDistance = 0.42;

  final Size size;
  final int rows;
  final int cols;
  final double inset;

  const BoxesBoardGeometry({
    required this.size,
    required this.rows,
    required this.cols,
    required this.inset,
  });

  /// Distance between two adjacent dots
  double get spacing => min((size.width - inset * 2) / cols, (size.height - inset * 2) / rows);

  Offset get _origin => Offset((size.width - spacing * cols) / 2, (size.height - spacing * rows) / 2);

  /// Center of dot (row, col)
  Offset dot(int row, int col) => _origin + Offset(col * spacing, row * spacing);

  /// Both end dots of [edge]
  (Offset, Offset) endsOf(BoxesEdge edge) => (dot(edge.row, edge.col), edge.isHorizontal ? dot(edge.row, edge.col + 1) : dot(edge.row + 1, edge.col));

  /// Area of box (row, col)
  Rect box(int row, int col) => Rect.fromPoints(dot(row, col), dot(row + 1, col + 1));

  /// The nearest edge to [position] for which [isFree] is true, or null when no free edge
  /// is within [maxTapDistance]. Taken edges are skipped, so a tap close to a drawn line
  /// still finds the free line next to it.
  BoxesEdge? edgeAt(Offset position, {required bool Function(BoxesEdge edge) isFree}) {
    if (spacing <= 0) return null;
    final local = (position - _origin) / spacing;
    BoxesEdge? nearest;
    var nearestDistance = maxTapDistance;
    for (final edge in BoxesEdge.all(rows: rows, cols: cols)) {
      if (!isFree(edge)) continue;
      final distance = _distanceToEdge(local, edge);
      if (distance <= nearestDistance) {
        nearest = edge;
        nearestDistance = distance;
      }
    }
    return nearest;
  }

  /// Distance from [point] (in cells) to the segment of [edge]
  static double _distanceToEdge(Offset point, BoxesEdge edge) {
    if (edge.isHorizontal) {
      final dx = point.dx < edge.col ? edge.col - point.dx : max(0.0, point.dx - (edge.col + 1));
      return Offset(dx, point.dy - edge.row).distance;
    }
    final dy = point.dy < edge.row ? edge.row - point.dy : max(0.0, point.dy - (edge.row + 1));
    return Offset(point.dx - edge.col, dy).distance;
  }
}
