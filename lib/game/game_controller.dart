import '../ads/ad_service.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/blade.dart';
import '../models/dojo_theme.dart';
import '../models/floating_text.dart';
import '../models/fruit.dart';
import '../models/juice_splatter.dart';
import '../models/level_data.dart';
import '../models/particle.dart';
import '../services/audio_manager.dart';
import '../services/storage_service.dart';
import 'blade_trail_manager.dart';

enum GameMode {
  level,
  arcade,
  zen,
}

enum GameState {
  ready,
  playing,
  paused,
  levelComplete,
  gameOver,
}

class GameController extends ChangeNotifier {
  final GameMode mode;
  final LevelData? levelData;
  final StorageService storageService;
  final AudioManager audioManager;

  GameState state = GameState.ready;

  // Visual Theme
  late DojoTheme dojoTheme;
  late BladeSkin bladeSkin;

  // Screen Bounds
  Size screenSize = const Size(400, 800);

  // Entities
  final List<Fruit> fruits = [];
  final List<JuiceSplatter> splatters = [];
  final List<Particle> particles = [];
  final List<FloatingText> floatingTexts = [];
  final BladeTrailManager bladeTrail = BladeTrailManager();

  // Stats & Progress
  int score = 0;
  int slicesCount = 0;
  int missesCount = 0;
  int totalSpawned = 0;
  int lives = 5;
  int maxLives = 5;
  double timeRemaining = 60.0;
  bool bombTriggeredInLevel = false;

  // Power-Ups Timers
  double freezeTimer = 0.0;
  double frenzyTimer = 0.0;
  double doubleScoreTimer = 0.0;

  // Combos
  final List<Fruit> _currentComboFruits = [];
  Timer? _comboResetTimer;

  // Screen Shake
  Offset screenShakeOffset = Offset.zero;
  double _screenShakeIntensity = 0.0;

  // Spawning
  double _spawnTimer = 0.3;
  final Random _rand = Random();

  GameController({
    required this.mode,
    this.levelData,
    required this.storageService,
    required this.audioManager,
  }) {
    _initGame();
  }

  void _initGame() {
    state = GameState.ready;
    dojoTheme = DojoTheme.getById(storageService.selectedDojoId);
    bladeSkin = BladeSkin.getById(storageService.selectedBladeId);

    if (mode == GameMode.level && levelData != null) {
      timeRemaining = levelData!.objective.timeLimitSeconds.toDouble();
      lives = 8;
      maxLives = 8;
    } else if (mode == GameMode.arcade) {
      timeRemaining = 60.0;
      lives = 999;
      maxLives = 999;
    } else {
      // Zen mode
      timeRemaining = 999999.0;
      lives = 5;
      maxLives = 5;
    }
  }

  void setScreenSize(Size size) {
    if (size.width > 0 && size.height > 0) {
      screenSize = size;
    }
  }

  void startGame() {
    state = GameState.playing;
    _spawnTimer = 0.3; // Spawn first wave right after GO!
    audioManager.playGameBgm(mode: mode.index);
    notifyListeners();
  }

  void pauseGame() {
    if (state == GameState.playing) {
      state = GameState.paused;
      notifyListeners();
    }
  }

  void resumeGame() {
    if (state == GameState.paused) {
      state = GameState.playing;
      notifyListeners();
    }
  }

  // --- Touch Gestures ---
  void onPanStart(Offset position) {
    bladeTrail.startTouch(position);
    if (state == GameState.playing) {
      _checkSliceIntersections();
    }
    notifyListeners();
  }

  void onPanUpdate(Offset position) {
    bladeTrail.updateTouch(position);

    // Blade sparks at tip
    if (_rand.nextDouble() < 0.6) {
      particles.addAll(
        Particle.createBladeSparks(
          position,
          bladeSkin.sparkColor,
          count: 3,
        ),
      );
    }

    if (state == GameState.playing) {
      _checkSliceIntersections();
    }
    notifyListeners();
  }

  void onPanEnd() {
    bladeTrail.endTouch();
    notifyListeners();
  }

