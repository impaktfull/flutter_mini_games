import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';

class BoxesTheme extends GameTheme {
  final BoxesColors colors;
  final BoxesTextStyles textStyles;
  final BoxesDimens dimens;

  static BoxesTheme of(BuildContext context) => GameTheme.of<BoxesTheme>(context);

  const BoxesTheme({
    required this.colors,
    required this.textStyles,
    required this.dimens,
  });

  factory BoxesTheme.fromCore(CoreGameTheme core) {
    final colors = BoxesColors(
      dot: core.colors.text,
      guide: core.colors.surface,
      bottomPlayer: core.playerColor(DuelPlayer.bottom),
      onBottomPlayer: core.onPlayerColor(DuelPlayer.bottom),
      topPlayer: core.playerColor(DuelPlayer.top),
      onTopPlayer: core.onPlayerColor(DuelPlayer.top),
      banner: core.colors.surface,
      onBanner: core.colors.text,
    );
    return BoxesTheme(
      colors: colors,
      textStyles: BoxesTextStyles(
        boxSymbol: core.textStyles.title,
        bannerLabel: core.textStyles.label,
        bannerStatus: core.textStyles.caption,
        bannerScore: core.textStyles.title,
      ),
      dimens: BoxesDimens(
        dotRadius: 6,
        lineWidth: 6,
        guideWidth: 4,
        lastLineMarkerRadius: 3,
        boardInset: 20,
        boxInset: 6,
        boxRadius: core.dimens.radiusSmall,
        bannerRadius: core.dimens.radiusLarge,
        bannerPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        bannerSymbolSize: 28,
        bannerBorderWidth: 2,
      ),
    );
  }

  BoxesTheme copyWith({
    BoxesColors? colors,
    BoxesTextStyles? textStyles,
    BoxesDimens? dimens,
  }) => BoxesTheme(
    colors: colors ?? this.colors,
    textStyles: textStyles ?? this.textStyles,
    dimens: dimens ?? this.dimens,
  );

  /// Color of [player]'s lines, boxes and banner
  Color playerColor(DuelPlayer player) => player == DuelPlayer.bottom ? colors.bottomPlayer : colors.topPlayer;

  /// Text and symbols on [playerColor]
  Color onPlayerColor(DuelPlayer player) => player == DuelPlayer.bottom ? colors.onBottomPlayer : colors.onTopPlayer;
}

class BoxesColors {
  final Color dot;

  /// Lines that are not drawn yet
  final Color guide;

  /// Lines and boxes of Player 1 (bottom)
  final Color bottomPlayer;
  final Color onBottomPlayer;

  /// Lines and boxes of Player 2 (top)
  final Color topPlayer;
  final Color onTopPlayer;

  /// Banner of the player who is waiting
  final Color banner;
  final Color onBanner;

  const BoxesColors({
    required this.dot,
    required this.guide,
    required this.bottomPlayer,
    required this.onBottomPlayer,
    required this.topPlayer,
    required this.onTopPlayer,
    required this.banner,
    required this.onBanner,
  });

  BoxesColors copyWith({
    Color? dot,
    Color? guide,
    Color? bottomPlayer,
    Color? onBottomPlayer,
    Color? topPlayer,
    Color? onTopPlayer,
    Color? banner,
    Color? onBanner,
  }) => BoxesColors(
    dot: dot ?? this.dot,
    guide: guide ?? this.guide,
    bottomPlayer: bottomPlayer ?? this.bottomPlayer,
    onBottomPlayer: onBottomPlayer ?? this.onBottomPlayer,
    topPlayer: topPlayer ?? this.topPlayer,
    onTopPlayer: onTopPlayer ?? this.onTopPlayer,
    banner: banner ?? this.banner,
    onBanner: onBanner ?? this.onBanner,
  );
}

class BoxesTextStyles {
  /// Player symbol in a claimed box, colored with the player's on-color
  final TextStyle boxSymbol;
  final TextStyle bannerLabel;
  final TextStyle bannerStatus;
  final TextStyle bannerScore;

  const BoxesTextStyles({
    required this.boxSymbol,
    required this.bannerLabel,
    required this.bannerStatus,
    required this.bannerScore,
  });

  BoxesTextStyles copyWith({
    TextStyle? boxSymbol,
    TextStyle? bannerLabel,
    TextStyle? bannerStatus,
    TextStyle? bannerScore,
  }) => BoxesTextStyles(
    boxSymbol: boxSymbol ?? this.boxSymbol,
    bannerLabel: bannerLabel ?? this.bannerLabel,
    bannerStatus: bannerStatus ?? this.bannerStatus,
    bannerScore: bannerScore ?? this.bannerScore,
  );
}

class BoxesDimens {
  final double dotRadius;
  final double lineWidth;

  /// Width of the lines that are not drawn yet
  final double guideWidth;
  final double lastLineMarkerRadius;

  /// Space between the outer dots and the board edge
  final double boardInset;

  /// Space between a claimed box fill and its lines
  final double boxInset;
  final double boxRadius;
  final double bannerRadius;
  final EdgeInsets bannerPadding;

  /// Size of the player symbol in the banner
  final double bannerSymbolSize;
  final double bannerBorderWidth;

  const BoxesDimens({
    required this.dotRadius,
    required this.lineWidth,
    required this.guideWidth,
    required this.lastLineMarkerRadius,
    required this.boardInset,
    required this.boxInset,
    required this.boxRadius,
    required this.bannerRadius,
    required this.bannerPadding,
    required this.bannerSymbolSize,
    required this.bannerBorderWidth,
  });

  BoxesDimens copyWith({
    double? dotRadius,
    double? lineWidth,
    double? guideWidth,
    double? lastLineMarkerRadius,
    double? boardInset,
    double? boxInset,
    double? boxRadius,
    double? bannerRadius,
    EdgeInsets? bannerPadding,
    double? bannerSymbolSize,
    double? bannerBorderWidth,
  }) => BoxesDimens(
    dotRadius: dotRadius ?? this.dotRadius,
    lineWidth: lineWidth ?? this.lineWidth,
    guideWidth: guideWidth ?? this.guideWidth,
    lastLineMarkerRadius: lastLineMarkerRadius ?? this.lastLineMarkerRadius,
    boardInset: boardInset ?? this.boardInset,
    boxInset: boxInset ?? this.boxInset,
    boxRadius: boxRadius ?? this.boxRadius,
    bannerRadius: bannerRadius ?? this.bannerRadius,
    bannerPadding: bannerPadding ?? this.bannerPadding,
    bannerSymbolSize: bannerSymbolSize ?? this.bannerSymbolSize,
    bannerBorderWidth: bannerBorderWidth ?? this.bannerBorderWidth,
  );
}
