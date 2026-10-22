import 'package:flutter/material.dart';

/// Entry point of a game. The host app creates the builders of the games it wants to offer.
///
/// Only reference the builders you use: games that are never referenced are not compiled
/// into your app.
abstract class FlutterMiniGameBuilder {
  final String name;
  final String description;

  const FlutterMiniGameBuilder({
    required this.name,
    required this.description,
  });

  /// Stable identifier of the game, used to store results. Never shown to the user.
  String get id;

  bool get isMultiPlayer;

  /// The game screen. Use `FlutterMiniGames.launch` or show it with your own router.
  Widget build(BuildContext context);
}
