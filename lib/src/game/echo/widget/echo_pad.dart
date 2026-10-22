import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/widget/input/game_input_detector.dart';
import 'package:flutter_mini_games/src/game/echo/style/echo_theme.dart';

/// One of the four pads. Every pad has its own shape icon so pads never differ by color alone.
class EchoPad extends StatelessWidget {
  /// Shape icon per pad: circle, triangle, square, star
  static const icons = [Icons.circle_outlined, Icons.change_history, Icons.crop_square, Icons.star_border];

  static const _animationDuration = Duration(milliseconds: 90);

  final int pad;
  final bool isLit;
  final bool isWrong;
  final VoidCallback onTap;

  const EchoPad({
    required this.pad,
    required this.isLit,
    required this.isWrong,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = EchoTheme.of(context);
    final radius = BorderRadius.circular(theme.dimens.padRadius);
    // A pad has no keyboard input of its own: four autofocused detectors would compete for focus
    return ExcludeFocus(
      child: GameInputDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: isLit ? 1 : theme.dimens.idleScale,
          duration: _animationDuration,
          child: AnimatedContainer(
            duration: _animationDuration,
            decoration: BoxDecoration(
              color: theme.padColor(pad, isLit: isLit),
              borderRadius: radius,
              border: isWrong ? Border.all(color: theme.colors.mistake, width: theme.dimens.mistakeBorderWidth) : null,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) => Center(
                // Animates together with the pad color, so the icon never blends into the pad
                child: TweenAnimationBuilder<Color?>(
                  tween: ColorTween(end: isWrong ? theme.colors.mistake : theme.padIconColor(pad, isLit: isLit)),
                  duration: _animationDuration,
                  builder: (context, color, child) => Icon(
                    isWrong ? Icons.close : icons[pad],
                    size: constraints.biggest.shortestSide * theme.dimens.iconSizeFactor,
                    color: color,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
