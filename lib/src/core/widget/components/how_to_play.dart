import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';

class GameHowToPlayItem {
  final IconData icon;
  final String text;

  const GameHowToPlayItem({
    required this.icon,
    required this.text,
  });
}

/// Short explanation of the rules. Shared by all games.
class GameHowToPlay extends StatelessWidget {
  final List<GameHowToPlayItem> items;

  const GameHowToPlay({
    required this.items,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CoreGameTheme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(theme.dimens.padding),
      decoration: BoxDecoration(
        color: theme.colors.surface,
        borderRadius: BorderRadius.circular(theme.dimens.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text('How to play', style: theme.textStyles.label),
          Wrap(
            spacing: 24,
            runSpacing: 8,
            children: [
              for (final item in items)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(theme.dimens.radiusSmall),
                      ),
                      child: Icon(item.icon, color: theme.colors.primary),
                    ),
                    Flexible(child: Text(item.text, style: theme.textStyles.caption)),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
