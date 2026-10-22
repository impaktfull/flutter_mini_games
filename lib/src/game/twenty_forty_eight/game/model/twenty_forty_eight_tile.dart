/// A numbered tile on the 2048 board.
///
/// The [id] stays the same while a tile slides, so the board can animate it.
/// When two tiles merge, the tile closest to the wall keeps its id.
class TwentyFortyEightTile {
  final int id;
  final int value;
  final int row;
  final int col;

  /// Spawned by the last move
  final bool isNew;

  /// Created by a merge in the last move
  final bool isMerged;

  const TwentyFortyEightTile({
    required this.id,
    required this.value,
    required this.row,
    required this.col,
    this.isNew = false,
    this.isMerged = false,
  });

  TwentyFortyEightTile copyWith({
    int? value,
    int? row,
    int? col,
    bool? isNew,
    bool? isMerged,
  }) => TwentyFortyEightTile(
    id: id,
    value: value ?? this.value,
    row: row ?? this.row,
    col: col ?? this.col,
    isNew: isNew ?? this.isNew,
    isMerged: isMerged ?? this.isMerged,
  );
}
