import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';

class PushTheme extends GameTheme {
  final PushColors colors;
  final PushTextStyles textStyles;
  final PushDimens dimens;

  static PushTheme of(BuildContext context) => GameTheme.of<PushTheme>(context);

  const PushTheme({
    required this.colors,
    required this.textStyles,
    required this.dimens,
  });

  factory PushTheme.fromCore(CoreGameTheme core) {
    return PushTheme(
      colors: PushColors(
        outside: core.colors.background,
        ring: core.colors.surface,
        ringEdge: core.colors.textMuted,
        startLine: core.colors.textMuted,
        bottomDisc: core.playerColor(DuelPlayer.bottom),
        onBottomDisc: core.onPlayerColor(DuelPlayer.bottom),
        topDisc: core.playerColor(DuelPlayer.top),
        onTopDisc: core.onPlayerColor(DuelPlayer.top),
      ),
      textStyles: PushTextStyles(
        discLabel: core.textStyles.label,
      ),
      dimens: const PushDimens(
        ringEdgeWidth: 4,
        startLineWidth: 3,
        aimLineWidth: 4,
        aimLength: 0.14,
      ),
    );
  }

  PushTheme copyWith({
    PushColors? colors,
    PushTextStyles? textStyles,
    PushDimens? dimens,
  }) => PushTheme(
    colors: colors ?? this.colors,
    textStyles: textStyles ?? this.textStyles,
    dimens: dimens ?? this.dimens,
  );
}

class PushColors {
  /// Area around the ring
  final Color outside;

  /// Floor of the ring
  final Color ring;

  /// Edge of the (shrinking) ring
  final Color ringEdge;

  /// Start lines of the discs
  final Color startLine;

  /// Disc and aim line of Player 1
  final Color bottomDisc;

  /// Number on the disc of Player 1
  final Color onBottomDisc;

  /// Disc and aim line of Player 2
  final Color topDisc;

  /// Number on the disc of Player 2
  final Color onTopDisc;

  const PushColors({
    required this.outside,
    required this.ring,
    required this.ringEdge,
    required this.startLine,
    required this.bottomDisc,
    required this.onBottomDisc,
    required this.topDisc,
    required this.onTopDisc,
  });

  Color disc(DuelPlayer player) => player == DuelPlayer.bottom ? bottomDisc : topDisc;

  Color onDisc(DuelPlayer player) => player == DuelPlayer.bottom ? onBottomDisc : onTopDisc;

  PushColors copyWith({
    Color? outside,
    Color? ring,
    Color? ringEdge,
    Color? startLine,
    Color? bottomDisc,
    Color? onBottomDisc,
    Color? topDisc,
    Color? onTopDisc,
  }) => PushColors(
    outside: outside ?? this.outside,
    ring: ring ?? this.ring,
    ringEdge: ringEdge ?? this.ringEdge,
    startLine: startLine ?? this.startLine,
    bottomDisc: bottomDisc ?? this.bottomDisc,
    onBottomDisc: onBottomDisc ?? this.onBottomDisc,
    topDisc: topDisc ?? this.topDisc,
    onTopDisc: onTopDisc ?? this.onTopDisc,
  );
}

class PushTextStyles {
  /// Player number on a disc, the color comes from [PushColors.onDisc]
  final TextStyle discLabel;

  const PushTextStyles({
    required this.discLabel,
  });

  PushTextStyles copyWith({
    TextStyle? discLabel,
  }) => PushTextStyles(
    discLabel: discLabel ?? this.discLabel,
  );
}

class PushDimens {
  /// Stroke width of the ring edge in pixels
  final double ringEdgeWidth;

  /// Stroke width of the start lines in pixels
  final double startLineWidth;

  /// Stroke width of the aim line in pixels
  final double aimLineWidth;

  /// Length of the aim line past the disc edge, in world units (ring radius = 1)
  final double aimLength;

  const PushDimens({
    required this.ringEdgeWidth,
    required this.startLineWidth,
    required this.aimLineWidth,
    required this.aimLength,
  });

  PushDimens copyWith({
    double? ringEdgeWidth,
    double? startLineWidth,
    double? aimLineWidth,
    double? aimLength,
  }) => PushDimens(
    ringEdgeWidth: ringEdgeWidth ?? this.ringEdgeWidth,
    startLineWidth: startLineWidth ?? this.startLineWidth,
    aimLineWidth: aimLineWidth ?? this.aimLineWidth,
    aimLength: aimLength ?? this.aimLength,
  );
}
