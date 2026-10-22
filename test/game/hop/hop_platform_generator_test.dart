import 'dart:math';

import 'package:flutter_mini_games/src/game/hop/game/logic/hop_game_controller.dart';
import 'package:flutter_mini_games/src/game/hop/game/model/hop_platform.dart';
import 'package:flutter_mini_games/src/game/hop/game/model/hop_platform_generator.dart';
import 'package:flutter_test/flutter_test.dart';

List<HopPlatform> _generate(int seed, double top) {
  final generator = HopPlatformGenerator(random: Random(seed), maxGap: HopGameController.maxPlatformGap, startY: 0.1);
  return [HopPlatform(x: 0.5, y: 0.1, width: 0.3), ...generator.generateUntil(top)];
}

void main() {
  group('HopPlatformGenerator', () {
    test('the max gap stays below the jump height', () {
      expect(HopGameController.maxPlatformGap, lessThan(HopGameController.maxJumpHeight));

      // At the max gap the character is still in the air long enough to cross half the world (wrap)
      const v = HopGameController.jumpVelocity;
      const g = HopGameController.gravity;
      const h = HopGameController.maxPlatformGap;
      final airTime = (v + sqrt(v * v - 2 * g * h)) / g;
      expect(airTime * HopGameController.moveSpeed, greaterThan(HopGameController.worldWidth / 2 + 0.1));
    });

    test('there is always a reachable, non-breakable platform above the previous one', () {
      for (var seed = 0; seed < 50; seed++) {
        final landable = _generate(seed, 150).where((p) => p.type != HopPlatformType.breakable).toList()..sort((a, b) => a.y.compareTo(b.y));
        for (var i = 1; i < landable.length; i++) {
          final gap = landable[i].y - landable[i - 1].y;
          expect(gap, lessThanOrEqualTo(HopGameController.maxPlatformGap + 1e-9), reason: 'seed $seed at ${landable[i].y}');
        }
        expect(landable.last.y, greaterThanOrEqualTo(150));
      }
    });

    test('platforms stay inside the world', () {
      for (final platform in _generate(1, 150)) {
        expect(platform.left, greaterThanOrEqualTo(0));
        expect(platform.right, lessThanOrEqualTo(HopGameController.worldWidth));
      }
    });

    test('gaps grow with the height', () {
      final generator = HopPlatformGenerator(random: Random(1), maxGap: HopGameController.maxPlatformGap, startY: 0);
      expect(generator.gapAt(0), lessThan(generator.gapAt(20)));
      expect(generator.gapAt(20), lessThan(generator.gapAt(HopPlatformGenerator.maxDifficultyHeight)));
      expect(generator.gapAt(1000), equals(HopGameController.maxPlatformGap));
    });

    test('moving and breakable platforms only appear as the game gets harder', () {
      final platforms = _generate(5, 150);
      final low = platforms.where((p) => p.y < 4);
      expect(low.every((p) => p.type == HopPlatformType.normal), isTrue);

      final high = platforms.where((p) => p.y > 20);
      expect(high.where((p) => p.type == HopPlatformType.moving), isNotEmpty);
      expect(high.where((p) => p.type == HopPlatformType.breakable), isNotEmpty);
      for (final moving in high.where((p) => p.type == HopPlatformType.moving)) {
        expect(moving.velocityX, isNot(equals(0)));
      }
    });

    test('is reproducible with the same seed', () {
      final a = _generate(9, 30).map((p) => (p.x, p.y, p.type));
      final b = _generate(9, 30).map((p) => (p.x, p.y, p.type));
      expect(a, equals(b));
    });
  });
}
