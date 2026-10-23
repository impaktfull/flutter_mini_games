import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/game/pairs/game/model/pairs_card.dart';
import 'package:flutter_mini_games/src/game/pairs/style/pairs_theme.dart';

/// One card that turns around its vertical axis when it is flipped
class PairsCardTile extends StatelessWidget {
  static const flipDuration = Duration(milliseconds: 250);

  /// Faces of the pairs, one per pair value (enough for the largest board)
  static const faceIcons = <IconData>[
    Icons.star,
    Icons.favorite,
    Icons.pets,
    Icons.local_florist,
    Icons.wb_sunny,
    Icons.music_note,
    Icons.rocket_launch,
    Icons.directions_bike,
    Icons.anchor,
    Icons.cake,
    Icons.bolt,
    Icons.eco,
    Icons.sailing,
    Icons.icecream,
    Icons.sports_soccer,
    Icons.nightlight_round,
    Icons.headphones,
    Icons.local_cafe,
  ];

  final PairsCard card;
  final double size;
  final VoidCallback? onTap;

  const PairsCardTile({
    required this.card,
    required this.size,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = PairsTheme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox.square(
        dimension: size,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: card.isFaceUp ? 1 : 0),
          duration: flipDuration,
          curve: Curves.easeInOut,
          builder: (context, progress, child) {
            // First half: the back turns away, second half: the face turns in
            final showFace = progress >= 0.5;
            final angle = showFace ? (1 - progress) * pi : progress * pi;
            final side = showFace ? _buildFace(theme) : _buildBack(theme);
            // Only cards that are turning need a transform layer
            if (angle == 0) return side;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.002)
                ..rotateY(angle),
              child: side,
            );
          },
        ),
      ),
    );
  }

  Widget _buildBack(PairsTheme theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colors.cardBack,
        borderRadius: BorderRadius.circular(theme.dimens.cardRadius),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.question_mark_rounded, size: size * 0.4, color: theme.colors.onCardBack),
    );
  }

  Widget _buildFace(PairsTheme theme) {
    final colors = theme.colors;
    final Color? borderColor;
    if (card.isMismatch) {
      borderColor = colors.cardMismatch;
    } else if (!card.isMatched) {
      borderColor = colors.cardFlipped;
    } else {
      borderColor = null;
    }
    // Found pairs fade towards the board with solid colors, an opacity layer per card is expensive
    Color fade(Color color) => card.isMatched ? Color.lerp(colors.board, color, theme.dimens.matchedOpacity)! : color;
    return Container(
      decoration: BoxDecoration(
        color: fade(colors.cardFace),
        borderRadius: BorderRadius.circular(theme.dimens.cardRadius),
        border: borderColor == null ? null : Border.all(color: borderColor, width: theme.dimens.cardBorderWidth),
      ),
      alignment: Alignment.center,
      child: Icon(
        faceIcons[card.value % faceIcons.length],
        size: size * 0.55,
        color: fade(colors.face(card.value)),
      ),
    );
  }
}
