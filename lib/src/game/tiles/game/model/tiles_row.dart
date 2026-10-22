/// One row of four tiles, exactly one of them is dark.
class TilesRow {
  /// Rows are numbered from the bottom: row 0 is the first one to tap
  final int index;

  /// Column (0..3) of the dark tile
  final int darkColumn;

  /// Game time in seconds at which the dark tile was tapped, null while it is not tapped
  final double? tappedAt;

  const TilesRow({
    required this.index,
    required this.darkColumn,
    this.tappedAt,
  });

  bool get isTapped => tappedAt != null;

  TilesRow copyWith({double? tappedAt}) => TilesRow(
    index: index,
    darkColumn: darkColumn,
    tappedAt: tappedAt ?? this.tappedAt,
  );
}

enum TilesMistakeKind {
  /// A light tile was tapped
  wrongTile,

  /// A dark tile left the bottom of the board without being tapped
  missedTile,
}

/// The tile that ended the game
class TilesMistake {
  final TilesMistakeKind kind;
  final int row;
  final int column;

  const TilesMistake({
    required this.kind,
    required this.row,
    required this.column,
  });
}
