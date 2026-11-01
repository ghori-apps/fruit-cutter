import 'dart:math';
import 'package:flutter/material.dart';

class JuiceSplatter {
  final Offset position;
  final Color color;
  final double radius;
  final double rotation;
  final List<Offset> drops;
  double opacity;
  double life;
  final double maxLife;

  JuiceSplatter({
    required this.position,
    required this.color,
    required this.radius,
    required this.rotation,
    required this.drops,
    this.opacity = 0.85,
    this.life = 6.0,
    this.maxLife = 6.0,
  });

  bool update(double dt) {
    life -= dt;
    if (life <= 0) return false;
    // Fade out gradually in the last 2 seconds
    if (life < 2.0) {
      opacity = (life / 2.0) * 0.85;
    }
    return true;
  }

  static JuiceSplatter create(Offset position, Color color) {
    final rand = Random();
    final dropCount = 4 + rand.nextInt(5);
    final drops = <Offset>[];

    for (int i = 0; i < dropCount; i++) {
      final angle = rand.nextDouble() * 2 * pi;
      final dist = 15.0 + rand.nextDouble() * 35.0;
      drops.add(Offset(cos(angle) * dist, sin(angle) * dist));
    }

    return JuiceSplatter(
      position: position,
      color: color,
      radius: 20.0 + rand.nextDouble() * 15.0,
      rotation: rand.nextDouble() * 2 * pi,
      drops: drops,
    );
  }
}
