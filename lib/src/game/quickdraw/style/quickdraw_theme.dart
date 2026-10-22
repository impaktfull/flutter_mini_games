import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';

class QuickdrawTheme extends GameTheme {
  final QuickdrawColors colors;
  final QuickdrawTextStyles textStyles;
  final QuickdrawDimens dimens;

  static QuickdrawTheme of(BuildContext context) => GameTheme.of<QuickdrawTheme>(context);

  const QuickdrawTheme({
    required this.colors,
    required this.textStyles,
    required this.dimens,
  });

  factory QuickdrawTheme.fromCore(CoreGameTheme core) {
    final colors = core.colors;
    return QuickdrawTheme(
      colors: QuickdrawColors(
        idle: colors.background,
        onIdle: colors.text,
        waiting: colors.surface,
        onWaiting: colors.text,
        go: colors.text,
        onGo: colors.background,
        tooEarly: colors.error,
        onTooEarly: colors.onError,
        divider: colors.textMuted,
      ),
      textStyles: QuickdrawTextStyles(
        signal: core.textStyles.title.copyWith(fontSize: 72, height: 1),
        message: core.textStyles.title,
        hint: core.textStyles.body,
      ),
      dimens: const QuickdrawDimens(
        iconSize: 56,
        signalIconSize: 72,
        dividerThickness: 2,
      ),
    );
  }

  QuickdrawTheme copyWith({
    QuickdrawColors? colors,
    QuickdrawTextStyles? textStyles,
    QuickdrawDimens? dimens,
  }) => QuickdrawTheme(
    colors: colors ?? this.colors,
    textStyles: textStyles ?? this.textStyles,
    dimens: dimens ?? this.dimens,
  );
}

class QuickdrawColors {
  /// Half before and between rounds; [onIdle] for text and icons on it
  final Color idle;
  final Color onIdle;

  /// Half while waiting for GO
  final Color waiting;
  final Color onWaiting;

  /// Half when GO is shown: tap now
  final Color go;
  final Color onGo;

  /// Half of the player who tapped before GO
  final Color tooEarly;
  final Color onTooEarly;

  /// Line between the two halves
  final Color divider;

  const QuickdrawColors({
    required this.idle,
    required this.onIdle,
    required this.waiting,
    required this.onWaiting,
    required this.go,
    required this.onGo,
    required this.tooEarly,
    required this.onTooEarly,
    required this.divider,
  });

  QuickdrawColors copyWith({
    Color? idle,
    Color? onIdle,
    Color? waiting,
    Color? onWaiting,
    Color? go,
    Color? onGo,
    Color? tooEarly,
    Color? onTooEarly,
    Color? divider,
  }) => QuickdrawColors(
    idle: idle ?? this.idle,
    onIdle: onIdle ?? this.onIdle,
    waiting: waiting ?? this.waiting,
    onWaiting: onWaiting ?? this.onWaiting,
    go: go ?? this.go,
    onGo: onGo ?? this.onGo,
    tooEarly: tooEarly ?? this.tooEarly,
    onTooEarly: onTooEarly ?? this.onTooEarly,
    divider: divider ?? this.divider,
  );
}

class QuickdrawTextStyles {
  /// The big "GO!"
  final TextStyle signal;

  /// "Wait..." and "Too early!" on a half
  final TextStyle message;

  /// Smaller line below the message
  final TextStyle hint;

  const QuickdrawTextStyles({
    required this.signal,
    required this.message,
    required this.hint,
  });

  QuickdrawTextStyles copyWith({
    TextStyle? signal,
    TextStyle? message,
    TextStyle? hint,
  }) => QuickdrawTextStyles(
    signal: signal ?? this.signal,
    message: message ?? this.message,
    hint: hint ?? this.hint,
  );
}

class QuickdrawDimens {
  /// Icon above "Wait..." and "Too early!"
  final double iconSize;

  /// Icon next to "GO!"
  final double signalIconSize;

  /// Thickness of the line between the halves
  final double dividerThickness;

  const QuickdrawDimens({
    required this.iconSize,
    required this.signalIconSize,
    required this.dividerThickness,
  });

  QuickdrawDimens copyWith({
    double? iconSize,
    double? signalIconSize,
    double? dividerThickness,
  }) => QuickdrawDimens(
    iconSize: iconSize ?? this.iconSize,
    signalIconSize: signalIconSize ?? this.signalIconSize,
    dividerThickness: dividerThickness ?? this.dividerThickness,
  );
}
