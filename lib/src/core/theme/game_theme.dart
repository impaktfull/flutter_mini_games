import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Base class of [CoreGameTheme] and every game theme.
///
/// Every game theme follows the same shape:
/// - `colors`, `textStyles` and `dimens`
/// - `fromCore(CoreGameTheme core)` to derive the defaults from the core theme
/// - `copyWith` on the theme and on each of its parts
abstract class GameTheme {
  static T of<T extends GameTheme>(BuildContext context) => Provider.of<T>(context);

  const GameTheme();
}

/// Lets a host tweak the default theme of a game, e.g.
/// `theme: (theme) => theme.copyWith(colors: theme.colors.copyWith(pathLine: Colors.teal))`
typedef GameThemeOverride<T extends GameTheme> = T Function(T theme);

/// Shared theme for all games. Game themes are derived from it.
class CoreGameTheme extends GameTheme {
  final CoreGameColors colors;
  final CoreGameTextStyles textStyles;
  final CoreGameDimens dimens;

  static CoreGameTheme of(BuildContext context) => GameTheme.of<CoreGameTheme>(context);

  const CoreGameTheme({
    required this.colors,
    required this.textStyles,
    required this.dimens,
  });

  factory CoreGameTheme.fromColors(
    CoreGameColors colors, {
    String? fontFamily,
  }) => CoreGameTheme(
    colors: colors,
    textStyles: CoreGameTextStyles.fromColors(colors, fontFamily: fontFamily),
    dimens: const CoreGameDimens(),
  );

  factory CoreGameTheme.light() => CoreGameTheme.fromColors(CoreGameColors.light());

  factory CoreGameTheme.dark() => CoreGameTheme.fromColors(CoreGameColors.dark());

  /// Follows the colors and font of the host app's Material theme
  factory CoreGameTheme.fromMaterial(ThemeData theme) {
    final scheme = theme.colorScheme;
    return CoreGameTheme.fromColors(
      CoreGameColors(
        primary: scheme.primary,
        onPrimary: scheme.onPrimary,
        secondary: scheme.inverseSurface,
        onSecondary: scheme.onInverseSurface,
        background: scheme.surface,
        surface: scheme.surfaceContainerHighest,
        text: scheme.onSurface,
        textMuted: scheme.onSurfaceVariant,
        error: scheme.error,
        onError: scheme.onError,
        shadow: scheme.shadow,
      ),
      fontFamily: theme.textTheme.bodyMedium?.fontFamily,
    );
  }

  CoreGameTheme copyWith({
    CoreGameColors? colors,
    CoreGameTextStyles? textStyles,
    CoreGameDimens? dimens,
  }) => CoreGameTheme(
    colors: colors ?? this.colors,
    textStyles: textStyles ?? this.textStyles,
    dimens: dimens ?? this.dimens,
  );
}

class CoreGameColors {
  /// Main accent color (buttons, highlights, player O)
  final Color primary;

  /// Text and icons on [primary]
  final Color onPrimary;

  /// Second accent color (player X, checkpoints)
  final Color secondary;

  /// Text and icons on [secondary]
  final Color onSecondary;

  /// Screen background
  final Color background;

  /// Cells, panels and other elements on top of [background]
  final Color surface;

  /// Primary text color
  final Color text;

  /// Secondary text color (captions, labels)
  final Color textMuted;

  /// Mistakes and wrong moves
  final Color error;

  /// Text and icons on [error]
  final Color onError;

  /// Shadow color, used with alpha
  final Color shadow;

  const CoreGameColors({
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.background,
    required this.surface,
    required this.text,
    required this.textMuted,
    required this.error,
    required this.onError,
    required this.shadow,
  });

  factory CoreGameColors.light() => const CoreGameColors(
    primary: Color(0xFF7D64F2),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF1A1A1A),
    onSecondary: Color(0xFFFFFFFF),
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFF5F5F5),
    text: Color(0xFF000000),
    textMuted: Color(0xFF6B6B6B),
    error: Color(0xFFD32F2F),
    onError: Color(0xFFFFFFFF),
    shadow: Color(0xFF000000),
  );

  factory CoreGameColors.dark() => const CoreGameColors(
    primary: Color(0xFF9D8AF5),
    onPrimary: Color(0xFF000000),
    secondary: Color(0xFFE6E6E6),
    onSecondary: Color(0xFF1A1A1A),
    background: Color(0xFF121212),
    surface: Color(0xFF242424),
    text: Color(0xFFFFFFFF),
    textMuted: Color(0xFFA0A0A0),
    error: Color(0xFFFF6B6B),
    onError: Color(0xFF1A1A1A),
    shadow: Color(0xFF000000),
  );

  CoreGameColors copyWith({
    Color? primary,
    Color? onPrimary,
    Color? secondary,
    Color? onSecondary,
    Color? background,
    Color? surface,
    Color? text,
    Color? textMuted,
    Color? error,
    Color? onError,
    Color? shadow,
  }) => CoreGameColors(
    primary: primary ?? this.primary,
    onPrimary: onPrimary ?? this.onPrimary,
    secondary: secondary ?? this.secondary,
    onSecondary: onSecondary ?? this.onSecondary,
    background: background ?? this.background,
    surface: surface ?? this.surface,
    text: text ?? this.text,
    textMuted: textMuted ?? this.textMuted,
    error: error ?? this.error,
    onError: onError ?? this.onError,
    shadow: shadow ?? this.shadow,
  );
}

class CoreGameTextStyles {
  /// Bold 24px title text
  final TextStyle title;

  /// Regular 16px body text
  final TextStyle body;

  /// Bold 16px text for buttons and the app bar
  final TextStyle label;

  /// Regular 12px muted text
  final TextStyle caption;

  const CoreGameTextStyles({
    required this.title,
    required this.body,
    required this.label,
    required this.caption,
  });

  factory CoreGameTextStyles.fromColors(
    CoreGameColors colors, {
    String? fontFamily,
  }) => CoreGameTextStyles(
    title: TextStyle(fontFamily: fontFamily, fontSize: 24, fontWeight: FontWeight.bold, color: colors.text),
    body: TextStyle(fontFamily: fontFamily, fontSize: 16, color: colors.text),
    label: TextStyle(fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.bold, color: colors.text),
    caption: TextStyle(fontFamily: fontFamily, fontSize: 12, color: colors.textMuted),
  );

  CoreGameTextStyles copyWith({
    TextStyle? title,
    TextStyle? body,
    TextStyle? label,
    TextStyle? caption,
  }) => CoreGameTextStyles(
    title: title ?? this.title,
    body: body ?? this.body,
    label: label ?? this.label,
    caption: caption ?? this.caption,
  );
}

class CoreGameDimens {
  /// Corner radius of boards and panels
  final double radiusLarge;

  /// Corner radius of cells and buttons
  final double radiusSmall;

  /// Default padding and spacing
  final double padding;

  const CoreGameDimens({
    this.radiusLarge = 16,
    this.radiusSmall = 8,
    this.padding = 16,
  });

  CoreGameDimens copyWith({
    double? radiusLarge,
    double? radiusSmall,
    double? padding,
  }) => CoreGameDimens(
    radiusLarge: radiusLarge ?? this.radiusLarge,
    radiusSmall: radiusSmall ?? this.radiusSmall,
    padding: padding ?? this.padding,
  );
}
