import 'dart:math';
import 'dart:ui' show lerpDouble;

import 'package:flutter_mini_games/src/game/hop/game/model/hop_platform.dart';

/// Generates platforms above the previous ones, harder as the height grows.
///
/// Every generated step contains one platform that is never breakable and is at most
/// [maxGap] above the previous one, so there is always a reachable way up.
/// Extra platforms (breakable ones as the game gets harder) are added in between.
class HopPlatformGenerator {
  /// Width of the world
  static const worldWidth = 1.0;

  /// Height at which the game reaches its maximum difficulty
  static const maxDifficultyHeight = 40.0;

  /// Smallest vertical gap between two platforms on the way up
  static const minGap = 0.16;

  final Random random;

  /// Highest vertical gap that is still allowed, must stay below the jump height
  final double maxGap;

  double _lastY;

  HopPlatformGenerator({
    required this.random,
    required this.maxGap,
    required double startY,
  }) : assert(maxGap > minGap),
       _lastY = startY;

  /// Top of the highest generated platform that is always reachable
  double get lastY => _lastY;

  /// 0 at the start, 1 from [maxDifficultyHeight] onwards
  static double difficultyAt(double y) => (y / maxDifficultyHeight).clamp(0.0, 1.0);

  /// Largest gap between reachable platforms at height [y]
  double gapAt(double y) => lerpDouble(minGap + 0.06, maxGap, difficultyAt(y))!;

  /// Width of the platforms at height [y]
  static double widthAt(double y) => lerpDouble(0.24, 0.16, difficultyAt(y))!;

  /// Generates platforms until the reachable path is above [top]
  List<HopPlatform> generateUntil(double top) {
    final platforms = <HopPlatform>[];
    while (_lastY < top) {
      platforms.addAll(_nextStep());
    }
    return platforms;
  }

  List<HopPlatform> _nextStep() {
    final difficulty = difficultyAt(_lastY);
    final maxStep = gapAt(_lastY);
    final gap = (maxStep * (0.7 + 0.3 * random.nextDouble())).clamp(minGap, maxGap);
    final y = _lastY + gap;
    final width = widthAt(y);
    final step = <HopPlatform>[];

    // The reachable platform: never breakable
    final isMoving = difficulty > 0.1 && random.nextDouble() < lerpDouble(0.1, 0.5, difficulty)!;
    step.add(
      HopPlatform(
        x: _randomX(width),
        y: y,
        width: width,
        type: isMoving ? HopPlatformType.moving : HopPlatformType.normal,
        velocityX: isMoving ? lerpDouble(0.15, 0.4, difficulty)! * (random.nextBool() ? 1 : -1) : 0,
      ),
    );

    // An extra platform in between
    if (gap > 0.24 && random.nextDouble() < lerpDouble(0.7, 0.4, difficulty)!) {
      final isBreakable = difficulty > 0.15 && random.nextDouble() < 0.6;
      step.add(
        HopPlatform(
          x: _randomX(width),
          y: _lastY + gap * (0.4 + 0.2 * random.nextDouble()),
          width: width,
          type: isBreakable ? HopPlatformType.breakable : HopPlatformType.normal,
        ),
      );
    }

    _lastY = y;
    return step;
  }

  double _randomX(double width) => width / 2 + random.nextDouble() * (worldWidth - width);
}