  // --- Game Loop Update ---
  void update(double dt) {
    // Unconditionally update blade trail, particles, splatters for smooth graphics
    bladeTrail.update();
    splatters.removeWhere((s) => !s.update(dt));
    particles.removeWhere((p) => !p.update(dt));
    floatingTexts.removeWhere((ft) => !ft.update(dt));

    if (state != GameState.playing) return;

    // Frame-accurate slicing check whenever finger/mouse is held down
    if (bladeTrail.isPointerDown) {
      _checkSliceIntersections();
    }

    // Power-up timers
    if (freezeTimer > 0) {
      freezeTimer -= dt;
      if (freezeTimer <= 0) freezeTimer = 0;
    }
    if (frenzyTimer > 0) {
      frenzyTimer -= dt;
      if (frenzyTimer <= 0) frenzyTimer = 0;
    }
    if (doubleScoreTimer > 0) {
      doubleScoreTimer -= dt;
      if (doubleScoreTimer <= 0) doubleScoreTimer = 0;
    }

    final timeScale = freezeTimer > 0 ? 0.35 : 1.0;
    final effectiveDt = dt * timeScale;

    // Timer countdown in Level & Arcade modes
    if (mode == GameMode.level || mode == GameMode.arcade) {
      timeRemaining -= dt;
      if (timeRemaining <= 0) {
        timeRemaining = 0;
        _handleTimeUp();
        return;
      }
    }

    // Screen shake update
    if (_screenShakeIntensity > 0) {
      _screenShakeIntensity -= dt * 15;
      if (_screenShakeIntensity <= 0) {
        _screenShakeIntensity = 0;
        screenShakeOffset = Offset.zero;
      } else {
        screenShakeOffset = Offset(
          (_rand.nextDouble() - 0.5) * _screenShakeIntensity * 12,
          (_rand.nextDouble() - 0.5) * _screenShakeIntensity * 12,
        );
      }
    }

    // Blade trail update
    bladeTrail.update();

    // Spawner
    _updateSpawner(effectiveDt);

    // Fruits update & continuous intersection check
    for (int i = fruits.length - 1; i >= 0; i--) {
      final fruit = fruits[i];
      fruit.update(effectiveDt);

      // Soft bounce on left/right screen bounds so fruits never vanish sideways
      if (!fruit.isSliced && screenSize.width > 0) {
        final minX = fruit.radius + 15.0;
        final maxX = screenSize.width - fruit.radius - 15.0;
        if (fruit.position.dx < minX && fruit.velocity.dx < 0) {
          fruit.position = Offset(minX, fruit.position.dy);
          fruit.velocity = Offset(-fruit.velocity.dx * 0.5, fruit.velocity.dy);
        } else if (fruit.position.dx > maxX && fruit.velocity.dx > 0) {
          fruit.position = Offset(maxX, fruit.position.dy);
          fruit.velocity = Offset(-fruit.velocity.dx * 0.5, fruit.velocity.dy);
        }
      }

      // Check if dropped below screen
      if (fruit.position.dy > screenSize.height + 150) {
        if (!fruit.isSliced && !fruit.isBomb && !fruit.isMissed) {
          fruit.isMissed = true;
          _handleMissedFruit(fruit);
        }
        fruits.removeAt(i);
      }
    }

    // Continuous slice check on every frame
    _checkSliceIntersections();

    // Splatters update
    splatters.removeWhere((s) => !s.update(dt));

    // Particles update
    particles.removeWhere((p) => !p.update(dt));

    // Floating texts update
    floatingTexts.removeWhere((ft) => !ft.update(dt));

    // Check level completion target
    if (mode == GameMode.level && levelData != null) {
      if (slicesCount >= levelData!.objective.targetSlices &&
          score >= levelData!.objective.targetScore) {
        _handleLevelSuccess();
      }
    }

    notifyListeners();
  }

  void _updateSpawner(double dt) {
    _spawnTimer -= dt;
    if (_spawnTimer <= 0) {
      final interval = frenzyTimer > 0
          ? 0.35
          : (levelData?.spawnIntervalSeconds ?? 1.8);
      _spawnTimer = interval;

      final count = frenzyTimer > 0
          ? (3 + _rand.nextInt(3))
          : _getSpawnCount();
      _spawnWave(count);
    }
  }

  int _getSpawnCount() {
    if (levelData != null) {
      final minS = levelData!.minSimultaneousSpawn;
      final maxS = levelData!.maxSimultaneousSpawn;
      return minS + _rand.nextInt(max(1, maxS - minS + 1));
    }
    return 1 + _rand.nextInt(3);
  }

