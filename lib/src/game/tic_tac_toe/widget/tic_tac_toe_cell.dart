import 'package:flutter/material.dart';

class TicTacToeCell extends StatelessWidget {
  final String? value;
  final bool isWinningCell;
  final VoidCallback onTap;

  const TicTacToeCell({
    required this.isWinningCell,
    required this.onTap,
    this.value,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isWinningCell ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: value != null
              ? Text(
                  value!,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: value == 'X' ? Colors.blue : Colors.red,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
