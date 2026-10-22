import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/game/slap/game/logic/slap_game_controller.dart';
import 'package:flutter_mini_games/src/game/slap/screen/slap_header.dart';
import 'package:flutter_mini_games/src/game/slap/widget/slap_attack_pad.dart';
import 'package:flutter_mini_games/src/game/slap/widget/slap_target_arena.dart';

/// One player's half: their role and status, and the attack pad or the target
class SlapSide extends StatelessWidget {
  /// Space at the bottom for the round score of `DuelPhaseOverlay`
  static const scoreSpace = 28.0;

  final SlapGameController controller;
  final DuelPlayer player;

  const SlapSide({
    required this.controller,
    required this.player,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isAttacker = controller.attacker == player;
    return Padding(
      padding: const EdgeInsets.only(bottom: scoreSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          SlapHeader(controller: controller, player: player),
          Expanded(
            child: isAttacker ? SlapAttackPad(controller: controller, player: player) : SlapTargetArena(controller: controller, player: player),
          ),
        ],
      ),
    );
  }
}
