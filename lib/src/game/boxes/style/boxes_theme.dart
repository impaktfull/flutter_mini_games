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
    );
    return BoxesTheme(
      colors: colors,
      textStyles: BoxesTextStyles(
        boxSymbol: core.textStyles.title,
      ),
      dimens: BoxesDimens(
        dotRadius: 6,
        lineWidth: 6,
        guideWidth: 4,
        lastLineMarkerRadius: 3,
        boardInset: 20,
        boxInset: 6,
        boxRadius: core.dimens.radiusSmall,
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

  /// Color of [player]'s lines and boxes
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

  const BoxesColors({
    required this.dot,
    required this.guide,
    required this.bottomPlayer,
    required this.onBottomPlayer,
    required this.topPlayer,
    required this.onTopPlayer,
  });

  BoxesColors copyWith({
    Color? dot,
    Color? guide,
    Color? bottomPlayer,
    Color? onBottomPlayer,
    Color? topPlayer,
    Color? onTopPlayer,
  }) => BoxesColors(
    dot: dot ?? this.dot,
    guide: guide ?? this.guide,
    bottomPlayer: bottomPlayer ?? this.bottomPlayer,
    onBottomPlayer: onBottomPlayer ?? this.onBottomPlayer,
    topPlayer: topPlayer ?? this.topPlayer,
    onTopPlayer: onTopPlayer ?? this.onTopPlayer,
  );
}

class BoxesTextStyles {
  /// Player symbol in a claimed box, colored with the player's on-color
  final TextStyle boxSymbol;

  const BoxesTextStyles({
    required this.boxSymbol,
  });

  BoxesTextStyles copyWith({
    TextStyle? boxSymbol,
  }) => BoxesTextStyles(
    boxSymbol: boxSymbol ?? this.boxSymbol,
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

  const BoxesDimens({
    required this.dotRadius,
    required this.lineWidth,
    required this.guideWidth,
    required this.lastLineMarkerRadius,
    required this.boardInset,
    required this.boxInset,
    required this.boxRadius,
  });

  BoxesDimens copyWith({
    double? dotRadius,
    double? lineWidth,
    double? guideWidth,
    double? lastLineMarkerRadius,
    double? boardInset,
    double? boxInset,
    double? boxRadius,
  }) => BoxesDimens(
    dotRadius: dotRadius ?? this.dotRadius,
    lineWidth: lineWidth ?? this.lineWidth,
    guideWidth: guideWidth ?? this.guideWidth,
    lastLineMarkerRadius: lastLineMarkerRadius ?? this.lastLineMarkerRadius,
    boardInset: boardInset ?? this.boardInset,
    boxInset: boxInset ?? this.boxInset,
    boxRadius: boxRadius ?? this.boxRadius,
  );
}
