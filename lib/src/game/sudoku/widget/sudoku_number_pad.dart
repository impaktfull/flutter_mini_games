import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/game/sudoku/game/logic/sudoku_game_controller.dart';
import 'package:flutter_mini_games/src/game/sudoku/style/sudoku_theme.dart';

/// Digits 1-9, the notes toggle, erase and an optional [trailing] widget (e.g. a reset button)
class SudokuNumberPad extends StatelessWidget {
  final SudokuGameController controller;
  final Widget? trailing;

  const SudokuNumberPad({
    required this.controller,
    this.trailing,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SudokuTheme.of(context);
    final canEdit = !controller.isFinished && controller.selected != null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: theme.dimens.keySpacing * 2,
      children: [
        Row(
          spacing: theme.dimens.keySpacing,
          children: [
            for (var digit = 1; digit <= 9; digit++)
              Expanded(
                child: _SudokuKey(
                  key: ValueKey('sudoku_key_$digit'),
                  onTap: canEdit && !controller.isDigitComplete(digit) ? () => controller.enterDigit(digit) : null,
                  child: FittedBox(child: Text('$digit', style: theme.textStyles.key)),
                ),
              ),
          ],
        ),
        Row(
          spacing: theme.dimens.keySpacing * 2,
          children: [
            Expanded(
              child: _SudokuKey(
                key: const ValueKey('sudoku_key_notes'),
                isActive: controller.isNotesMode,
                onTap: controller.isFinished ? null : controller.toggleNotesMode,
                icon: Icons.edit_outlined,
                label: controller.isNotesMode ? 'Notes on' : 'Notes off',
              ),
            ),
            Expanded(
              child: _SudokuKey(
                key: const ValueKey('sudoku_key_erase'),
                onTap: canEdit ? controller.erase : null,
                icon: Icons.backspace_outlined,
                label: 'Erase',
              ),
            ),
            ?trailing,
          ],
        ),
      ],
    );
  }
}

class _SudokuKey extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isActive;
  final Widget? child;
  final IconData? icon;
  final String? label;

  const _SudokuKey({
    required this.onTap,
    this.isActive = false,
    this.child,
    this.icon,
    this.label,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SudokuTheme.of(context);
    final icon = this.icon;
    final label = this.label;
    return Opacity(
      opacity: onTap == null ? theme.dimens.disabledKeyOpacity : 1,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: theme.dimens.keyHeight,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? theme.colors.keyActive : theme.colors.key,
            borderRadius: BorderRadius.circular(theme.dimens.keyRadius),
          ),
          alignment: Alignment.center,
          child:
              child ??
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  if (icon != null) Icon(icon, size: 20, color: isActive ? theme.colors.keyIconActive : theme.colors.keyIcon),
                  if (label != null)
                    Flexible(
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: isActive ? theme.textStyles.keyLabelActive : theme.textStyles.keyLabel,
                      ),
                    ),
                ],
              ),
        ),
      ),
    );
  }
}
