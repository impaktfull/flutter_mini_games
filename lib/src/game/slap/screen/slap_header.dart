import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_game_controller.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';
import 'package:flutter_mini_games/src/game/slap/game/logic/slap_game_controller.dart';
import 'package:flutter_mini_games/src/game/slap/game/model/slap_attack.dart';
import 'package:flutter_mini_games/src/game/slap/style/slap_theme.dart';

/// Role ("Attack" / "Defend", with an icon) and what [player] has to do now
class SlapHeader extends StatelessWidget {
  final SlapGameController controller;
  final DuelPlayer player;

  const SlapHeader({
    required this.controller,
    required this.player,
    super.key,
  });

  bool get _isAttacker => controller.attacker == player;

  @override
  Widget build(BuildContext context) {
    final theme = SlapTheme.of(context);
    final coreTheme = CoreGameTheme.of(context);
    final onColor = coreTheme.onPlayerColor(player);
    return Row(
      spacing: 8,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: coreTheme.playerColor(player),
            borderRadius: BorderRadius.circular(theme.dimens.roleRadius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              Icon(_isAttacker ? Icons.sports_mma : Icons.shield, size: 18, color: onColor),
              Text(_isAttacker ? 'Attack' : 'Defend', style: theme.textStyles.role.copyWith(color: onColor)),
            ],
          ),
        ),
        Expanded(
          child: Text(
            _status(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textStyles.status,
          ),
        ),
      ],
    );
  }

  String _status() {
    switch (controller.phase) {
      case DuelPhase.ready:
      case DuelPhase.countdown:
        return _isAttacker ? 'You slap first' : 'You hold the target first';
      case DuelPhase.roundOver:
      case DuelPhase.finished:
        // DuelPhaseOverlay shows why the round ended
        return '';
      case DuelPhase.playing:
        break;
    }
    final defender = controller.defender;
    switch (controller.attack) {
      case SlapAttackState.waitingForHold:
        return _isAttacker ? 'Wait until ${defender.label} holds' : 'Hold your target';
      case SlapAttackState.armed:
        return _isAttacker ? 'Slap or fake!' : 'Lift when the slap comes';
      case SlapAttackState.windUp:
        if (!_isAttacker) return 'Watch the hand!';
        return controller.isFake ? 'Faking...' : 'Winding up...';
      case SlapAttackState.strike:
        return _isAttacker ? 'Slap!' : 'Watch the hand!';
      case SlapAttackState.retract:
        return _isAttacker ? 'Fake!' : 'Watch the hand!';
    }
  }
}
