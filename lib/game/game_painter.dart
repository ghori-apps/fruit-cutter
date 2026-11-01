import 'dart:math';
import 'package:flutter/material.dart';
import '../models/blade.dart';
import '../models/dojo_theme.dart';
import '../models/floating_text.dart';
import '../models/fruit.dart';
import '../models/juice_splatter.dart';
import '../models/particle.dart';

class GamePainter extends CustomPainter {
  final DojoTheme dojoTheme;
  final BladeSkin bladeSkin;
  final List<JuiceSplatter> splatters;
  final List<Fruit> fruits;
  final List<BladePoint> bladePoints;
  final List<Particle> particles;
  final List<FloatingText> floatingTexts;
  final bool isFreezeActive;
  final bool isFrenzyActive;
  final Offset screenShakeOffset;

  GamePainter({
    required this.dojoTheme,
    required this.bladeSkin,
    required this.splatters,
    required this.fruits,
    required this.bladePoints,
    required this.particles,
    required this.floatingTexts,
    required this.isFreezeActive,
    required this.isFrenzyActive,
    required this.screenShakeOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    try {
      canvas.save();
      canvas.translate(screenShakeOffset.dx, screenShakeOffset.dy);

      // 1. Draw Dojo Background
      _drawBackground(canvas, size);

      // 2. Draw Juice Splatters on Wall
      _drawSplatters(canvas);

      // 3. Draw Fruits & Sliced Halves
      _drawFruits(canvas);

      // 4. Draw Particles (Juice drops, sparks, smoke, ice)
      _drawParticles(canvas);

      // 5. Draw Blade Trail with Neon Glow
      _drawBladeTrail(canvas);

      // 6. Draw Special Overlay (Freeze frost border / Frenzy aura)
      if (isFreezeActive) {
        _drawFreezeOverlay(canvas, size);
      }
      if (isFrenzyActive) {
        _drawFrenzyBorder(canvas, size);
      }

      // 7. Draw Floating Score & Combo Texts
      _drawFloatingTexts(canvas);

      canvas.restore();
    } catch (e) {
      // print('GAME_PAINTER_ERROR: $e\n$stack');
    }
  }

  double _safeOpacity(double v) => v.isNaN || v.isInfinite ? 0.0 : v.clamp(0.0, 1.0);

  void _drawBackground(Canvas canvas, Size size) {
    final w = (size.width.isFinite && size.width > 0) ? size.width : 400.0;
    final h = (size.height.isFinite && size.height > 0) ? size.height : 800.0;
    final rect = Rect.fromLTWH(0, 0, w, h);

    // 1. Rich Base Gradient
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: dojoTheme.backgroundGradient,
    );
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // 2. Theme-Specific Visual Details
    if (dojoTheme.type == DojoThemeType.classicWood) {
      // Draw Vertical Wooden Wall Planks
      final plankWidth = w / 6.0;
      for (int i = 0; i < 6; i++) {
        final x = i * plankWidth;
        final plankRect = Rect.fromLTWH(x, 0, plankWidth, h);

        // Subtle plank tone variation
        final plankShade = (i % 2 == 0) ? Colors.black.withValues(alpha: 0.04) : Colors.white.withValues(alpha: 0.03);
        canvas.drawRect(plankRect, Paint()..color = plankShade);

        // Vertical plank seam/shadow line
        if (i > 0) {
          final seamPaint = Paint()
            ..color = Colors.black.withValues(alpha: 0.35)
            ..strokeWidth = 2.0;
          canvas.drawLine(Offset(x, 0), Offset(x, h), seamPaint);

          // Highlight on right edge of seam
          final highlightPaint = Paint()
            ..color = const Color(0xFFFFE0B2).withValues(alpha: 0.12)
            ..strokeWidth = 1.0;
          canvas.drawLine(Offset(x + 1, 0), Offset(x + 1, h), highlightPaint);
        }
      }

      // Horizontal Wood Slats
      final slatCount = 10;
      final slatHeight = h / slatCount;
      for (int i = 1; i < slatCount; i++) {
        final y = i * slatHeight;
        canvas.drawLine(
          Offset(0, y),
          Offset(w, y),
          Paint()
            ..color = Colors.black.withValues(alpha: 0.25)
            ..strokeWidth = 2.0,
        );
        canvas.drawLine(
          Offset(0, y - 1),
          Offset(w, y - 1),
          Paint()
            ..color = const Color(0xFFFFD59E).withValues(alpha: 0.12)
            ..strokeWidth = 1.0,
        );
      }

      // 3. Bright Warm Center Spotlight (Ensures screen center is bright & clear!)
      final spotlight = RadialGradient(
        center: Alignment.center,
        radius: 0.85,
        colors: [
          const Color(0xFFFFE082).withValues(alpha: 0.22),
          const Color(0xFFFFB300).withValues(alpha: 0.08),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      );
      canvas.drawRect(rect, Paint()..shader = spotlight.createShader(rect));
    } else if (dojoTheme.type == DojoThemeType.cyberpunk) {
      final gridPaint = Paint()
        ..color = const Color(0xFF00E5FF).withValues(alpha: 0.15)
        ..strokeWidth = 1.2;
      for (double x = 0; x < w; x += 40) {
        canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
      }
      for (double y = 0; y < h; y += 40) {
        canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
      }
    } else if (dojoTheme.type == DojoThemeType.zenBamboo) {
      // Emerald Bamboo Stalks
      final bambooCount = 8;
      final spacing = w / bambooCount;
      for (int i = 0; i < bambooCount; i++) {
        final bx = i * spacing + spacing * 0.5;
        final stalkPaint = Paint()
          ..color = const Color(0xFF10B981).withValues(alpha: 0.12)
          ..strokeWidth = 8.0;
        canvas.drawLine(Offset(bx, 0), Offset(bx, h), stalkPaint);
      }
    } else if (dojoTheme.type == DojoThemeType.sunsetPagoda) {
      // Golden Horizon Glow
      final sunGlow = RadialGradient(
        center: const Alignment(0.0, 0.2),
        radius: 0.7,
        colors: [
          const Color(0xFFFF7A00).withValues(alpha: 0.30),
          Colors.transparent,
        ],
      );
      canvas.drawRect(rect, Paint()..shader = sunGlow.createShader(rect));
    } else if (dojoTheme.type == DojoThemeType.magmaForge) {
      // Lava Glow
      final magmaGlow = RadialGradient(
        center: const Alignment(0.0, 0.8),
        radius: 0.8,
        colors: [
          const Color(0xFFFF3D00).withValues(alpha: 0.35),
          Colors.transparent,
        ],
      );
      canvas.drawRect(rect, Paint()..shader = magmaGlow.createShader(rect));
    }
  }

  void _drawSplatters(Canvas canvas) {
    for (final splatter in splatters) {
      final opacity = (splatter.opacity * 0.55).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = splatter.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      // Central splat circle
      canvas.drawCircle(splatter.position, splatter.radius, paint);

      // Droplets around
      for (final drop in splatter.drops) {
        canvas.drawCircle(
          splatter.position + drop,
          splatter.radius * 0.28,
          paint,
        );
      }
    }
  }

  void _drawFruits(Canvas canvas) {
    for (final fruit in fruits) {
      if (!fruit.isSliced) {
        _drawWholeFruit(canvas, fruit);
      } else {
        if (fruit.half1 != null) _drawSlicedHalf(canvas, fruit.half1!);
        if (fruit.half2 != null) _drawSlicedHalf(canvas, fruit.half2!);
      }
    }
  }

  void _drawWholeFruit(Canvas canvas, Fruit fruit) {
    canvas.save();
    canvas.translate(fruit.position.dx, fruit.position.dy);
    canvas.rotate(fruit.rotation);

    final r = fruit.radius;

    if (fruit.isBomb) {
      // Draw Bomb
      final bombPaint = Paint()..color = const Color(0xFF1E1E24);
      canvas.drawCircle(Offset.zero, r, bombPaint);

      // Bomb highlight
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(-r * 0.3, -r * 0.3), r * 0.25, highlightPaint);

      // Bomb Cap
      final capPaint = Paint()..color = const Color(0xFF757575);
      canvas.drawRect(Rect.fromLTWH(-r * 0.25, -r - 6, r * 0.5, 8), capPaint);

      // Burning Fuse
      final fusePaint = Paint()
        ..color = const Color(0xFFD7CCC8)
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke;
      final fusePath = Path()
        ..moveTo(0, -r - 6)
        ..quadraticBezierTo(12, -r - 16, 8, -r - 24);
      canvas.drawPath(fusePath, fusePaint);

      // Fuse Spark
      final sparkPaint = Paint()..color = const Color(0xFFFFD600);
      canvas.drawCircle(Offset(8, -r - 24), 5.0, sparkPaint);
      final sparkGlow = Paint()
        ..color = const Color(0xFFFF3D00).withValues(alpha: 0.7)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset(8, -r - 24), 9.0, sparkGlow);
    } else {
      // Special Fruit Aura Glow
      if (fruit.isSpecial) {
        final pulse = (sin(fruit.specialPulseTimer * 6) * 0.15 + 0.85).clamp(0.1, 1.0);
        final auraColor = fruit.type == FruitType.freezeBanana
            ? const Color(0xFF00E5FF)
            : fruit.type == FruitType.dragonFruit
                ? const Color(0xFFFF007F)
                : const Color(0xFFFFD700);

        final glowPaint = Paint()
          ..color = auraColor.withValues(alpha: (0.45 * pulse).clamp(0.0, 1.0))
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, max(1.0, 14 * pulse));
        canvas.drawCircle(Offset.zero, r * 1.35 * pulse, glowPaint);
      }

