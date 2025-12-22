import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

abstract class GameTheme {
  static T of<T extends GameTheme>(BuildContext context) => Provider.of<T>(
    context,
    listen: false,
  );
  const GameTheme();
}

class CoreGameTheme extends GameTheme {
  final CoreGameColorTheme colors;

  const CoreGameTheme({
    required this.colors,
  });

  static CoreGameTheme getDefault() => const CoreGameTheme(
    colors: CoreGameColorTheme(
      primary: Color(0xFF7d64f2),
      secondary: Color(0xFF1a1a1a),
      background: Colors.white,
      text: Colors.black,
      textInverted: Colors.white,
      onPrimaryText: Colors.white,
    ),
  );
}

class CoreGameColorTheme {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color text;
  final Color textInverted;
  final Color onPrimaryText;

  const CoreGameColorTheme({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.text,
    required this.textInverted,
    required this.onPrimaryText,
  });
}