  void _spawnWave(int count) {
    if (screenSize.width <= 0 || screenSize.height <= 0) return;

    final gravity = 800.0;
    final spawnY = screenSize.height + 30.0;

    for (int i = 0; i < count; i++) {
      final spawnX = 60.0 + _rand.nextDouble() * max(20.0, screenSize.width - 120.0);

      // Target peak Y safely inside top screen region (e.g. 15% to 35% from top)
      final targetPeakY = max(80.0, screenSize.height * 0.15) +
          _rand.nextDouble() * max(40.0, screenSize.height * 0.20);
      final deltaY = spawnY - targetPeakY;

      // Exact upward launch velocity: vy = -sqrt(2 * g * deltaY)
      final vy = -sqrt(2 * gravity * deltaY);

      // Target peak X safely inside middle screen region (25% to 75% of screen width)
      final targetX = screenSize.width * 0.25 + _rand.nextDouble() * (screenSize.width * 0.50);

      // Time to reach peak height: t_peak = |vy| / g
      final timeToPeak = vy.abs() / gravity;

      // Horizontal velocity vx to reach targetX at peak:
      final vx = timeToPeak > 0 ? (targetX - spawnX) / timeToPeak : 0.0;

      final fruitType = _pickFruitType();

      final fruit = Fruit.create(
        type: fruitType,
        position: Offset(spawnX, spawnY),
        velocity: Offset(vx, vy),
      );

      fruits.add(fruit);
      if (!fruit.isBomb) {
        totalSpawned++;
      }
    }

    audioManager.playSwoosh();
  }

  FruitType _pickFruitType() {
    final bombProb = frenzyTimer > 0
        ? 0.0
        : (levelData?.bombProbability ?? (mode == GameMode.arcade ? 0.22 : 0.12));

    if (_rand.nextDouble() < bombProb) {
      return FruitType.bomb;
    }

    // Special bonus fruits probability
    final specialRoll = _rand.nextDouble();
    if (specialRoll < 0.06) return FruitType.freezeBanana;
    if (specialRoll < 0.10) return FruitType.frenzyMelon;
    if (specialRoll < 0.14) return FruitType.dragonFruit;
    if (specialRoll < 0.18 && lives < maxLives) return FruitType.heartPeach;

    // Standard juicy fruits
    final standardFruits = [
      FruitType.watermelon,
      FruitType.pineapple,
      FruitType.banana,
      FruitType.apple,
      FruitType.orange,
      FruitType.strawberry,
      FruitType.kiwi,
    ];
    return standardFruits[_rand.nextInt(standardFruits.length)];
  }

  // --- Slicing Physics & Detection ---
  void _checkSliceIntersections() {
    if (fruits.isEmpty) return;

    for (final fruit in fruits) {
      if (fruit.isSliced) continue;

      if (bladeTrail.checkIntersection(fruit.position, fruit.radius)) {
        final cutAngle = bladeTrail.getLatestSwipeAngle();
        _sliceFruit(fruit, cutAngle);
      }
    }
  }

  void _sliceFruit(Fruit fruit, double cutAngle) {
    fruit.slice(cutAngle);

    if (fruit.isBomb) {
      _handleBombSliced(fruit);
      return;
    }

    slicesCount++;
    audioManager.playSlice();

    // Splatters on background wall
    if (_rand.nextDouble() < 0.85) {
      splatters.add(JuiceSplatter.create(fruit.position, fruit.juiceColor));
      audioManager.playSplat();
    }

    // Juice explosion particles
    particles.addAll(
      Particle.createJuiceExplosion(fruit.position, fruit.juiceColor, count: 18),
    );

    // Calculate score
    int pointsEarned = fruit.basePoints;
    if (doubleScoreTimer > 0 || fruit.type == FruitType.dragonFruit) {
      pointsEarned *= 2;
    }

    score += pointsEarned;

    // Special power-up effects
    _handleSpecialFruitEffects(fruit);

    // Floating text alert
    floatingTexts.add(
      FloatingText(
        position: fruit.position,
        text: '+$pointsEarned',
        color: fruit.juiceColor,
      ),
    );

    // Combo system tracking
    _trackCombo(fruit);
  }

  void _handleSpecialFruitEffects(Fruit fruit) {
    if (fruit.type == FruitType.freezeBanana) {
      freezeTimer = 4.5;
      audioManager.playFreeze();
      particles.addAll(Particle.createFreezeCrystals(fruit.position));
      floatingTexts.add(
        FloatingText(
          position: fruit.position - const Offset(0, 30),
          text: '❄️ FREEZE!',
          color: const Color(0xFF00E5FF),
          fontSize: 28,
          hasGlow: true,
        ),
      );
    } else if (fruit.type == FruitType.frenzyMelon) {
      frenzyTimer = 4.5;
      audioManager.playFrenzy();
      floatingTexts.add(
        FloatingText(
          position: fruit.position - const Offset(0, 30),
          text: '⚡ FRENZY STORM!',
          color: const Color(0xFFFFD600),
          fontSize: 28,
          hasGlow: true,
        ),
      );
    } else if (fruit.type == FruitType.dragonFruit) {
      doubleScoreTimer = 6.0;
      audioManager.playDoublePoints();
      floatingTexts.add(
        FloatingText(
          position: fruit.position - const Offset(0, 30),
          text: '💎 2X DOUBLE SCORE!',
          color: const Color(0xFFFF007F),
          fontSize: 28,
          hasGlow: true,
        ),
      );
    } else if (fruit.type == FruitType.heartPeach) {
      if (lives < maxLives) {
        lives++;
        audioManager.playExtraLife();
        floatingTexts.add(
          FloatingText(
            position: fruit.position - const Offset(0, 30),
            text: '💖 +1 LIFE!',
            color: const Color(0xFFFF4081),
            fontSize: 28,
            hasGlow: true,
          ),
        );
      }
    }
  }

