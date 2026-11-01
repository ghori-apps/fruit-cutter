import 'dart:math';
import 'package:flutter/material.dart';

enum ParticleType {
  juice,
  bladeSpark,
  bombFire,
  bombSmoke,
  freezeCrystal,
  confetti,
}

class Particle {
  Offset position;
  Offset velocity;
  double size;
  Color color;
  double opacity;
  double life;
  final double maxLife;
  final ParticleType type;
  double rotation;
  double rotationSpeed;

  Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.color,
    required this.type,
    this.opacity = 1.0,
    this.life = 1.0,
    this.maxLife = 1.0,
    this.rotation = 0.0,
    this.rotationSpeed = 0.0,
  });

  bool update(double dt) {
    life -= dt / maxLife;
    if (life <= 0) return false;

    opacity = (life / maxLife).clamp(0.0, 1.0);
    position += velocity * dt;

    if (type == ParticleType.juice || type == ParticleType.confetti) {
      velocity += const Offset(0, 750) * dt; // Gravity
    } else if (type == ParticleType.bombSmoke) {
      velocity += const Offset(0, -60) * dt; // Smoke rises
      size += 15 * dt; // Smoke expands
    }

    rotation += rotationSpeed * dt;
    return true;
  }

  static List<Particle> createJuiceExplosion(
    Offset position,
    Color color, {
    int count = 18,
  }) {
    final rand = Random();
    final particles = <Particle>[];

    for (int i = 0; i < count; i++) {
      final angle = rand.nextDouble() * 2 * pi;
      final speed = 120.0 + rand.nextDouble() * 320.0;
      final vx = cos(angle) * speed;
      final vy = sin(angle) * speed;
      final life = 0.4 + rand.nextDouble() * 0.5;

      particles.add(
        Particle(
          position: position,
          velocity: Offset(vx, vy),
          size: 3.5 + rand.nextDouble() * 5.5,
          color: color,
          type: ParticleType.juice,
          maxLife: life,
          life: life,
        ),
      );
    }
    return particles;
  }

  static List<Particle> createBladeSparks(
    Offset position,
    Color sparkColor, {
    int count = 5,
  }) {
    final rand = Random();
    final particles = <Particle>[];

    for (int i = 0; i < count; i++) {
      final angle = rand.nextDouble() * 2 * pi;
      final speed = 40.0 + rand.nextDouble() * 120.0;
      final vx = cos(angle) * speed;
      final vy = sin(angle) * speed;
      final life = 0.2 + rand.nextDouble() * 0.25;

      particles.add(
        Particle(
          position: position,
          velocity: Offset(vx, vy),
          size: 2.0 + rand.nextDouble() * 3.5,
          color: sparkColor,
          type: ParticleType.bladeSpark,
          maxLife: life,
          life: life,
        ),
      );
    }
    return particles;
  }

  static List<Particle> createBombExplosion(Offset position) {
    final rand = Random();
    final particles = <Particle>[];

    // Fire particles
    for (int i = 0; i < 35; i++) {
      final angle = rand.nextDouble() * 2 * pi;
      final speed = 180.0 + rand.nextDouble() * 450.0;
      final colors = [
        const Color(0xFFFFCC00),
        const Color(0xFFFF6600),
        const Color(0xFFFF2200),
        Colors.white,
      ];
      final life = 0.4 + rand.nextDouble() * 0.6;

      particles.add(
        Particle(
          position: position,
          velocity: Offset(cos(angle) * speed, sin(angle) * speed),
          size: 6.0 + rand.nextDouble() * 10.0,
          color: colors[rand.nextInt(colors.length)],
          type: ParticleType.bombFire,
          maxLife: life,
          life: life,
        ),
      );
    }

    // Smoke particles
    for (int i = 0; i < 20; i++) {
      final angle = rand.nextDouble() * 2 * pi;
      final speed = 50.0 + rand.nextDouble() * 150.0;
      final life = 0.7 + rand.nextDouble() * 0.8;

      particles.add(
        Particle(
          position: position,
          velocity: Offset(cos(angle) * speed, sin(angle) * speed - 50),
          size: 15.0 + rand.nextDouble() * 20.0,
          color: const Color(0x99333333),
          type: ParticleType.bombSmoke,
          maxLife: life,
          life: life,
        ),
      );
    }
    return particles;
  }

  static List<Particle> createFreezeCrystals(Offset position) {
    final rand = Random();
    final particles = <Particle>[];

    for (int i = 0; i < 25; i++) {
      final angle = rand.nextDouble() * 2 * pi;
      final speed = 80.0 + rand.nextDouble() * 220.0;
      final life = 0.6 + rand.nextDouble() * 0.7;

      particles.add(
        Particle(
          position: position,
          velocity: Offset(cos(angle) * speed, sin(angle) * speed),
          size: 4.0 + rand.nextDouble() * 6.0,
          color: const Color(0xFFE0F7FA),
          type: ParticleType.freezeCrystal,
          maxLife: life,
          life: life,
          rotation: rand.nextDouble() * pi,
          rotationSpeed: (rand.nextDouble() - 0.5) * 6,
        ),
      );
    }
    return particles;
  }
}
