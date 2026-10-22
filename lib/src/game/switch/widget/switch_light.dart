import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/game/switch/style/switch_theme.dart';

/// Duration of switching a light on or off
const _switchDuration = Duration(milliseconds: 150);

/// One light of the board: filled bulb on the lit color when on, outlined bulb when off
class SwitchLight extends StatelessWidget {
  final bool isLit;
  final bool isHint;
  final double size;
  final VoidCallback? onTap;

  const SwitchLight({
    required this.isLit,
    required this.isHint,
    required this.size,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SwitchGameTheme.of(context);
    final colors = theme.colors;
    return Semantics(
      button: true,
      label: isLit ? 'Light on' : 'Light off',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        // Only the decoration animates, the size follows the board right away
        child: SizedBox.square(
          dimension: size,
          child: AnimatedContainer(
            duration: _switchDuration,
            decoration: BoxDecoration(
              color: isLit ? colors.lightOn : colors.lightOff,
              borderRadius: BorderRadius.circular(theme.dimens.cellRadius),
              border: isHint ? Border.all(color: colors.hint, width: theme.dimens.hintBorderWidth) : null,
            ),
            alignment: Alignment.center,
            child: Icon(
              isLit ? Icons.lightbulb : Icons.lightbulb_outline,
              size: size * theme.dimens.iconScale,
              color: isLit ? colors.iconOn : colors.iconOff,
            ),
          ),
        ),
      ),
    );
  }
}

/// Glow behind a lit light: a solid color blurred by the shadow, painted in a layer below the lights
class SwitchLightGlow extends StatelessWidget {
  final bool isLit;
  final double size;

  const SwitchLightGlow({
    required this.isLit,
    required this.size,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SwitchGameTheme.of(context);
    return SizedBox.square(
      dimension: size,
      child: AnimatedContainer(
        duration: _switchDuration,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(theme.dimens.cellRadius),
          boxShadow: [
            BoxShadow(
              color: theme.colors.glow,
              blurRadius: isLit ? theme.dimens.glowRadius : 0,
              spreadRadius: isLit ? 2 : -size / 2,
            ),
          ],
        ),
      ),
    );
  }
}
