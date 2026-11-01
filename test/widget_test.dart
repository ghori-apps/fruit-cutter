import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_cutter_flutter/game/blade_trail_manager.dart';
import 'package:fruit_cutter_flutter/models/blade.dart';
import 'package:fruit_cutter_flutter/models/dojo_theme.dart';
import 'package:fruit_cutter_flutter/models/fruit.dart';
import 'package:fruit_cutter_flutter/services/level_generator.dart';

void main() {
  test('LevelGenerator generates progressive infinite levels', () {
    final level1 = LevelGenerator.generate(1);
    final level10 = LevelGenerator.generate(10);
    final level50 = LevelGenerator.generate(50);

    expect(level1.levelNumber, 1);
    expect(level1.difficultyLabel, 'Easy');
    expect(level1.bombProbability, 0.0);

    expect(level10.levelNumber, 10);
    expect(level10.difficultyLabel, 'Medium');
    expect(level10.objective.targetScore, greaterThan(level1.objective.targetScore));

    expect(level50.levelNumber, 50);
    expect(level50.difficultyLabel, 'Extra Hard');
    expect(level50.bombProbability, greaterThan(0.3));
  });

  test('Blade and Dojo collections are initialized properly', () {
    expect(BladeSkin.allBlades.length, greaterThanOrEqualTo(6));
    expect(DojoTheme.allThemes.length, greaterThanOrEqualTo(5));

    final classic = BladeSkin.getById('blade_classic');
    expect(classic.isDefaultUnlocked, true);

    final dojo = DojoTheme.getById('dojo_classic');
    expect(dojo.isDefaultUnlocked, true);
  });

  test('Fruit slice split mechanics create two halves', () {
    final fruit = Fruit.create(
      type: FruitType.watermelon,
      position: const Offset(100, 100),
      velocity: const Offset(0, -200),
    );

    expect(fruit.isSliced, false);
    fruit.slice(0.5);
    expect(fruit.isSliced, true);
    expect(fruit.half1, isNotNull);
    expect(fruit.half2, isNotNull);
  });

  test('BladeTrailManager accurately detects slice collisions', () {
    final trail = BladeTrailManager();
    trail.addPoint(const Offset(50, 100));
    trail.addPoint(const Offset(150, 100));

    // Fruit at (100, 100) right in path of horizontal cut
    final hit = trail.checkIntersection(const Offset(100, 100), 40.0);
    expect(hit, true);

    // Fruit at (300, 300) far away from cut
    final miss = trail.checkIntersection(const Offset(300, 300), 40.0);
    expect(miss, false);
  });
}
