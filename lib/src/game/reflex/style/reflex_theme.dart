import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';

class ReflexTheme extends GameTheme {
  final ReflexColors colors;
  final ReflexTextStyles textStyles;
  final ReflexDimens dimens;

  static ReflexTheme of(BuildContext context) => GameTheme.of<ReflexTheme>(context);

  const ReflexTheme({
    required this.colors,
    required this.textStyles,
    required this.dimens,
  });

  factory ReflexTheme.fromCore(CoreGameTheme core) {
    final colors = core.colors;
    return ReflexTheme(
      colors: ReflexColors(
        idle: colors.surface,
        onIdle: colors.text,
        waiting: colors.secondary,
        onWaiting: colors.onSecondary,
        go: colors.primary,
        onGo: colors.onPrimary,
        tooEarly: colors.error,
        onTooEarly: colors.onError,
        attempt: colors.surface,
        onAttempt: colors.text,
        attemptEmpty: colors.textMuted,
        attemptCurrent: colors.primary,
      ),
      textStyles: ReflexTextStyles(
        message: core.textStyles.title.copyWith(fontSize: 40, height: 1.1),
        hint: core.textStyles.body,
        header: core.textStyles.title,
        status: core.textStyles.body.copyWith(color: colors.textMuted),
        attemptLabel: core.textStyles.caption,
        attemptValue: core.textStyles.label,
      ),
      dimens: ReflexDimens(
        iconSize: 64,
        attemptRadius: core.dimens.radiusSmall,
        attemptBorderWidth: 2,
        attemptMinWidth: 56,
      ),
    );
  }

  ReflexTheme copyWith({
    ReflexColors? colors,
    ReflexTextStyles? textStyles,
    ReflexDimens? dimens,
  }) => ReflexTheme(
    colors: colors ?? this.colors,
    textStyles: textStyles ?? this.textStyles,
    dimens: dimens ?? this.dimens,
  );
}

class ReflexColors {
  /// Board before the start, between tries and at the end; [onIdle] for text and icons on it
  final Color idle;
  final Color onIdle;

  /// Board while waiting for the change
  final Color waiting;
  final Color onWaiting;

  /// Board after the change: tap now
  final Color go;
  final Color onGo;

  /// Board after tapping too early
  final Color tooEarly;
  final Color onTooEarly;

  /// Background and text of a try in the header
  final Color attempt;
  final Color onAttempt;

  /// Text of a try that is not played yet
  final Color attemptEmpty;

  /// Border of the try that is being played
  final Color attemptCurrent;

  const ReflexColors({
    required this.idle,
    required this.onIdle,
    required this.waiting,
    required this.onWaiting,
    required this.go,
    required this.onGo,
    required this.tooEarly,
    required this.onTooEarly,
    required this.attempt,
    required this.onAttempt,
    required this.attemptEmpty,
    required this.attemptCurrent,
  });

  ReflexColors copyWith({
    Color? idle,
    Color? onIdle,
    Color? waiting,
    Color? onWaiting,
    Color? go,
    Color? onGo,
    Color? tooEarly,
    Color? onTooEarly,
    Color? attempt,
    Color? onAttempt,
    Color? attemptEmpty,
    Color? attemptCurrent,
  }) => ReflexColors(
    idle: idle ?? this.idle,
    onIdle: onIdle ?? this.onIdle,
    waiting: waiting ?? this.waiting,
    onWaiting: onWaiting ?? this.onWaiting,
    go: go ?? this.go,
    onGo: onGo ?? this.onGo,
    tooEarly: tooEarly ?? this.tooEarly,
    onTooEarly: onTooEarly ?? this.onTooEarly,
    attempt: attempt ?? this.attempt,
    onAttempt: onAttempt ?? this.onAttempt,
    attemptEmpty: attemptEmpty ?? this.attemptEmpty,
    attemptCurrent: attemptCurrent ?? this.attemptCurrent,
  );
}

class ReflexTextStyles {
  /// Big message on the board ("Wait...", "Tap!", "245 ms"), colored per phase
  final TextStyle message;

  /// Smaller line below the message on the board
  final TextStyle hint;

  /// Average in the header
  final TextStyle header;

  /// Status next to the average in the header
  final TextStyle status;

  /// "#1" label of a try in the header
  final TextStyle attemptLabel;

  /// Time of a try in the header
  final TextStyle attemptValue;

  const ReflexTextStyles({
    required this.message,
    required this.hint,
    required this.header,
    required this.status,
    required this.attemptLabel,
    required this.attemptValue,
  });

  ReflexTextStyles copyWith({
    TextStyle? message,
    TextStyle? hint,
    TextStyle? header,
    TextStyle? status,
    TextStyle? attemptLabel,
    TextStyle? attemptValue,
  }) => ReflexTextStyles(
    message: message ?? this.message,
    hint: hint ?? this.hint,
    header: header ?? this.header,
    status: status ?? this.status,
    attemptLabel: attemptLabel ?? this.attemptLabel,
    attemptValue: attemptValue ?? this.attemptValue,
  );
}

class ReflexDimens {
  /// Size of the icon on the board
  final double iconSize;

  /// Corner radius of a try in the header
  final double attemptRadius;

  /// Border width of the try that is being played
  final double attemptBorderWidth;

  /// Minimum width of a try in the header
  final double attemptMinWidth;

  const ReflexDimens({
    required this.iconSize,
    required this.attemptRadius,
    required this.attemptBorderWidth,
    required this.attemptMinWidth,
  });

  ReflexDimens copyWith({
    double? iconSize,
    double? attemptRadius,
    double? attemptBorderWidth,
    double? attemptMinWidth,
  }) => ReflexDimens(
    iconSize: iconSize ?? this.iconSize,
    attemptRadius: attemptRadius ?? this.attemptRadius,
    attemptBorderWidth: attemptBorderWidth ?? this.attemptBorderWidth,
    attemptMinWidth: attemptMinWidth ?? this.attemptMinWidth,
  );
}
