import 'package:flutter/painting.dart';
import 'package:flutter_mini_games/src/game/boxes/game/model/boxes_board_geometry.dart';
import 'package:flutter_mini_games/src/game/boxes/game/model/boxes_edge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // 4x4 boxes on 240x240 with an inset of 20: dots every 50 px, starting at (20, 20)
  const geometry = BoxesBoardGeometry(size: Size(240, 240), rows: 4, cols: 4, inset: 20);
  bool allFree(BoxesEdge edge) => true;

  test('dots are spread evenly inside the inset', () {
    expect(geometry.spacing, 50);
    expect(geometry.dot(0, 0), const Offset(20, 20));
    expect(geometry.dot(4, 4), const Offset(220, 220));
    expect(geometry.endsOf(const BoxesEdge.vertical(1, 2)), (const Offset(120, 70), const Offset(120, 120)));
  });

  test('a non-square board centers the grid', () {
    const wide = BoxesBoardGeometry(size: Size(340, 240), rows: 4, cols: 4, inset: 20);
    expect(wide.spacing, 50);
    expect(wide.dot(0, 0), const Offset(70, 20));
  });

  test('a tap between two dots maps to the edge between them', () {
    expect(geometry.edgeAt(const Offset(45, 20), isFree: allFree), const BoxesEdge.horizontal(0, 0));
    expect(geometry.edgeAt(const Offset(20, 45), isFree: allFree), const BoxesEdge.vertical(0, 0));
    expect(geometry.edgeAt(const Offset(195, 220), isFree: allFree), const BoxesEdge.horizontal(4, 3));
    expect(geometry.edgeAt(const Offset(220, 145), isFree: allFree), const BoxesEdge.vertical(2, 4));
  });

  test('the hit area is generous, also outside the outer dots', () {
    // 15 px (0.3 cells) next to the line
    expect(geometry.edgeAt(const Offset(95, 85), isFree: allFree), const BoxesEdge.horizontal(1, 1));
    expect(geometry.edgeAt(const Offset(70 + 18, 95), isFree: allFree), const BoxesEdge.vertical(1, 1));
    // In the inset above the top row
    expect(geometry.edgeAt(const Offset(145, 4), isFree: allFree), const BoxesEdge.horizontal(0, 2));
  });

  test('a tap in the middle of a box or far outside draws nothing', () {
    expect(geometry.edgeAt(const Offset(45, 45), isFree: allFree), isNull);
    expect(geometry.edgeAt(const Offset(145, -40), isFree: allFree), isNull);
  });

  test('taken edges are skipped for the nearest free edge', () {
    const tap = Offset(24, 26); // next to dot (0, 0)
    expect(geometry.edgeAt(tap, isFree: allFree), const BoxesEdge.vertical(0, 0));
    expect(geometry.edgeAt(tap, isFree: (edge) => edge != const BoxesEdge.vertical(0, 0)), const BoxesEdge.horizontal(0, 0));
    expect(geometry.edgeAt(const Offset(45, 30), isFree: (edge) => edge != const BoxesEdge.horizontal(0, 0)), isNull);
  });
}
