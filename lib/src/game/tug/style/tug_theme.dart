import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';

class TugTheme extends GameTheme {
  final TugColors colors;
  final TugTextStyles textStyles;
  final TugDimens dimens;

  static TugTheme of(BuildContext context) => GameTheme.of<TugTheme>(context);

  const TugTheme({
    required this.colors,
    required this.textStyles,
    required this.dimens,
  });

  factory TugTheme.fromCore(CoreGameTheme core) {
    final c = core.colors;
    return TugTheme(
      colors: TugColors(
        track: c.surface,
        rope: Color.lerp(c.surface, c.text, 0.35)!,
        ropeStrand: Color.lerp(c.surface, c.text, 0.6)!,
        middle: c.textMuted,
        marker: c.text,
        markerBorder: c.background,
        bottomSide: Color.lerp(c.background, c.primary, 0.08)!,
        topSide: Color.lerp(c.background, c.secondary, 0.08)!,
        hint: c.textMuted,
      ),
      textStyles: TugTextStyles(
        hint: core.textStyles.title.copyWith(color: c.textMuted),
      ),
      dimens: TugDimens(
        ropeLengthFraction: 0.36,
        ropeThickness: 10,
        strandSpacing: 12,
        markerRadius: 14,
        markerBorder: 3,
        edgeLength: 24,
        trackRadius: core.dimens.radiusLarge,
        trackWidth: 56,
        hintIconSize: 48,
      ),
    );
  }

  TugTheme copyWith({
    TugColors? colors,
    TugTextStyles? textStyles,
    TugDimens? dimens,
  }) => TugTheme(
    colors: colors ?? this.colors,
    textStyles: textStyles ?? this.textStyles,
    dimens: dimens ?? this.dimens,
  );
}

class TugColors {
  /// Rounded lane behind the rope
  final Color track;

  /// The rope and its twisted strands
  final Color rope;
  final Color ropeStrand;

  /// Line in the middle of the rope where the marker starts
  final Color middle;

  /// The knot that is pulled to a player's edge
  final Color marker;
  final Color markerBorder;

  /// Background of each player's half (Player 1 at the bottom, Player 2 at the top)
  final Color bottomSide;
  final Color topSide;

  /// "Tap!" hand on each half while playing
  final Color hint;

  const TugColors({
    required this.track,
    required this.rope,
    required this.ropeStrand,
    required this.middle,
    required this.marker,
    required this.markerBorder,
    required this.bottomSide,
    required this.topSide,
    required this.hint,
  });

  TugColors copyWith({
    Color? track,
    Color? rope,
    Color? ropeStrand,
    Color? middle,
    Color? marker,
    Color? markerBorder,
    Color? bottomSide,
    Color? topSide,
    Color? hint,
  }) => TugColors(
    track: track ?? this.track,
    rope: rope ?? this.rope,
    ropeStrand: ropeStrand ?? this.ropeStrand,
    middle: middle ?? this.middle,
    marker: marker ?? this.marker,
    markerBorder: markerBorder ?? this.markerBorder,
    bottomSide: bottomSide ?? this.bottomSide,
    topSide: topSide ?? this.topSide,
    hint: hint ?? this.hint,
  );
}

class TugTextStyles {
  /// "Tap!" on each half while playing
  final TextStyle hint;

  const TugTextStyles({
    required this.hint,
  });

  TugTextStyles copyWith({
    TextStyle? hint,
  }) => TugTextStyles(
    hint: hint ?? this.hint,
  );
}

class TugDimens {
  /// Part of the screen height used by the rope between the two halves
  final double ropeLengthFraction;
  final double ropeThickness;

  /// Distance between two twisted strands of the rope
  final double strandSpacing;
  final double markerRadius;
  final double markerBorder;

  /// Length of the player colored edge at each end of the rope
  final double edgeLength;
  final double trackRadius;
  final double trackWidth;
  final double hintIconSize;

  const TugDimens({
    required this.ropeLengthFraction,
    required this.ropeThickness,
    required this.strandSpacing,
    required this.markerRadius,
    required this.markerBorder,
    required this.edgeLength,
    required this.trackRadius,
    required this.trackWidth,
    required this.hintIconSize,
  });

  TugDimens copyWith({
    double? ropeLengthFraction,
    double? ropeThickness,
    double? strandSpacing,
    double? markerRadius,
    double? markerBorder,
    double? edgeLength,
    double? trackRadius,
    double? trackWidth,
    double? hintIconSize,
  }) => TugDimens(
    ropeLengthFraction: ropeLengthFraction ?? this.ropeLengthFraction,
    ropeThickness: ropeThickness ?? this.ropeThickness,
    strandSpacing: strandSpacing ?? this.strandSpacing,
    markerRadius: markerRadius ?? this.markerRadius,
    markerBorder: markerBorder ?? this.markerBorder,
    edgeLength: edgeLength ?? this.edgeLength,
    trackRadius: trackRadius ?? this.trackRadius,
    trackWidth: trackWidth ?? this.trackWidth,
    hintIconSize: hintIconSize ?? this.hintIconSize,
  );
}
