import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/core/widget/theme/theme_builder.dart';

class GameButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData icon;

  const GameButton({
    required this.label,
    required this.onTap,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GameThemeBuilder<CoreGameTheme>(
      builder: (context, theme) => Opacity(
        opacity: onTap == null ? 0.5 : 1.0,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: theme.colors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
