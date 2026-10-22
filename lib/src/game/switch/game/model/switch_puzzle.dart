import 'dart:math';

import 'package:flutter_mini_games/src/game/switch/game/model/switch_solver.dart';

/// A Switch (Lights Out) board: which lights are on at the start and the minimal number of taps (par).
class SwitchPuzzle {
  static const defaultSize = 5;

  /// Number of rows and columns
  final int size;

  /// Bit `row * size + col` is set when that light is on
  final int lights;

  /// Minimal number of taps that turns every light off
  final int par;
  final String? name;

  const SwitchPuzzle._({
    required this.size,
    required this.lights,
    required this.par,
    this.name,
  });

  /// A puzzle from a bitmask of lit cells. Throws an [ArgumentError] when every light is off
  /// or when the board can not be solved.
  factory SwitchPuzzle.fromMask(int lights, {int size = defaultSize, String? name}) {
    if (size < 1 || size > SwitchSolver.maxSize) throw ArgumentError.value(size, 'size', 'must be 1 to ${SwitchSolver.maxSize}');
    if (lights <= 0 || lights >= 1 << (size * size)) throw ArgumentError.value(lights, 'lights', 'must have at least one light on');
    final par = SwitchSolver(size: size).minimalMoves(lights);
    if (par == null) throw ArgumentError.value(lights, 'lights', 'is not solvable');
    return SwitchPuzzle._(size: size, lights: lights, par: par, name: name);
  }

  /// A square puzzle from a string, row by row: `#`, `1` or `x` is on, `.` or `0` is off.
  /// Whitespace is ignored, e.g. `SwitchPuzzle.fromString('.#... ###.. .#... ..... .....')`.
  factory SwitchPuzzle.fromString(String value, {String? name}) {
    final cells = value.replaceAll(RegExp(r'\s'), '');
    final size = sqrt(cells.length).round();
    if (cells.isEmpty || size * size != cells.length) throw ArgumentError.value(value, 'value', 'must describe a square board');
    var lights = 0;
    for (var i = 0; i < cells.length; i++) {
      switch (cells[i]) {
        case '#' || '1' || 'x' || 'X':
          lights |= 1 << i;
        case '.' || '0':
          break;
        default:
          throw ArgumentError.value(value, 'value', 'unknown character "${cells[i]}"');
      }
    }
    return SwitchPuzzle.fromMask(lights, size: size, name: name);
  }

  int get cells => size * size;

  bool isLit(int row, int col) => lights & (1 << (row * size + col)) != 0;
}
