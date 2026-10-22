import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';

class FlipTheme extends GameTheme {
  final FlipColors colors;
  final FlipTextStyles textStyles;
  final FlipDimens dimens;

  static FlipTheme of(BuildContext context) => GameTheme.of<FlipTheme>(context);

  const FlipTheme({
    required this.colors,
    required this.textStyles,
    required this.dimens,
  });

  factory FlipTheme.fromCore(CoreGameTheme core) => FlipTheme(
    colors: FlipColors(
      cell: core.colors.surface,
      lastMoveCell: Color.lerp(core.colors.surface, core.colors.textMuted, 0.3)!,
      bottomPlayer: core.playerColor(DuelPlayer.bottom),
      onBottomPlayer: core.onPlayerColor(DuelPlayer.bottom),
      topPlayer: core.playerColor(DuelPlayer.top),
      onTopPlayer: core.onPlayerColor(DuelPlayer.top),
      banner: core.colors.surface,
      text: core.colors.text,
      textMuted: core.colors.textMuted,
    ),
    textStyles: FlipTextStyles(
      playerName: core.textStyles.label,
      status: core.textStyles.body.copyWith(fontSize: 14),
      count: core.textStyles.title,
    ),
    dimens: FlipDimens(
      cellRadius: core.dimens.radiusSmall / 2,
      cellSpacing: 3,
      boardPadding: 6,
      discInset: 0.12,
      ringWidth: 0.3,
      hintSize: 0.34,
      bannerRadius: core.dimens.radiusSmall,
      bannerDiscSize: 22,
    ),
  );

  FlipTheme copyWith({
    FlipColors? colors,
    FlipTextStyles? textStyles,
    FlipDimens? dimens,
  }) => FlipTheme(
    colors: colors ?? this.colors,
    textStyles: textStyles ?? this.textStyles,
    dimens: dimens ?? this.dimens,
  );
}

class FlipColors {
  /// Empty cell
  final Color cell;

  /// Cell of the last placed disc
  final Color lastMoveCell;

  /// Discs of Player 1 (bottom, filled discs)
  final Color bottomPlayer;

  /// Text and discs on [bottomPlayer]
  final Color onBottomPlayer;

  /// Discs of Player 2 (top, ring discs)
  final Color topPlayer;

  /// Text and discs on [topPlayer]
  final Color onTopPlayer;

  /// Turn banner of the player that is waiting
  final Color banner;
  final Color text;
  final Color textMuted;

  const FlipColors({
    required this.cell,
    required this.lastMoveCell,
    required this.bottomPlayer,
    required this.onBottomPlayer,
    required this.topPlayer,
    required this.onTopPlayer,
    required this.banner,
    required this.text,
    required this.textMuted,
  });

  Color player(DuelPlayer player) => player == DuelPlayer.bottom ? bottomPlayer : topPlayer;

  Color onPlayer(DuelPlayer player) => player == DuelPlayer.bottom ? onBottomPlayer : onTopPlayer;

  FlipColors copyWith({
    Color? cell,
    Color? lastMoveCell,
    Color? bottomPlayer,
    Color? onBottomPlayer,
    Color? topPlayer,
    Color? onTopPlayer,
    Color? banner,
    Color? text,
    Color? textMuted,
  }) => FlipColors(
    cell: cell ?? this.cell,
    lastMoveCell: lastMoveCell ?? this.lastMoveCell,
    bottomPlayer: bottomPlayer ?? this.bottomPlayer,
    onBottomPlayer: onBottomPlayer ?? this.onBottomPlayer,
    topPlayer: topPlayer ?? this.topPlayer,
    onTopPlayer: onTopPlayer ?? this.onTopPlayer,
    banner: banner ?? this.banner,
    text: text ?? this.text,
    textMuted: textMuted ?? this.textMuted,
  );
}

class FlipTextStyles {
  /// Player name in the turn banner
  final TextStyle playerName;

  /// "Your turn", "Waiting", "Passed", ... in the turn banner
  final TextStyle status;

  /// Disc count in the turn banner
  final TextStyle count;

  const FlipTextStyles({
    required this.playerName,
    required this.status,
    required this.count,
  });

  FlipTextStyles copyWith({
    TextStyle? playerName,
    TextStyle? status,
    TextStyle? count,
  }) => FlipTextStyles(
    playerName: playerName ?? this.playerName,
    status: status ?? this.status,
    count: count ?? this.count,
  );
}

class FlipDimens {
  final double cellRadius;
  final double cellSpacing;
  final double boardPadding;

  /// Space between a disc and its cell edge, as a fraction of the cell size
  final double discInset;

  /// Ring width of Player 2's discs, as a fraction of the disc radius
  final double ringWidth;

  /// Size of a legal move hint, as a fraction of the cell size
  final double hintSize;
  final double bannerRadius;
  final double bannerDiscSize;

  const FlipDimens({
    required this.cellRadius,
    required this.cellSpacing,
    required this.boardPadding,
    required this.discInset,
    required this.ringWidth,
    required this.hintSize,
    required this.bannerRadius,
    required this.bannerDiscSize,
  });

  FlipDimens copyWith({
    double? cellRadius,
    double? cellSpacing,
    double? boardPadding,
    double? discInset,
    double? ringWidth,
    double? hintSize,
    double? bannerRadius,
    double? bannerDiscSize,
  }) => FlipDimens(
    cellRadius: cellRadius ?? this.cellRadius,
    cellSpacing: cellSpacing ?? this.cellSpacing,
    boardPadding: boardPadding ?? this.boardPadding,
    discInset: discInset ?? this.discInset,
    ringWidth: ringWidth ?? this.ringWidth,
    hintSize: hintSize ?? this.hintSize,
    bannerRadius: bannerRadius ?? this.bannerRadius,
    bannerDiscSize: bannerDiscSize ?? this.bannerDiscSize,
  );
}
