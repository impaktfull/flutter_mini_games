import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/game/code/game/model/code_feedback.dart';
import 'package:flutter_mini_games/src/game/code/style/code_theme.dart';

/// Feedback of a guess as a 2x2 grid of markers:
/// filled = right symbol in the right place, hollow ring = right symbol in the wrong place.
class CodeFeedbackMarkers extends StatelessWidget {
  final CodeFeedback? feedback;
  final int codeLength;

  const CodeFeedbackMarkers({
    required this.feedback,
    required this.codeLength,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CodeTheme.of(context);
    final feedback = this.feedback;
    return Semantics(
      label: feedback == null ? null : '${feedback.exact} right place, ${feedback.misplaced} wrong place',
      child: CustomPaint(
        painter: _CodeFeedbackPainter(
          exact: feedback?.exact ?? 0,
          misplaced: feedback?.misplaced ?? 0,
          codeLength: codeLength,
          exactColor: theme.colors.feedbackExact,
          misplacedColor: theme.colors.feedbackMisplaced,
          emptyColor: theme.colors.feedbackEmpty,
          stroke: theme.dimens.feedbackMarkerStroke,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _CodeFeedbackPainter extends CustomPainter {
  final int exact;
  final int misplaced;
  final int codeLength;
  final Color exactColor;
  final Color misplacedColor;
  final Color emptyColor;
  final double stroke;

  const _CodeFeedbackPainter({
    required this.exact,
    required this.misplaced,
    required this.codeLength,
    required this.exactColor,
    required this.misplacedColor,
    required this.emptyColor,
    required this.stroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const columns = 2;
    final rows = (codeLength / columns).ceil();
    final cellWidth = size.width / columns;
    final cellHeight = size.height / rows;
    final cell = cellWidth < cellHeight ? cellWidth : cellHeight;
    final radius = cell * 0.34;
    final origin = Offset((size.width - cell * columns) / 2, (size.height - cell * rows) / 2);

    for (var i = 0; i < codeLength; i++) {
      final center = origin + Offset(cell * (i % columns + 0.5), cell * (i ~/ columns + 0.5));
      if (i < exact) {
        canvas.drawCircle(center, radius, Paint()..color = exactColor);
      } else if (i < exact + misplaced) {
        canvas.drawCircle(
          center,
          radius - stroke / 2,
          Paint()
            ..color = misplacedColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = stroke,
        );
      } else {
        canvas.drawCircle(center, radius * 0.4, Paint()..color = emptyColor);
      }
    }
  }

  @override
  bool shouldRepaint(_CodeFeedbackPainter oldDelegate) =>
      oldDelegate.exact != exact ||
      oldDelegate.misplaced != misplaced ||
      oldDelegate.codeLength != codeLength ||
      oldDelegate.exactColor != exactColor ||
      oldDelegate.misplacedColor != misplacedColor ||
      oldDelegate.emptyColor != emptyColor ||
      oldDelegate.stroke != stroke;
}
