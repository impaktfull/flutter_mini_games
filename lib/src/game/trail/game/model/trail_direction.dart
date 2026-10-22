/// Direction from a cell towards a neighbouring cell on the trail
enum TrailDirection {
  up,
  down,
  left,
  right;

  /// Direction from [from] towards the adjacent cell [to]
  static TrailDirection between((int, int) from, (int, int) to) {
    if (to.$1 < from.$1) return TrailDirection.up;
    if (to.$1 > from.$1) return TrailDirection.down;
    if (to.$2 < from.$2) return TrailDirection.left;
    return TrailDirection.right;
  }
}
