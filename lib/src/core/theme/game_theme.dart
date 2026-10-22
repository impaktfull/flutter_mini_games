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
  final CoreGameTextTheme textStyles;

  static CoreGameTheme of(BuildContext context) => GameTheme.of<CoreGameTheme>(context);

  const CoreGameTheme({
    required this.colors,
    required this.textStyles,
  });

  static CoreGameTheme getDefault() => CoreGameTheme(
    colors: CoreGameColorTheme.getDefault(),
    textStyles: CoreGameTextTheme.getDefault(),
  );
}

class CoreGameColorTheme {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color card;
  final Color card2;
  final Color text;
  final Color textInverted;
  final Color onPrimaryText;

  const CoreGameColorTheme({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.card,
    required this.card2,
    required this.text,
    required this.textInverted,
    required this.onPrimaryText,
  });

  static CoreGameColorTheme getDefault() => const CoreGameColorTheme(
    primary: Color(0xFF7d64f2),
    secondary: Color(0xFF1a1a1a),
    background: Color(0xFFF5F5F5),
    card: Colors.white,
    card2: Colors.white,
    text: Colors.black,
    textInverted: Colors.white,
    onPrimaryText: Colors.white,
  );
}

class CoreGameTextTheme {
  final TextStyle title;
  final TextStyle body;

  const CoreGameTextTheme({
    required this.title,
    required this.body,
  });

  static CoreGameTextTheme getDefault() => const CoreGameTextTheme(
    title: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    body: TextStyle(
      fontSize: 16,
      color: Colors.black,
    ),
  );
}
