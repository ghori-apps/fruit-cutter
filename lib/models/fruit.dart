import 'dart:math';
import 'package:flutter/material.dart';

enum FruitType {
  watermelon,
  pineapple,
  banana,
  apple,
  orange,
  strawberry,
  kiwi,
  dragonFruit,  // 2x score bonus
  freezeBanana, // Freeze time
  frenzyMelon,  // Frenzy fruit rain
  heartPeach,   // +1 Life
  bomb,         // Hazard
}

class SlicedHalf {
  Offset position;
  Offset velocity;
  double rotation;
  double rotationSpeed;
  final double cutAngle;
  final bool isLeftHalf;
  final Color innerColor;
  final Color outerColor;
  final double radius;
  double opacity;

  SlicedHalf({
    required this.position,
    required this.velocity,
    required this.rotation,
    required this.rotationSpeed,
    required this.cutAngle,
    required this.isLeftHalf,
    required this.innerColor,
    required this.outerColor,
    required this.radius,
    this.opacity = 1.0,
  });

  void update(double dt, {double gravity = 900}) {
    velocity += Offset(0, gravity * dt);
    position += velocity * dt;
    rotation += rotationSpeed * dt;
  }
}

class Fruit {
  final String id;
  final FruitType type;
  Offset position;
  Offset velocity;
  double radius;
  double rotation;
  double rotationSpeed;
  bool isSliced;
  bool isMissed;
  final int basePoints;
  final Color outerColor;
  final Color innerColor;
  final Color juiceColor;
  final String emoji;
  final String name;

  // Sliced half representations
  SlicedHalf? half1;
  SlicedHalf? half2;

  // Special animation timers
  double specialPulseTimer = 0.0;

  Fruit({
    required this.id,
    required this.type,
    required this.position,
    required this.velocity,
    required this.radius,
    required this.outerColor,
    required this.innerColor,
    required this.juiceColor,
    required this.emoji,
    required this.name,
    this.basePoints = 10,
    this.rotation = 0.0,
    this.rotationSpeed = 1.5,
    this.isSliced = false,
    this.isMissed = false,
  });

  bool get isSpecial =>
      type == FruitType.freezeBanana ||
      type == FruitType.frenzyMelon ||
      type == FruitType.dragonFruit ||
      type == FruitType.heartPeach;

  bool get isBomb => type == FruitType.bomb;

  void update(double dt, {double gravity = 800, double timeScale = 1.0}) {
    final effectiveDt = dt * timeScale;

    if (!isSliced) {
      velocity += Offset(0, gravity * effectiveDt);
      position += velocity * effectiveDt;
      rotation += rotationSpeed * effectiveDt;
      specialPulseTimer += effectiveDt;
    } else {
      half1?.update(effectiveDt, gravity: gravity);
      half2?.update(effectiveDt, gravity: gravity);
    }
  }

  void slice(double cutAngle) {
    if (isSliced) return;
    isSliced = true;

    if (isBomb) return; // Bombs detonate rather than split cleanly

    final rand = Random();
    final separationSpeed = 160.0 + rand.nextDouble() * 80.0;
    final perpAngle = cutAngle + pi / 2;

    final sepVector = Offset(
      cos(perpAngle) * separationSpeed,
      sin(perpAngle) * separationSpeed,
    );

    half1 = SlicedHalf(
      position: position,
      velocity: velocity - sepVector + Offset(-40, -60),
      rotation: rotation,
      rotationSpeed: -3.0 - rand.nextDouble() * 2.0,
      cutAngle: cutAngle,
      isLeftHalf: true,
      innerColor: innerColor,
      outerColor: outerColor,
      radius: radius,
    );

    half2 = SlicedHalf(
      position: position,
      velocity: velocity + sepVector + Offset(40, -60),
      rotation: rotation,
      rotationSpeed: 3.0 + rand.nextDouble() * 2.0,
      cutAngle: cutAngle,
      isLeftHalf: false,
      innerColor: innerColor,
      outerColor: outerColor,
      radius: radius,
    );
  }

