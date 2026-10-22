import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';

/// Rounded, elevated frame around the playing field. Shared by all games.
class GameBoard extends StatelessWidget {
  /// Width / height of the board, the board is as large as possible within its parent
  final double aspectRatio;
  final EdgeInsets padding;
  final Widget child;

  const GameBoard({
    required this.child,
    this.aspectRatio = 1,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CoreGameTheme.of(context);
    final radius = BorderRadius.circular(theme.dimens.radiusLarge);
    return Center(
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colors.background,
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: theme.colors.shadow.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}