      // Outer Fruit Peel
      final peelPaint = Paint()
        ..color = fruit.outerColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset.zero, r, peelPaint);

      // Inner Pulp layer
      final pulpPaint = Paint()
        ..color = fruit.innerColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset.zero, r * 0.82, pulpPaint);

      // Subtle 3D Highlight & Shadow
      final lightPaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.35),
          radius: 0.7,
          colors: [
            Colors.white.withValues(alpha: 0.4),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: r));
      canvas.drawCircle(Offset.zero, r, lightPaint);

      // Central Fruit Symbol / Character
      _drawCenteredText(
        canvas,
        fruit.emoji,
        Offset.zero,
        fontSize: r * 0.95,
      );
    }

    canvas.restore();
  }

  void _drawSlicedHalf(Canvas canvas, SlicedHalf half) {
    canvas.save();
    canvas.translate(half.position.dx, half.position.dy);
    canvas.rotate(half.rotation);

    final r = half.radius;
    final path = Path();
    final halfOpacity = half.opacity.clamp(0.0, 1.0);

    // Semicircle geometry along cut angle
    if (half.isLeftHalf) {
      path.addArc(
        Rect.fromCircle(center: Offset.zero, radius: r),
        half.cutAngle + pi / 2,
        pi,
      );
    } else {
      path.addArc(
        Rect.fromCircle(center: Offset.zero, radius: r),
        half.cutAngle - pi / 2,
        pi,
      );
    }
    path.close();

    // Outer skin
    final peelPaint = Paint()
      ..color = half.outerColor.withValues(alpha: halfOpacity)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, peelPaint);

    // Inner exposed flesh
    final innerPath = Path();
    if (half.isLeftHalf) {
      innerPath.addArc(
        Rect.fromCircle(center: Offset.zero, radius: r * 0.82),
        half.cutAngle + pi / 2,
        pi,
      );
    } else {
      innerPath.addArc(
        Rect.fromCircle(center: Offset.zero, radius: r * 0.82),
        half.cutAngle - pi / 2,
        pi,
      );
    }
    innerPath.close();

    final innerPaint = Paint()
      ..color = half.innerColor.withValues(alpha: halfOpacity)
      ..style = PaintingStyle.fill;
    canvas.drawPath(innerPath, innerPaint);

    // Cut face shine line
    final cutLinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5 * halfOpacity)
      ..strokeWidth = 2.0;
    final p1 = Offset(cos(half.cutAngle) * r, sin(half.cutAngle) * r);
    final p2 = Offset(-cos(half.cutAngle) * r, -sin(half.cutAngle) * r);
    canvas.drawLine(p1, p2, cutLinePaint);

    canvas.restore();
  }

  void _drawBladeTrail(Canvas canvas) {
    if (bladePoints.isEmpty) return;

    final now = DateTime.now();
    final tipPoint = bladePoints.last.position;

    // 1. Draw connecting trail segments
    if (bladePoints.length >= 2) {
      for (int i = 0; i < bladePoints.length - 1; i++) {
        final p1 = bladePoints[i];
        final p2 = bladePoints[i + 1];

        final indexRatio = (i + 1) / bladePoints.length;
        final timeDiff = now.difference(p2.time).inMilliseconds;
        final timeRatio = (1.0 - (timeDiff / 260.0)).clamp(0.05, 1.0);
        final alphaRatio = (indexRatio * 0.65 + timeRatio * 0.35).clamp(0.1, 1.0);

        final width = bladeSkin.baseWidth * alphaRatio;

        // A. Atmospheric Outer Glow
        final glowPaint = Paint()
          ..color = bladeSkin.glowColor.withValues(alpha: _safeOpacity(0.65 * alphaRatio))
          ..strokeWidth = width * 2.6
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
        canvas.drawLine(p1.position, p2.position, glowPaint);

        // B. Mid Vibrant Trail
        final midPaint = Paint()
          ..color = bladeSkin.trailColor.withValues(alpha: _safeOpacity(0.95 * alphaRatio))
          ..strokeWidth = width * 1.3
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(p1.position, p2.position, midPaint);

        // C. Razor Sharp Bright Core
        final corePaint = Paint()
          ..color = bladeSkin.coreColor.withValues(alpha: _safeOpacity(1.0 * alphaRatio))
          ..strokeWidth = max(3.5, width * 0.45)
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(p1.position, p2.position, corePaint);
      }
    }

    // 2. Draw Razor-Sharp Glowing Blade Tip / Cutter Head at finger position
    //    This renders even with a SINGLE touch point (length == 1)
    final headGlowPaint = Paint()
      ..color = bladeSkin.glowColor.withValues(alpha: 0.85)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawCircle(tipPoint, bladeSkin.baseWidth * 1.1, headGlowPaint);

    final headMidPaint = Paint()..color = bladeSkin.trailColor;
    canvas.drawCircle(tipPoint, bladeSkin.baseWidth * 0.6, headMidPaint);

    final headCorePaint = Paint()..color = bladeSkin.coreColor;
    canvas.drawCircle(tipPoint, bladeSkin.baseWidth * 0.32, headCorePaint);

    // 4-Point Star Diamond Flare at Blade Tip
    final flarePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.95)
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;
    final flareLen = bladeSkin.baseWidth * 1.0;
    canvas.drawLine(tipPoint - Offset(flareLen, 0), tipPoint + Offset(flareLen, 0), flarePaint);
    canvas.drawLine(tipPoint - Offset(0, flareLen), tipPoint + Offset(0, flareLen), flarePaint);

    // Diagonal micro-flares for extra sharpness
    final diagLen = flareLen * 0.55;
    final diagPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(tipPoint - Offset(diagLen, diagLen), tipPoint + Offset(diagLen, diagLen), diagPaint);
    canvas.drawLine(tipPoint - Offset(-diagLen, diagLen), tipPoint + Offset(-diagLen, diagLen), diagPaint);
  }

  void _drawParticles(Canvas canvas) {
    for (final p in particles) {
      final pOpacity = p.opacity.clamp(0.0, 1.0);
      final paint = Paint()
        ..color = p.color.withValues(alpha: pOpacity)
        ..style = PaintingStyle.fill;

      if (p.type == ParticleType.freezeCrystal) {
        canvas.save();
        canvas.translate(p.position.dx, p.position.dy);
        canvas.rotate(p.rotation);
        // Diamond crystal
        final path = Path()
          ..moveTo(0, -p.size)
          ..lineTo(p.size * 0.6, 0)
          ..lineTo(0, p.size)
          ..lineTo(-p.size * 0.6, 0)
          ..close();
        canvas.drawPath(path, paint);
        canvas.restore();
      } else if (p.type == ParticleType.bombSmoke) {
        final smokePaint = Paint()
          ..color = p.color.withValues(alpha: (pOpacity * 0.6).clamp(0.0, 1.0))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawCircle(p.position, p.size, smokePaint);
      } else {
        canvas.drawCircle(p.position, p.size, paint);
      }
    }
  }

  void _drawFreezeOverlay(Canvas canvas, Size size) {
    // Frosty Border Vignette
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final frostGradient = RadialGradient(
      center: Alignment.center,
      radius: 0.9,
      colors: [
        Colors.transparent,
        const Color(0xFF80D8FF).withValues(alpha: 0.25),
        const Color(0xFF00E5FF).withValues(alpha: 0.55),
      ],
      stops: const [0.65, 0.85, 1.0],
    );
    final paint = Paint()..shader = frostGradient.createShader(rect);
    canvas.drawRect(rect, paint);
  }

  void _drawFrenzyBorder(Canvas canvas, Size size) {
    // Golden Fire Border
    final borderPaint = Paint()
      ..color = const Color(0xFFFFD600).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);
  }

  void _drawFloatingTexts(Canvas canvas) {
    for (final ft in floatingTexts) {
      final ftOpacity = ft.opacity.clamp(0.0, 1.0);
      final textSpan = TextSpan(
        text: ft.text,
        style: TextStyle(
          color: ft.color.withValues(alpha: ftOpacity),
          fontSize: max(10.0, ft.fontSize * ft.scale),
          fontWeight: FontWeight.w900,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.8 * ftOpacity),
              blurRadius: 6,
              offset: const Offset(2, 2),
            ),
            if (ft.hasGlow)
              Shadow(
                color: ft.color.withValues(alpha: 0.9 * ftOpacity),
                blurRadius: 16,
              ),
          ],
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        ft.position - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  void _drawCenteredText(
    Canvas canvas,
    String text,
    Offset center, {
    required double fontSize,
  }) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(fontSize: max(8.0, fontSize)),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) => true;
}
