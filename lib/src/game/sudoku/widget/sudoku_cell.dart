import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/game/sudoku/style/sudoku_theme.dart';

class SudokuCell extends StatelessWidget {
  /// Digit in the cell, 0 when empty
  final int value;

  /// Pencil marks, only shown when the cell is empty
  final Set<int> notes;
  final bool isGiven;
  final bool isWrong;
  final bool isSelected;
  final bool isPeer;
  final bool hasSameValue;
  final VoidCallback? onTap;

  const SudokuCell({
    required this.value,
    required this.notes,
    required this.isGiven,
    required this.isWrong,
    required this.isSelected,
    required this.isPeer,
    required this.hasSameValue,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SudokuTheme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ColoredBox(
        color: _backgroundColor(theme.colors),
        child: value != 0 ? _buildValue(theme) : _buildNotes(theme),
      ),
    );
  }

  Color _backgroundColor(SudokuColors colors) {
    if (isWrong) return colors.cellWrong;
    if (isSelected) return colors.cellSelected;
    if (hasSameValue) return colors.cellSameValue;
    if (isPeer) return colors.cellPeer;
    return colors.cell;
  }

  Widget _buildValue(SudokuTheme theme) {
    final TextStyle style;
    if (isWrong) {
      style = theme.textStyles.wrong;
    } else if (isSelected) {
      style = theme.textStyles.selected;
    } else if (isGiven) {
      style = theme.textStyles.given;
    } else {
      style = theme.textStyles.entry;
    }
    return Padding(
      padding: const EdgeInsets.all(6),
      child: FittedBox(child: Text('$value', style: style)),
    );
  }

  Widget _buildNotes(SudokuTheme theme) {
    if (notes.isEmpty) return const SizedBox.expand();
    final style = isSelected ? theme.textStyles.note.copyWith(color: theme.textStyles.selected.color) : theme.textStyles.note;
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Column(
        children: [
          for (var row = 0; row < 3; row++)
            Expanded(
              child: Row(
                children: [
                  for (var col = 0; col < 3; col++)
                    Expanded(
                      child: notes.contains(row * 3 + col + 1) ? FittedBox(child: Text('${row * 3 + col + 1}', style: style)) : const SizedBox.shrink(),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