  void _handleBombSliced(Fruit bomb) {
    bombTriggeredInLevel = true;
    _screenShakeIntensity = 1.0;
    audioManager.playBombExplosion();
    particles.addAll(Particle.createBombExplosion(bomb.position));

    if (mode == GameMode.arcade) {
      // Deduct 50 pts & 10 sec in Arcade
      score = max(0, score - 50);
      timeRemaining = max(0.0, timeRemaining - 10.0);
      floatingTexts.add(
        FloatingText(
          position: bomb.position,
          text: '💥 -50 PTS & -10s!',
          color: const Color(0xFFFF1744),
          fontSize: 28,
          hasGlow: true,
        ),
      );
    } else {
      // Deduct 1 life in Level/Zen
      lives--;
      floatingTexts.add(
        FloatingText(
          position: bomb.position,
          text: '💥 BOMB HIT! -1 LIFE',
          color: const Color(0xFFFF1744),
          fontSize: 28,
          hasGlow: true,
        ),
      );

      if (lives <= 0) {
        _handleGameOver();
      }
    }
  }

  void _handleMissedFruit(Fruit fruit) {
    missesCount++;

    if (mode == GameMode.zen) {
      lives--;
      if (lives <= 0) {
        _handleGameOver();
      }
    } else if (mode == GameMode.level) {
      lives--;
      if (lives <= 0) {
        _handleGameOver();
      }
    }
  }

  void _trackCombo(Fruit fruit) {
    _currentComboFruits.add(fruit);
    _comboResetTimer?.cancel();

    _comboResetTimer = Timer(const Duration(milliseconds: 320), () {
      if (_currentComboFruits.length >= 3) {
        _triggerComboReward(_currentComboFruits.length);
      }
      _currentComboFruits.clear();
    });
  }

  void _triggerComboReward(int count) {
    final bonus = count == 3
        ? 30
        : count == 4
            ? 50
            : 100;
    score += bonus;
    audioManager.playCombo();

    final label = count >= 5 ? '🔥 MEGA COMBO x$count!' : '⚡ COMBO x$count!';

    floatingTexts.add(
      FloatingText(
        position: Offset(screenSize.width / 2, screenSize.height * 0.4),
        text: '$label +$bonus',
        color: const Color(0xFFFFD700),
        fontSize: 32,
        hasGlow: true,
      ),
    );
  }

  void _handleTimeUp() {
    if (mode == GameMode.level && levelData != null) {
      if (slicesCount >= levelData!.objective.targetSlices &&
          score >= levelData!.objective.targetScore) {
        _handleLevelSuccess();
      } else {
        _handleGameOver();
      }
    } else {
      _handleGameOver();
    }
  }

  void _handleLevelSuccess() {
    if (state == GameState.levelComplete) return;
    state = GameState.levelComplete;

    final accuracy = totalSpawned > 0 ? (slicesCount / totalSpawned) : 1.0;
    final stars = levelData!.calculateStars(
      finalScore: score,
      accuracy: accuracy,
      bombTriggered: bombTriggeredInLevel,
    );

    // Save stars & progression
    storageService.saveLevelStars(levelData!.levelNumber, stars);
    storageService.setUnlockedLevel(levelData!.levelNumber + 1);
    storageService.addCoins(levelData!.coinReward);

    audioManager.playLevelWin();
    notifyListeners();
  }

  void _handleGameOver() {
    if (state == GameState.gameOver) return;
    state = GameState.gameOver;
    AdService.showInterstitialAd();

    if (mode == GameMode.arcade) {
      storageService.saveArcadeHighScore(score);
    } else if (mode == GameMode.zen) {
      storageService.saveZenHighScore(score);
    }

    notifyListeners();
  }

  double get accuracy {
    final attempts = slicesCount + missesCount;
    return attempts > 0 ? (slicesCount / attempts) : 1.0;
  }

  @override
  void dispose() {
    _comboResetTimer?.cancel();
    super.dispose();
  }
}