  static Fruit create({
    required FruitType type,
    required Offset position,
    required Offset velocity,
    double radius = 42.0,
  }) {
    final rand = Random();
    final id = '${DateTime.now().microsecondsSinceEpoch}_${rand.nextInt(9999)}';
    final rotSpeed = (rand.nextDouble() - 0.5) * 4.0;

    switch (type) {
      case FruitType.watermelon:
        return Fruit(
          id: id,
          type: type,
          position: position,
          velocity: velocity,
          radius: radius * 1.15,
          outerColor: const Color(0xFF2E7D32),
          innerColor: const Color(0xFFFF2A4A),
          juiceColor: const Color(0xFFFF1744),
          emoji: '🍉',
          name: 'Watermelon',
          basePoints: 10,
          rotationSpeed: rotSpeed,
        );

      case FruitType.pineapple:
        return Fruit(
          id: id,
          type: type,
          position: position,
          velocity: velocity,
          radius: radius * 1.1,
          outerColor: const Color(0xFFE65100),
          innerColor: const Color(0xFFFFEA00),
          juiceColor: const Color(0xFFFFD600),
          emoji: '🍍',
          name: 'Pineapple',
          basePoints: 15,
          rotationSpeed: rotSpeed,
        );

      case FruitType.banana:
        return Fruit(
          id: id,
          type: type,
          position: position,
          velocity: velocity,
          radius: radius * 0.95,
          outerColor: const Color(0xFFFFD600),
          innerColor: const Color(0xFFFFF9C4),
          juiceColor: const Color(0xFFFFEE58),
          emoji: '🍌',
          name: 'Banana',
          basePoints: 10,
          rotationSpeed: rotSpeed,
        );

      case FruitType.apple:
        return Fruit(
          id: id,
          type: type,
          position: position,
          velocity: velocity,
          radius: radius,
          outerColor: const Color(0xFFD50000),
          innerColor: const Color(0xFFFFFDE7),
          juiceColor: const Color(0xFFFF5252),
          emoji: '🍎',
          name: 'Apple',
          basePoints: 10,
          rotationSpeed: rotSpeed,
        );

      case FruitType.orange:
        return Fruit(
          id: id,
          type: type,
          position: position,
          velocity: velocity,
          radius: radius,
          outerColor: const Color(0xFFFF6D00),
          innerColor: const Color(0xFFFFAB40),
          juiceColor: const Color(0xFFFF9100),
          emoji: '🍊',
          name: 'Orange',
          basePoints: 10,
          rotationSpeed: rotSpeed,
        );

      case FruitType.strawberry:
        return Fruit(
          id: id,
          type: type,
          position: position,
          velocity: velocity,
          radius: radius * 0.85,
          outerColor: const Color(0xFFC2185B),
          innerColor: const Color(0xFFFF4081),
          juiceColor: const Color(0xFFF50057),
          emoji: '🍓',
          name: 'Strawberry',
          basePoints: 15,
          rotationSpeed: rotSpeed,
        );

      case FruitType.kiwi:
        return Fruit(
          id: id,
          type: type,
          position: position,
          velocity: velocity,
          radius: radius * 0.85,
          outerColor: const Color(0xFF5D4037),
          innerColor: const Color(0xFF76FF03),
          juiceColor: const Color(0xFF64DD17),
          emoji: '🥝',
          name: 'Kiwi',
          basePoints: 20,
          rotationSpeed: rotSpeed,
        );

      case FruitType.dragonFruit:
        return Fruit(
          id: id,
          type: type,
          position: position,
          velocity: velocity,
          radius: radius * 1.1,
          outerColor: const Color(0xFFFF007F),
          innerColor: const Color(0xFFFFFFFF),
          juiceColor: const Color(0xFFFF4081),
          emoji: '💎',
          name: 'Dragon Fruit (2x)',
          basePoints: 50,
          rotationSpeed: rotSpeed * 1.5,
        );

      case FruitType.freezeBanana:
        return Fruit(
          id: id,
          type: type,
          position: position,
          velocity: velocity,
          radius: radius,
          outerColor: const Color(0xFF00E5FF),
          innerColor: const Color(0xFFE0F7FA),
          juiceColor: const Color(0xFF80D8FF),
          emoji: '❄️',
          name: 'Freeze Banana',
          basePoints: 25,
          rotationSpeed: rotSpeed,
        );

      case FruitType.frenzyMelon:
        return Fruit(
          id: id,
          type: type,
          position: position,
          velocity: velocity,
          radius: radius * 1.05,
          outerColor: const Color(0xFFFF0055),
          innerColor: const Color(0xFFFFD54F),
          juiceColor: const Color(0xFFFF1744),
          emoji: '⚡',
          name: 'Frenzy Melon',
          basePoints: 30,
          rotationSpeed: rotSpeed * 1.4,
        );

      case FruitType.heartPeach:
        return Fruit(
          id: id,
          type: type,
          position: position,
          velocity: velocity,
          radius: radius * 0.9,
          outerColor: const Color(0xFFFF4081),
          innerColor: const Color(0xFFFFCDD2),
          juiceColor: const Color(0xFFFF80AB),
          emoji: '💖',
          name: 'Heart Peach (+1 Life)',
          basePoints: 20,
          rotationSpeed: rotSpeed,
        );

      case FruitType.bomb:
        return Fruit(
          id: id,
          type: type,
          position: position,
          velocity: velocity,
          radius: radius * 0.95,
          outerColor: const Color(0xFF212121),
          innerColor: const Color(0xFFFF1744),
          juiceColor: const Color(0xFFFF5722),
          emoji: '💣',
          name: 'Bomb',
          basePoints: -50,
          rotationSpeed: rotSpeed * 0.8,
        );
    }
  }
}
