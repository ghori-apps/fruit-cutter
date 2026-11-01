import 'dart:math';
import '../models/level_data.dart';

class LevelGenerator {
  static const List<String> _levelPrefixes = [
    'Apprentice',
    'Bamboo',
    'Citrus',
    'Crimson',
    'Dragon',
    'Emerald',
    'Frost',
    'Golden',
    'Inferno',
    'Jade',
    'Katana',
    'Lotus',
    'Mystic',
    'Ninja',
    'Obsidian',
    'Phantom',
    'Quantum',
    'Ronin',
    'Shadow',
    'Thunder',
    'Ultimate',
    'Vortex',
    'Wildfire',
    'Zenith',
  ];

  static const List<String> _levelSuffixes = [
    'Grove',
    'Blades',
    'Breeze',
    'Storm',
    'Fury',
    'Strike',
    'Cascade',
    'Dojo',
    'Trial',
    'Rush',
    'Sanctuary',
    'Ascent',
    'Labyrinth',
    'Domain',
    'Apex',
  ];

  static LevelData generate(int levelNumber) {
    final level = max(1, levelNumber);

    // 1. Difficulty Tier
    LevelDifficulty difficulty;
    if (level <= 5) {
      difficulty = LevelDifficulty.easy;
    } else if (level <= 15) {
      difficulty = LevelDifficulty.medium;
    } else if (level <= 30) {
      difficulty = LevelDifficulty.hard;
    } else if (level <= 50) {
      difficulty = LevelDifficulty.extraHard;
    } else {
      difficulty = LevelDifficulty.nightmare;
    }

    // 2. Title
    String title;
    if (level == 1) {
      title = 'Apprentice Dojo';
    } else if (level == 2) {
      title = 'Citrus Slice';
    } else if (level == 3) {
      title = 'Watermelon Rush';
    } else if (level == 5) {
      title = 'Bamboo Trial';
    } else if (level == 10) {
      title = 'Ninja Awakening';
    } else if (level == 20) {
      title = 'Dragon Fury';
    } else if (level == 50) {
      title = 'Grandmaster Apex';
    } else {
      final pIndex = (level * 7 + 3) % _levelPrefixes.length;
      final sIndex = (level * 13 + 5) % _levelSuffixes.length;
      title = '${_levelPrefixes[pIndex]} ${_levelSuffixes[sIndex]}';
    }

    // 3. Targets & Equations
    final targetSlices = 10 + (level * 3);
    final targetScore = 80 + (level * 45) + (pow(level, 1.12).toInt() * 8);
    final timeLimit = (35 + min(25, (level * 1.5))).toInt();

    // 4. Bomb Probability
    double bombProb;
    if (level <= 3) {
      bombProb = 0.0; // No bombs in intro levels
    } else if (level <= 15) {
      bombProb = 0.06 + (level - 3) * 0.015;
    } else if (level <= 35) {
      bombProb = 0.22 + (level - 15) * 0.008;
    } else {
      bombProb = min(0.42, 0.35 + (level - 35) * 0.003);
    }

    // 5. Fruit Speed & Spawn Counts
    final speedMultiplier = min(1.85, 1.0 + (log(level + 1) * 0.22));

    final minSpawn = level <= 4 ? 1 : level <= 20 ? 2 : 3;
    final maxSpawn = min(6, 2 + (level / 12).floor());

    final spawnInterval = max(1.1, 2.2 - (min(30, level) * 0.035));

    // 6. Star thresholds
    final star1 = targetScore;
    final star2 = (targetScore * 1.35).toInt();
    final star3 = (targetScore * 1.75).toInt();

    final coinReward = 20 + (level * 5);

    return LevelData(
      levelNumber: level,
      title: title,
      difficulty: difficulty,
      objective: LevelObjective(
        targetScore: targetScore,
        targetSlices: targetSlices,
        timeLimitSeconds: timeLimit,
        minAccuracyForStar3: level <= 5 ? 0.75 : 0.85,
        maxMissesAllowed: level <= 10 ? 4 : 3,
      ),
      bombProbability: bombProb,
      fruitSpeedMultiplier: speedMultiplier,
      minSimultaneousSpawn: minSpawn,
      maxSimultaneousSpawn: maxSpawn,
      spawnIntervalSeconds: spawnInterval,
      star1Score: star1,
      star2Score: star2,
      star3Score: star3,
      coinReward: coinReward,
    );
  }
}
