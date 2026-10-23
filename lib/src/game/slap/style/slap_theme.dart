import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';

/// Theme of Slap. The hands, the held target and the slap button use the player color tokens
/// (`SlapColors.bottomPlayer` / `topPlayer`), derived from `CoreGameTheme.playerColor`.
class SlapTheme extends GameTheme {
  final SlapColors colors;
  final SlapTextStyles textStyles;
  final SlapDimens dimens;

  static SlapTheme of(BuildContext context) => GameTheme.of<SlapTheme>(context);

  const SlapTheme({
    required this.colors,
    required this.textStyles,
    required this.dimens,
  });

  factory SlapTheme.fromCore(CoreGameTheme core) {
    final colors = core.colors;
    return SlapTheme(
      colors: SlapColors(
        arena: colors.surface,
        bottomPlayer: core.playerColor(DuelPlayer.bottom),
        onBottomPlayer: core.onPlayerColor(DuelPlayer.bottom),
        topPlayer: core.playerColor(DuelPlayer.top),
        onTopPlayer: core.onPlayerColor(DuelPlayer.top),
        target: colors.background,
        onTarget: colors.textMuted,
        slapped: colors.error,
        onSlapped: colors.onError,
        handOutline: colors.background,
        buttonDisabled: colors.background,
        onButtonDisabled: colors.textMuted,
        fake: colors.background,
        onFake: colors.text,
        timerTrack: colors.background,
        divider: colors.surface,
      ),
      textStyles: SlapTextStyles(
        role: core.textStyles.label,
        status: core.textStyles.body,
        target: core.textStyles.label,
        button: core.textStyles.label,
        buttonHint: core.textStyles.caption,
      ),
      dimens: SlapDimens(
        arenaRadius: core.dimens.radiusLarge,
        roleRadius: core.dimens.radiusSmall,
        targetBorderWidth: 4,
        handOutlineWidth: 3,
        timerHeight: 6,
        dividerHeight: 4,
      ),
    );
  }

  SlapTheme copyWith({
    SlapColors? colors,
    SlapTextStyles? textStyles,
    SlapDimens? dimens,
  }) => SlapTheme(
    colors: colors ?? this.colors,
    textStyles: textStyles ?? this.textStyles,
    dimens: dimens ?? this.dimens,
  );
}

class SlapColors {
  /// Background of the defender's arena and the attacker's pad
  final Color arena;

  /// Player 1 (bottom) and Player 2 (top), [onBottomPlayer] / [onTopPlayer] for text and icons on them
  final Color bottomPlayer;
  final Color onBottomPlayer;
  final Color topPlayer;
  final Color onTopPlayer;

  /// Target that is not held; [onTarget] for its icon, text and ring
  final Color target;
  final Color onTarget;

  /// Target after a slap landed on it
  final Color slapped;
  final Color onSlapped;

  /// Outline around the hand, separates the fingers
  final Color handOutline;

  /// Slap button while the attacker can't slap
  final Color buttonDisabled;
  final Color onButtonDisabled;

  /// Fake button
  final Color fake;
  final Color onFake;

  /// Track of the attack timer, the bar uses the attacker's color
  final Color timerTrack;

  /// Line between the two halves
  final Color divider;

  const SlapColors({
    required this.arena,
    required this.bottomPlayer,
    required this.onBottomPlayer,
    required this.topPlayer,
    required this.onTopPlayer,
    required this.target,
    required this.onTarget,
    required this.slapped,
    required this.onSlapped,
    required this.handOutline,
    required this.buttonDisabled,
    required this.onButtonDisabled,
    required this.fake,
    required this.onFake,
    required this.timerTrack,
    required this.divider,
  });

  /// Color of [player]
  Color playerColor(DuelPlayer player) => player == DuelPlayer.bottom ? bottomPlayer : topPlayer;

  /// Text and icons on [playerColor]
  Color onPlayerColor(DuelPlayer player) => player == DuelPlayer.bottom ? onBottomPlayer : onTopPlayer;

  SlapColors copyWith({
    Color? arena,
    Color? bottomPlayer,
    Color? onBottomPlayer,
    Color? topPlayer,
    Color? onTopPlayer,
    Color? target,
    Color? onTarget,
    Color? slapped,
    Color? onSlapped,
    Color? handOutline,
    Color? buttonDisabled,
    Color? onButtonDisabled,
    Color? fake,
    Color? onFake,
    Color? timerTrack,
    Color? divider,
  }) => SlapColors(
    arena: arena ?? this.arena,
    bottomPlayer: bottomPlayer ?? this.bottomPlayer,
    onBottomPlayer: onBottomPlayer ?? this.onBottomPlayer,
    topPlayer: topPlayer ?? this.topPlayer,
    onTopPlayer: onTopPlayer ?? this.onTopPlayer,
    target: target ?? this.target,
    onTarget: onTarget ?? this.onTarget,
    slapped: slapped ?? this.slapped,
    onSlapped: onSlapped ?? this.onSlapped,
    handOutline: handOutline ?? this.handOutline,
    buttonDisabled: buttonDisabled ?? this.buttonDisabled,
    onButtonDisabled: onButtonDisabled ?? this.onButtonDisabled,
    fake: fake ?? this.fake,
    onFake: onFake ?? this.onFake,
    timerTrack: timerTrack ?? this.timerTrack,
    divider: divider ?? this.divider,
  );
}

class SlapTextStyles {
  /// "Attack" / "Defend" label
  final TextStyle role;

  /// Status next to the role ("Hold your target", "Slap or fake!")
  final TextStyle status;

  /// Text on the target
  final TextStyle target;

  /// Label of the slap and fake buttons
  final TextStyle button;

  /// Small line on a button ("2 left")
  final TextStyle buttonHint;

  const SlapTextStyles({
    required this.role,
    required this.status,
    required this.target,
    required this.button,
    required this.buttonHint,
  });

  SlapTextStyles copyWith({
    TextStyle? role,
    TextStyle? status,
    TextStyle? target,
    TextStyle? button,
    TextStyle? buttonHint,
  }) => SlapTextStyles(
    role: role ?? this.role,
    status: status ?? this.status,
    target: target ?? this.target,
    button: button ?? this.button,
    buttonHint: buttonHint ?? this.buttonHint,
  );
}

class SlapDimens {
  /// Corner radius of the arena and the pad
  final double arenaRadius;

  /// Corner radius of the role label
  final double roleRadius;

  /// Width of the ring around the target
  final double targetBorderWidth;

  /// Width of the outline around the hand
  final double handOutlineWidth;

  /// Height of the attack timer
  final double timerHeight;

  /// Height of the line between the two halves
  final double dividerHeight;

  const SlapDimens({
    required this.arenaRadius,
    required this.roleRadius,
    required this.targetBorderWidth,
    required this.handOutlineWidth,
    required this.timerHeight,
    required this.dividerHeight,
  });

  SlapDimens copyWith({
    double? arenaRadius,
    double? roleRadius,
    double? targetBorderWidth,
    double? handOutlineWidth,
    double? timerHeight,
    double? dividerHeight,
  }) => SlapDimens(
    arenaRadius: arenaRadius ?? this.arenaRadius,
    roleRadius: roleRadius ?? this.roleRadius,
    targetBorderWidth: targetBorderWidth ?? this.targetBorderWidth,
    handOutlineWidth: handOutlineWidth ?? this.handOutlineWidth,
    timerHeight: timerHeight ?? this.timerHeight,
    dividerHeight: dividerHeight ?? this.dividerHeight,
  );
}
