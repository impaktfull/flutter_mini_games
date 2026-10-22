import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/theme/game_theme.dart';

class EchoTheme extends GameTheme {
  final EchoColors colors;
  final EchoTextStyles textStyles;
  final EchoDimens dimens;

  static EchoTheme of(BuildContext context) => GameTheme.of<EchoTheme>(context);

  const EchoTheme({
    required this.colors,
    required this.textStyles,
    required this.dimens,
  });

  factory EchoTheme.fromCore(CoreGameTheme core) {
    return EchoTheme(
      colors: EchoColors(
        pads: [core.colors.primary, core.colors.secondary, core.colors.error, core.colors.textMuted],
        onPads: [core.colors.onPrimary, core.colors.onSecondary, core.colors.onError, core.colors.background],
        idle: core.colors.background,
        mistake: core.colors.text,
      ),
      textStyles: EchoTextStyles(
        score: core.textStyles.title,
        status: core.textStyles.body.copyWith(color: core.colors.textMuted),
        yourTurn: core.textStyles.label.copyWith(color: core.colors.primary),
      ),
      dimens: EchoDimens(
        padRadius: core.dimens.radiusLarge,
        padGap: 12,
        idleBlend: 0.65,
        idleScale: 0.94,
        iconSizeFactor: 0.32,
        mistakeBorderWidth: 4,
      ),
    );
  }

  EchoTheme copyWith({
    EchoColors? colors,
    EchoTextStyles? textStyles,
    EchoDimens? dimens,
  }) => EchoTheme(
    colors: colors ?? this.colors,
    textStyles: textStyles ?? this.textStyles,
    dimens: dimens ?? this.dimens,
  );

  /// Solid color of [pad]: its full color when lit, blended towards [EchoColors.idle] otherwise
  Color padColor(int pad, {required bool isLit}) {
    final color = colors.pads[pad];
    return isLit ? color : Color.lerp(color, colors.idle, dimens.idleBlend)!;
  }

  /// Color of the icon on [pad]
  Color padIconColor(int pad, {required bool isLit}) => isLit ? colors.onPads[pad] : colors.pads[pad];
}

class EchoColors {
  /// Lit color of each of the four pads (top left, top right, bottom left, bottom right)
  final List<Color> pads;

  /// Icon color on each lit pad
  final List<Color> onPads;

  /// Unlit pads blend their color towards this color
  final Color idle;

  /// Border of the wrong pad when the game is over
  final Color mistake;

  const EchoColors({
    required this.pads,
    required this.onPads,
    required this.idle,
    required this.mistake,
  }) : assert(pads.length == 4 && onPads.length == 4);

  EchoColors copyWith({
    List<Color>? pads,
    List<Color>? onPads,
    Color? idle,
    Color? mistake,
  }) => EchoColors(
    pads: pads ?? this.pads,
    onPads: onPads ?? this.onPads,
    idle: idle ?? this.idle,
    mistake: mistake ?? this.mistake,
  );
}

class EchoTextStyles {
  final TextStyle score;
  final TextStyle status;

  /// "Your turn" while the player repeats the sequence
  final TextStyle yourTurn;

  const EchoTextStyles({
    required this.score,
    required this.status,
    required this.yourTurn,
  });

  EchoTextStyles copyWith({
    TextStyle? score,
    TextStyle? status,
    TextStyle? yourTurn,
  }) => EchoTextStyles(
    score: score ?? this.score,
    status: status ?? this.status,
    yourTurn: yourTurn ?? this.yourTurn,
  );
}

class EchoDimens {
  final double padRadius;

  /// Space between the pads
  final double padGap;

  /// How far unlit pads blend towards the idle color, 0..1
  final double idleBlend;

  /// Scale of an unlit pad, a lit pad has scale 1
  final double idleScale;

  /// Icon size relative to the pad size
  final double iconSizeFactor;
  final double mistakeBorderWidth;

  const EchoDimens({
    required this.padRadius,
    required this.padGap,
    required this.idleBlend,
    required this.idleScale,
    required this.iconSizeFactor,
    required this.mistakeBorderWidth,
  });

  EchoDimens copyWith({
    double? padRadius,
    double? padGap,
    double? idleBlend,
    double? idleScale,
    double? iconSizeFactor,
    double? mistakeBorderWidth,
  }) => EchoDimens(
    padRadius: padRadius ?? this.padRadius,
    padGap: padGap ?? this.padGap,
    idleBlend: idleBlend ?? this.idleBlend,
    idleScale: idleScale ?? this.idleScale,
    iconSizeFactor: iconSizeFactor ?? this.iconSizeFactor,
    mistakeBorderWidth: mistakeBorderWidth ?? this.mistakeBorderWidth,
  );
}
