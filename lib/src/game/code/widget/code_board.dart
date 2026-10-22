import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/game/code/game/logic/code_game_controller.dart';
import 'package:flutter_mini_games/src/game/code/game/model/code_peg.dart';
import 'package:flutter_mini_games/src/game/code/style/code_theme.dart';
import 'package:flutter_mini_games/src/game/code/widget/code_feedback_markers.dart';
import 'package:flutter_mini_games/src/game/code/widget/code_peg_shape.dart';

/// The hidden code on top, below it one row per try: submitted guesses with their feedback,
/// the guess being built and the empty rows that are left.
class CodeBoard extends StatelessWidget {
  /// Width / height that fits the hidden code row and [CodeGameController.maxTries] rows
  static const aspectRatio = 0.6;

  /// Rows: the hidden code + one per try
  static const _rowCount = CodeGameController.maxTries + 1;

  /// Columns, in slot widths: the pegs + the feedback markers
  static const _columnCount = CodeGameController.codeLength + 1;

  final CodeGameController controller;

  const CodeBoard({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CodeTheme.of(context);
    final dimens = theme.dimens;
    return LayoutBuilder(
      builder: (context, constraints) {
        final rowPadding = dimens.slotSpacing / 2;
        // Largest slot for which all rows fit
        final slotByHeight = (constraints.maxHeight - dimens.rowSpacing * (_rowCount - 1)) / _rowCount - rowPadding * 2;
        final slotByWidth = (constraints.maxWidth - rowPadding * 2 - dimens.slotSpacing * (_columnCount + 1)) / _columnCount;
        final slot = max(0.0, min(slotByHeight, slotByWidth));
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: dimens.rowSpacing,
          children: [
            _buildSecretRow(theme, slot, rowPadding),
            for (var row = 0; row < CodeGameController.maxTries; row++) _buildGuessRow(theme, row, slot, rowPadding),
          ],
        );
      },
    );
  }

  Widget _buildSecretRow(CodeTheme theme, double slot, double padding) {
    final isRevealed = controller.isFinished;
    return _CodeRow(
      key: const ValueKey('code_row_secret'),
      color: theme.colors.row,
      padding: padding,
      slots: [
        for (var i = 0; i < CodeGameController.codeLength; i++)
          SizedBox.square(
            dimension: slot,
            child: isRevealed
                ? _CodeSlot(peg: controller.secret[i], isActive: false)
                : DecoratedBox(
                    decoration: BoxDecoration(color: theme.colors.secret, shape: BoxShape.circle),
                    child: Center(
                      child: FittedBox(child: Text('?', style: theme.textStyles.secretMark)),
                    ),
                  ),
          ),
      ],
      trailing: SizedBox.square(
        dimension: slot,
        child: Icon(
          isRevealed ? Icons.lock_open : Icons.lock_outline,
          size: slot * 0.6,
          color: theme.colors.secret,
        ),
      ),
    );
  }

  Widget _buildGuessRow(CodeTheme theme, int row, double slot, double padding) {
    final guesses = controller.guesses;
    final isCurrent = !controller.isFinished && row == guesses.length;
    final guess = row < guesses.length ? guesses[row] : null;
    final current = controller.currentGuess;
    final nextEmpty = current.indexOf(null);
    return _CodeRow(
      key: ValueKey('code_row_$row'),
      color: isCurrent ? theme.colors.currentRow : theme.colors.row,
      padding: padding,
      slots: [
        for (var i = 0; i < CodeGameController.codeLength; i++)
          SizedBox.square(
            dimension: slot,
            child: isCurrent
                ? GestureDetector(
                    key: ValueKey('code_slot_$i'),
                    behavior: HitTestBehavior.opaque,
                    onTap: current[i] == null ? null : () => controller.clearSlot(i),
                    child: _CodeSlot(peg: current[i], isActive: i == nextEmpty),
                  )
                : _CodeSlot(peg: guess?.pegs[i], isActive: false),
          ),
      ],
      trailing: SizedBox.square(
        dimension: slot,
        child: isCurrent && controller.canSubmit ? _buildSubmit(theme, slot) : CodeFeedbackMarkers(feedback: guess?.feedback, codeLength: CodeGameController.codeLength),
      ),
    );
  }

  /// Submit right next to a complete guess, also reachable when the controls are scrolled away on short screens
  Widget _buildSubmit(CodeTheme theme, double slot) {
    return Semantics(
      button: true,
      label: 'Submit',
      child: GestureDetector(
        key: const ValueKey('code_row_submit'),
        behavior: HitTestBehavior.opaque,
        onTap: controller.submit,
        child: DecoratedBox(
          decoration: BoxDecoration(color: theme.colors.submit, shape: BoxShape.circle),
          child: Icon(Icons.check, size: slot * 0.6, color: theme.colors.onSubmit),
        ),
      ),
    );
  }
}

class _CodeRow extends StatelessWidget {
  final Color color;
  final double padding;
  final List<Widget> slots;
  final Widget trailing;

  const _CodeRow({
    required this.color,
    required this.padding,
    required this.slots,
    required this.trailing,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CodeTheme.of(context);
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(theme.dimens.rowRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: theme.dimens.slotSpacing,
        children: [
          ...slots,
          SizedBox(width: theme.dimens.slotSpacing),
          trailing,
        ],
      ),
    );
  }
}

class _CodeSlot extends StatelessWidget {
  final CodePeg? peg;

  /// The slot that the next picked symbol goes into
  final bool isActive;

  const _CodeSlot({
    required this.peg,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CodeTheme.of(context);
    final peg = this.peg;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.slot,
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? theme.colors.slotBorderActive : theme.colors.slotBorder,
          width: theme.dimens.slotBorderWidth,
        ),
      ),
      child: peg == null
          ? null
          : FractionallySizedBox(
              widthFactor: theme.dimens.pegScale,
              heightFactor: theme.dimens.pegScale,
              child: CodePegShape(peg: peg, color: theme.colors.peg(peg)),
            ),
    );
  }
}
