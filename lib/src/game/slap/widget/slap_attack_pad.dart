import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_layout.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/game/slap/game/logic/slap_game_controller.dart';
import 'package:flutter_mini_games/src/game/slap/style/slap_theme.dart';
import 'package:flutter_mini_games/src/game/slap/widget/slap_hand.dart';

/// The attacker's half: the slap button, the fake button and the attack timer
class SlapAttackPad extends StatelessWidget {
  final SlapGameController controller;

  /// The attacker
  final DuelPlayer player;

  const SlapAttackPad({
    required this.controller,
    required this.player,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SlapTheme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(theme.dimens.arenaRadius),
      child: ColoredBox(
        color: theme.colors.arena,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            spacing: 8,
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final slapSize = max(0.0, min(constraints.maxHeight, constraints.maxWidth * 0.55));
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 16,
                      children: [
                        _SlapButton(controller: controller, player: player, size: slapSize),
                        _FakeButton(controller: controller, player: player, size: slapSize * 0.62),
                      ],
                    );
                  },
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(theme.dimens.timerHeight / 2),
                child: SizedBox(
                  height: theme.dimens.timerHeight,
                  child: ColoredBox(
                    color: theme.colors.timerTrack,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      // The time runs every frame: only the bar rebuilds and repaints
                      child: RepaintBoundary(
                        child: ListenableBuilder(
                          listenable: controller.frame,
                          builder: (context, child) => FractionallySizedBox(widthFactor: controller.attackTimeLeft, heightFactor: 1, child: child),
                          child: ColoredBox(color: theme.colors.playerColor(player)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlapButton extends StatelessWidget {
  final SlapGameController controller;
  final DuelPlayer player;
  final double size;

  const _SlapButton({
    required this.controller,
    required this.player,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    // The hand on the button moves every frame during an attack: only the button rebuilds and repaints
    return RepaintBoundary(
      child: ListenableBuilder(listenable: controller.frame, builder: (context, child) => _buildButton(context)),
    );
  }

  Widget _buildButton(BuildContext context) {
    final theme = SlapTheme.of(context);
    final isEnabled = controller.canAttack;
    // The button shows the attacker's own hand, also while it moves
    final isAttacking = !isEnabled && controller.handLift > 0;
    final color = isEnabled || isAttacking ? theme.colors.playerColor(player) : theme.colors.buttonDisabled;
    final onColor = isEnabled || isAttacking ? theme.colors.onPlayerColor(player) : theme.colors.onButtonDisabled;
    return DuelTapArea(
      key: const ValueKey('slap_button'),
      onTap: isEnabled ? () => controller.slap(player) : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: isEnabled || isAttacking ? color : onColor, width: 2),
        ),
        padding: EdgeInsets.all(size * 0.16),
        child: FittedBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              Transform.scale(
                scale: 1 + 0.3 * controller.handLift,
                child: SlapHand(width: 40, color: onColor, outlineColor: color, outlineWidth: 2),
              ),
              Text('Slap', style: theme.textStyles.button.copyWith(color: onColor)),
            ],
          ),
        ),
      ),
    );
  }
}

class _FakeButton extends StatelessWidget {
  final SlapGameController controller;
  final DuelPlayer player;
  final double size;

  const _FakeButton({
    required this.controller,
    required this.player,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SlapTheme.of(context);
    final isEnabled = controller.canFake;
    final onColor = isEnabled ? theme.colors.onFake : theme.colors.onButtonDisabled;
    return DuelTapArea(
      key: const ValueKey('slap_fake_button'),
      onTap: isEnabled ? () => controller.fake(player) : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: theme.colors.fake,
          shape: BoxShape.circle,
          border: Border.all(color: onColor, width: 2),
        ),
        padding: EdgeInsets.all(size * 0.18),
        child: FittedBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Fake', style: theme.textStyles.button.copyWith(color: onColor)),
              Text('${controller.fakesLeft} left', style: theme.textStyles.buttonHint.copyWith(color: onColor)),
            ],
          ),
        ),
      ),
    );
  }
}
