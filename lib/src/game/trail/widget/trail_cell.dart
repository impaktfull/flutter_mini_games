import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/widget/theme/theme_builder.dart';
import 'package:flutter_mini_games/src/game/trail/game/model/trail_direction.dart';
import 'package:flutter_mini_games/src/game/trail/style/trail_theme.dart';

class TrailCell extends StatelessWidget {
  final bool isFilled;
  final int? checkpointNumber;
  final bool isCurrentTarget;
  final bool isCompleted;
  final Set<TrailDirection> pathDirections;
  final VoidCallback? onTap;

  const TrailCell({
    required this.isFilled,
    required this.pathDirections,
    this.checkpointNumber,
    this.isCurrentTarget = false,
    this.isCompleted = false,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GameThemeBuilder<TrailTheme>(
      builder: (context, theme) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: theme.colors.cellEmpty,
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomPaint(
            painter: _TrailCellPainter(
              pathDirections: pathDirections,
              lineColor: theme.colors.pathLine,
              lineThickness: theme.dimens.lineThickness,
              isFilled: isFilled,
            ),
            child: checkpointNumber == null ? null : _buildCheckpoint(theme),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckpoint(TrailTheme theme) {
    final Color checkpointColor;
    if (isCompleted) {
      checkpointColor = theme.colors.checkpointCompletedBackground;
    } else if (isCurrentTarget) {
      checkpointColor = theme.colors.checkpointTargetBackground;
    } else {
      checkpointColor = theme.colors.checkpointBackground;
    }

    return Center(
      child: Container(
        width: theme.dimens.checkpointSize,
        height: theme.dimens.checkpointSize,
        decoration: BoxDecoration(
          color: checkpointColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: theme.colors.shadow.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            checkpointNumber.toString(),
            style: theme.textStyles.checkpointNumber,
          ),
        ),
      ),
    );
  }
}

class _TrailCellPainter extends CustomPainter {
  final Set<TrailDirection> pathDirections;
  final Color lineColor;
  final double lineThickness;
  final bool isFilled;

  _TrailCellPainter({
    required this.pathDirections,
    required this.lineColor,
    required this.lineThickness,
    required this.isFilled,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (pathDirections.isEmpty || !isFilled) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineThickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);

    // Extend past edges to cover gaps between cells
    const overshoot = 4.0;

    // Draw lines from center to edges based on path directions
    for (final direction in pathDirections) {
      final endPoint = switch (direction) {
        TrailDirection.up => Offset(center.dx, -overshoot),
        TrailDirection.down => Offset(center.dx, size.height + overshoot),
        TrailDirection.left => Offset(-overshoot, center.dy),
        TrailDirection.right => Offset(size.width + overshoot, center.dy),
      };
      canvas.drawLine(center, endPoint, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TrailCellPainter oldDelegate) {
    return !_setEquals(oldDelegate.pathDirections, pathDirections) ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.lineThickness != lineThickness ||
        oldDelegate.isFilled != isFilled;
  }

  static bool _setEquals(Set<TrailDirection> a, Set<TrailDirection> b) => a.length == b.length && a.containsAll(b);
}
