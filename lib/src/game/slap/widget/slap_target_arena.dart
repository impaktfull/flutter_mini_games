import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/game/slap/game/logic/slap_game_controller.dart';
import 'package:flutter_mini_games/src/game/slap/game/model/slap_attack.dart';
import 'package:flutter_mini_games/src/game/slap/style/slap_theme.dart';
import 'package:flutter_mini_games/src/game/slap/widget/slap_hand.dart';

/// The defender's half: their target (hold it with a finger) and the attacker's hand above it
class SlapTargetArena extends StatelessWidget {
  final SlapGameController controller;

  /// The defender
  final DuelPlayer player;

  const SlapTargetArena({
    required this.controller,
    required this.player,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SlapTheme.of(context);
    final coreTheme = CoreGameTheme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(theme.dimens.arenaRadius),
      child: ColoredBox(
        color: theme.colors.arena,
        child: LayoutBuilder(
          builder: (context, constraints) {
            const padding = 8.0;
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;
            // Hand (1.3 radius high) + gap + target (2 radius) fit in the height
            final radius = max(0.0, min(width * 0.3, (height - padding * 2 - 8) / 3.3));
            final handWidth = radius;
            final handHeight = handWidth * SlapHand.aspectRatio;
            final targetCenter = Offset(width / 2, height - padding - radius);
            const restTop = padding;
            final landTop = targetCenter.dy - handHeight / 2;
            final handTop = lerpDouble(restTop, landTop, controller.handPosition)!;
            final lift = controller.handLift;
            return Stack(
              children: [
                Positioned(
                  left: targetCenter.dx - radius,
                  top: targetCenter.dy - radius,
                  width: radius * 2,
                  height: radius * 2,
                  child: _Target(controller: controller, player: player, radius: radius),
                ),
                Positioned(
                  left: (width - handWidth) / 2,
                  top: handTop,
                  child: IgnorePointer(
                    // Raised: bigger and tilted, growing away from the target (anchored at the fingertips)
                    child: Transform.rotate(
                      angle: -0.2 * lift,
                      alignment: Alignment.bottomCenter,
                      child: Transform.scale(
                        scale: 1 + 0.35 * lift,
                        alignment: Alignment.bottomCenter,
                        child: SlapHand(
                          width: handWidth,
                          color: coreTheme.playerColor(player.opponent),
                          outlineColor: theme.colors.handOutline,
                          outlineWidth: theme.dimens.handOutlineWidth,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Target extends StatelessWidget {
  final SlapGameController controller;
  final DuelPlayer player;
  final double radius;

  const _Target({
    required this.controller,
    required this.player,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SlapTheme.of(context);
    final coreTheme = CoreGameTheme.of(context);
    final isHolding = controller.isHolding(player);
    final isSlapped = controller.roundEnd == SlapRoundEnd.slapped;
    final Color color;
    final Color onColor;
    final String label;
    final IconData icon;
    if (isSlapped) {
      color = theme.colors.slapped;
      onColor = theme.colors.onSlapped;
      label = 'Ouch!';
      icon = Icons.close;
    } else if (isHolding) {
      color = coreTheme.playerColor(player);
      onColor = coreTheme.onPlayerColor(player);
      label = 'Holding';
      icon = Icons.touch_app;
    } else {
      color = theme.colors.target;
      onColor = theme.colors.onTarget;
      label = 'Hold here';
      icon = Icons.touch_app_outlined;
    }
    return Listener(
      key: const ValueKey('slap_target'),
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) => controller.press(player, event.pointer),
      onPointerUp: (event) => controller.release(player, event.pointer),
      onPointerCancel: (event) => controller.release(player, event.pointer),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: isSlapped ? onColor : coreTheme.playerColor(player), width: theme.dimens.targetBorderWidth),
        ),
        child: Padding(
          padding: EdgeInsets.all(radius * 0.3),
          child: FittedBox(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: onColor, size: 32),
                Text(label, style: theme.textStyles.target.copyWith(color: onColor)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
