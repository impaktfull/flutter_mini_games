import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';

class TicTacToeTheme extends GameTheme {
  final TicTacToeColors colors;
  final TicTacToeTextStyles textStyles;
  final TicTacToeDimens dimens;

  static TicTacToeTheme of(BuildContext context) => GameTheme.of<TicTacToeTheme>(context);

  const TicTacToeTheme({
    required this.colors,
    required this.textStyles,
    required this.dimens,
  });

  factory TicTacToeTheme.fromCore(CoreGameTheme core) => TicTacToeTheme(
    colors: TicTacToeColors(
      cellBackground: core.colors.surface,
      bottomPlayer: core.playerColor(DuelPlayer.bottom),
      onBottomPlayer: core.onPlayerColor(DuelPlayer.bottom),
      topPlayer: core.playerColor(DuelPlayer.top),
      onTopPlayer: core.onPlayerColor(DuelPlayer.top),
    ),
    textStyles: TicTacToeTextStyles(
      mark: core.textStyles.title.copyWith(fontSize: 48),
      bannerMark: core.textStyles.caption.copyWith(fontWeight: FontWeight.bold),
    ),
    dimens: TicTacToeDimens(
      cellRadius: core.dimens.radiusSmall,
      cellSpacing: 8,
    ),
  );

  TicTacToeTheme copyWith({
    TicTacToeColors? colors,
    TicTacToeTextStyles? textStyles,
    TicTacToeDimens? dimens,
  }) => TicTacToeTheme(
    colors: colors ?? this.colors,
    textStyles: textStyles ?? this.textStyles,
    dimens: dimens ?? this.dimens,
  );
}

class TicTacToeColors {
  final Color cellBackground;

  /// Color of Player 1's X (bottom), also the background of their winning cells
  final Color bottomPlayer;

  /// Color of X on a winning cell
  final Color onBottomPlayer;

  /// Color of Player 2's O (top), also the background of their winning cells
  final Color topPlayer;

  /// Color of O on a winning cell
  final Color onTopPlayer;

  const TicTacToeColors({
    required this.cellBackground,
    required this.bottomPlayer,
    required this.onBottomPlayer,
    required this.topPlayer,
    required this.onTopPlayer,
  });

  Color playerColor(DuelPlayer player) => player == DuelPlayer.bottom ? bottomPlayer : topPlayer;

  Color onPlayerColor(DuelPlayer player) => player == DuelPlayer.bottom ? onBottomPlayer : onTopPlayer;

  TicTacToeColors copyWith({
    Color? cellBackground,
    Color? bottomPlayer,
    Color? onBottomPlayer,
    Color? topPlayer,
    Color? onTopPlayer,
  }) => TicTacToeColors(
    cellBackground: cellBackground ?? this.cellBackground,
    bottomPlayer: bottomPlayer ?? this.bottomPlayer,
    onBottomPlayer: onBottomPlayer ?? this.onBottomPlayer,
    topPlayer: topPlayer ?? this.topPlayer,
    onTopPlayer: onTopPlayer ?? this.onTopPlayer,
  );
}

class TicTacToeTextStyles {
  /// X and O on the board, colored with the player color
  final TextStyle mark;

  /// X and O in the turn banners
  final TextStyle bannerMark;

  const TicTacToeTextStyles({
    required this.mark,
    required this.bannerMark,
  });

  TicTacToeTextStyles copyWith({
    TextStyle? mark,
    TextStyle? bannerMark,
  }) => TicTacToeTextStyles(
    mark: mark ?? this.mark,
    bannerMark: bannerMark ?? this.bannerMark,
  );
}

class TicTacToeDimens {
  final double cellRadius;
  final double cellSpacing;

  const TicTacToeDimens({
    required this.cellRadius,
    required this.cellSpacing,
  });

  TicTacToeDimens copyWith({
    double? cellRadius,
    double? cellSpacing,
  }) => TicTacToeDimens(
    cellRadius: cellRadius ?? this.cellRadius,
    cellSpacing: cellSpacing ?? this.cellSpacing,
  );
}
