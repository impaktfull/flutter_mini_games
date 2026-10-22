import 'package:flutter/material.dart';

/// The symbols of the tiles and the target: Material icons with clearly different shapes.
/// Needs at least `SnatchGameController.symbolCount` icons.
abstract final class SnatchSymbols {
  static const icons = <IconData>[
    Icons.star,
    Icons.favorite,
    Icons.bolt,
    Icons.pets,
    Icons.anchor,
    Icons.local_florist,
  ];

  static IconData of(int symbol) => icons[symbol % icons.length];
}
