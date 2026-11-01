import 'package:flutter/material.dart';

class FloatingText {
  Offset position;
  final String text;
  final Color color;
  final double fontSize;
  final bool isBold;
  final bool hasGlow;
  double opacity;
  double life;
  final double maxLife;
  double scale;

  FloatingText({
    required this.position,
    required this.text,
    required this.color,
    this.fontSize = 22.0,
    this.isBold = true,
    this.hasGlow = false,
    this.opacity = 1.0,
    this.life = 0.8,
    this.maxLife = 0.8,
    this.scale = 1.0,
  });

  bool update(double dt) {
    life -= dt;
    if (life <= 0) return false;

    // Upward float
    position += Offset(0, -45 * dt);

    final progress = 1.0 - (life / maxLife);
    if (progress < 0.2) {
      // Pop scale up
      scale = 0.8 + (progress / 0.2) * 0.4;
    } else {
      scale = 1.2 - (progress - 0.2) * 0.25;
    }

    if (life < 0.3) {
      opacity = (life / 0.3).clamp(0.0, 1.0);
    }

    return true;
  }
}
