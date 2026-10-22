import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/game/minesweeper/game/model/minesweeper_cell.dart';
import 'package:flutter_mini_games/src/game/minesweeper/style/minesweeper_theme.dart';

class MinesweeperCellTile extends StatelessWidget {
  final MinesweeperCell cell;
  final double size;

  /// Shows the hidden mines and wrong flags (after losing)
  final bool showMines;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const MinesweeperCellTile({
    required this.cell,
    required this.size,
    required this.showMines,
    this.onTap,
    this.onLongPress,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = MinesweeperTheme.of(context);
    final colors = theme.colors;
    final Color background;
    if (cell.isExploded) {
      background = colors.cellExploded;
    } else if (cell.isRevealed) {
      background = colors.cellRevealed;
    } else {
      background = colors.cellHidden;
    }
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(theme.dimens.cellRadius),
        ),
        alignment: Alignment.center,
        child: _buildContent(theme),
      ),
    );
  }

  Widget? _buildContent(MinesweeperTheme theme) {
    final colors = theme.colors;
    final iconSize = size * 0.6;
    if (cell.isExploded) return Icon(Icons.brightness_7, size: iconSize, color: colors.mineExploded);
    if (cell.isFlagged) {
      if (showMines && !cell.isMine) return Icon(Icons.close, size: iconSize, color: colors.wrongFlag);
      return Icon(Icons.flag, size: iconSize, color: colors.flag);
    }
    if (!cell.isRevealed) {
      if (showMines && cell.isMine) return Icon(Icons.brightness_7, size: iconSize, color: colors.mine);
      return null;
    }
    if (cell.adjacentMines == 0) return null;
    return Text(
      '${cell.adjacentMines}',
      style: theme.textStyles.number.copyWith(
        fontSize: size * 0.55,
        height: 1,
        color: colors.number(cell.adjacentMines),
      ),
    );
  }
}
