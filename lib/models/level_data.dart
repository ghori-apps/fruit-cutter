enum LevelDifficulty {
  easy,
  medium,
  hard,
  extraHard,
  nightmare,
}

class LevelObjective {
  final int targetScore;
  final int targetSlices;
  final int timeLimitSeconds;
  final double minAccuracyForStar3;
  final int maxMissesAllowed;

  const LevelObjective({
    required this.targetScore,
    required this.targetSlices,
    this.timeLimitSeconds = 45,
    this.minAccuracyForStar3 = 0.85,
    this.maxMissesAllowed = 3,
  });
}

class LevelData {
  final int levelNumber;
  final String title;
  final LevelDifficulty difficulty;
  final LevelObjective objective;
  final double bombProbability;
  final double fruitSpeedMultiplier;
  final int minSimultaneousSpawn;
  final int maxSimultaneousSpawn;
  final double spawnIntervalSeconds;
  final int star1Score;
  final int star2Score;
  final int star3Score;
  final int coinReward;

  const LevelData({
    required this.levelNumber,
    required this.title,
    required this.difficulty,
    required this.objective,
    required this.bombProbability,
    required this.fruitSpeedMultiplier,
    required this.minSimultaneousSpawn,
    required this.maxSimultaneousSpawn,
    required this.spawnIntervalSeconds,
    required this.star1Score,
    required this.star2Score,
    required this.star3Score,
    required this.coinReward,
  });

  String get difficultyLabel {
    switch (difficulty) {
      case LevelDifficulty.easy:
        return 'Easy';
      case LevelDifficulty.medium:
        return 'Medium';
      case LevelDifficulty.hard:
        return 'Hard';
      case LevelDifficulty.extraHard:
        return 'Extra Hard';
      case LevelDifficulty.nightmare:
        return 'Nightmare';
    }
  }

  int calculateStars({
    required int finalScore,
    required double accuracy,
    required bool bombTriggered,
  }) {
    if (finalScore < star1Score) return 0;

    int stars = 1;
    if (finalScore >= star2Score && accuracy >= 0.70) {
      stars = 2;
    }
    if (finalScore >= star3Score &&
        accuracy >= objective.minAccuracyForStar3 &&
        !bombTriggered) {
      stars = 3;
    }
    return stars;
  }
}
