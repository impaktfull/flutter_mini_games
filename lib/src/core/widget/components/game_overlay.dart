import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';

/// Message on top of the playing field, e.g. "Tap to start" or "Game over".
/// Shared by all games. Ignores touches so taps reach the game below.
class GameOverlay extends StatelessWidget {
  final String title;
  final String? subtitle;

  const GameOverlay({
    required this.title,
    this.subtitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CoreGameTheme.of(context);
    final subtitle = this.subtitle;
    return IgnorePointer(
      child: Center(
        child: Container(
          margin: EdgeInsets.all(theme.dimens.padding),
          padding: EdgeInsets.symmetric(horizontal: theme.dimens.padding * 1.5, vertical: theme.dimens.padding),
          decoration: BoxDecoration(
            color: theme.colors.background.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(theme.dimens.radiusLarge),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              Text(title, textAlign: TextAlign.center, style: theme.textStyles.title),
              if (subtitle != null) Text(subtitle, textAlign: TextAlign.center, style: theme.textStyles.body),
            ],
          ),
        ),
      ),
    );
  }
}
