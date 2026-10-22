import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/game/tiles/game/logic/tiles_game_controller.dart';
import 'package:flutter_mini_games/src/game/tiles/style/tiles_theme.dart';

/// Tiles tapped and the current speed
class TilesHeader extends StatelessWidget {
  final TilesGameController controller;

  const TilesHeader({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = TilesTheme.of(context);
    final multiplier = controller.speed / TilesGameController.startSpeed;
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 24,
      runSpacing: 8,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Icon(Icons.grid_view_rounded, color: theme.colors.darkTile),
            Text('${controller.score}', style: theme.textStyles.score),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Icon(Icons.speed, size: 20, color: theme.colors.darkTile),
            Text('×${multiplier.toStringAsFixed(1)}', style: theme.textStyles.speed),
          ],
        ),
      ],
    );
  }
}
