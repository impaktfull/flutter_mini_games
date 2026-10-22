/// A pair of columns with a gap in between, in world units.
///
/// The world is [FlitGameController.worldWidth] wide and 1.0 high, y grows downwards.
class FlitColumn {
  /// Left edge of the columns
  final double x;

  /// Vertical center of the gap
  final double gapCenter;

  /// Height of the gap
  final double gapSize;

  /// Whether the flyer passed this column (and scored a point for it)
  final bool isPassed;

  const FlitColumn({
    required this.x,
    required this.gapCenter,
    required this.gapSize,
    this.isPassed = false,
  });

  /// Bottom of the top column
  double get gapTop => gapCenter - gapSize / 2;

  /// Top of the bottom column
  double get gapBottom => gapCenter + gapSize / 2;

  FlitColumn copyWith({
    double? x,
    bool? isPassed,
  }) => FlitColumn(
    x: x ?? this.x,
    gapCenter: gapCenter,
    gapSize: gapSize,
    isPassed: isPassed ?? this.isPassed,
  );
}
