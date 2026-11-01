import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../game/blade_trail_manager.dart';
import '../../game/game_controller.dart';
import '../../models/blade.dart';
import '../../models/fruit.dart';
import '../../models/particle.dart';
import '../../services/audio_manager.dart';
import '../../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/settings_dialog.dart';
import 'game_screen.dart';
import 'level_map_screen.dart';
import 'shop_screen.dart';

class HomeScreen extends StatefulWidget {
  final StorageService storageService;
  final AudioManager audioManager;

  const HomeScreen({
    super.key,
    required this.storageService,
    required this.audioManager,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;
  final BladeTrailManager _bladeTrail = BladeTrailManager();
  final List<Fruit> _menuFruits = [];
  final List<Particle> _particles = [];


  @override
  void initState() {
    super.initState();
    widget.audioManager.playMenuBgm();

    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _ticker.addListener(_updateMenuPhysics);
    _spawnInitialMenuFruits();
  }

  void _spawnInitialMenuFruits() {
    _menuFruits.add(
      Fruit.create(
        type: FruitType.watermelon,
        position: const Offset(80, 220),
        velocity: const Offset(0, 0),
      ),
    );
    _menuFruits.add(
      Fruit.create(
        type: FruitType.pineapple,
        position: const Offset(320, 260),
        velocity: const Offset(0, 0),
      ),
    );
    _menuFruits.add(
      Fruit.create(
        type: FruitType.dragonFruit,
        position: const Offset(200, 180),
        velocity: const Offset(0, 0),
      ),
    );
  }

  void _updateMenuPhysics() {
    // Gentle floating bob
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
    for (int i = 0; i < _menuFruits.length; i++) {
      final f = _menuFruits[i];
      if (!f.isSliced) {
        f.rotation += 0.02;
        f.position = Offset(
          f.position.dx,
          f.position.dy + sin(time * 2 + i) * 0.4,
        );
      } else {
        f.update(0.016);
      }
    }

    _bladeTrail.update();
    _particles.removeWhere((p) => !p.update(0.016));
    setState(() {});
  }

  void _onPanUpdate(Offset pos) {
    _bladeTrail.addPoint(pos);
    for (final fruit in _menuFruits) {
      if (!fruit.isSliced && _bladeTrail.checkIntersection(fruit.position, fruit.radius)) {
        fruit.slice(_bladeTrail.getLatestSwipeAngle());
        widget.audioManager.playSlice();
        _particles.addAll(
          Particle.createJuiceExplosion(fruit.position, fruit.juiceColor, count: 12),
        );
      }
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalStars = widget.storageService.totalStarsEarned;
    final coins = widget.storageService.coins;

    return Scaffold(
      body: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (e) => _onPanUpdate(e.localPosition),
        onPointerMove: (e) => _onPanUpdate(e.localPosition),
        onPointerUp: (_) => _bladeTrail.clear(),
        onPointerCancel: (_) => _bladeTrail.clear(),
        child: Stack(
          children: [
            // Dojo Background Image / Gradient
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF240B1D), Color(0xFF0F0510)],
                  ),
                ),
              ),
            ),

            // Canvas for floating sliceable fruits & blade trails
            Positioned.fill(
              child: CustomPaint(
                painter: _MenuCanvasPainter(
                  fruits: _menuFruits,
                  bladePoints: _bladeTrail.points,
                  particles: _particles,
                ),
              ),
            ),

            // Top Status Bar (Stars & Coins & Settings)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Stars Badge
                    _buildTopBadge(
                      icon: Icons.star_rounded,
                      iconColor: const Color(0xFFFFD700),
                      text: '$totalStars',
                    ),

                    // Coins Badge
                    _buildTopBadge(
                      icon: Icons.monetization_on_rounded,
                      iconColor: const Color(0xFFFFB300),
                      text: '$coins',
                    ),

                    // Settings Button
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(Icons.settings_rounded, color: Colors.white),
                      ),
                      onPressed: () {
                        widget.audioManager.playButtonClick();
                        showDialog(
                          context: context,
                          builder: (_) => SettingsDialog(
                            storageService: widget.storageService,
                            audioManager: widget.audioManager,
                          ),
                        ).then((_) => setState(() {}));
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Main Menu Content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),

                      // Game Title
                      Text(
                        'FRUIT',
                        style: AppTheme.titleStyle(
                          fontSize: 48,
                          color: const Color(0xFFFFD700),
                        ),
                      )
                          .animate()
                          .scale(duration: 500.ms, curve: Curves.easeOutBack),
                      Text(
                        'CUTTER',
                        style: AppTheme.titleStyle(
                          fontSize: 42,
                          color: const Color(0xFFFF1744),
                        ),
                      )
                          .animate()
                          .scale(delay: 200.ms, duration: 500.ms, curve: Curves.easeOutBack),

                      Text(
                        '✨ SWIPE TO SLICE FRUITS! ✨',
                        style: AppTheme.bodyStyle(fontSize: 13, color: Colors.white60),
                      ),

                      const SizedBox(height: 40),

                      // Adventure Mode Button (Infinite Levels)
                      _buildModeButton(
                        title: 'ADVENTURE LEVELS',
                        subtitle: 'Level ${widget.storageService.unlockedLevel} • Infinite Stages',
                        icon: Icons.military_tech_rounded,
                        primaryColor: const Color(0xFFFF6D00),
                        accentColor: const Color(0xFFFFD700),
                        onTap: () {
                          widget.audioManager.playButtonClick();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LevelMapScreen(
                                storageService: widget.storageService,
                                audioManager: widget.audioManager,
                              ),
                            ),
                          ).then((_) {
                            widget.audioManager.playMenuBgm();
                            setState(() {});
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Arcade Mode
                      _buildModeButton(
                        title: 'ARCADE FRENZY',
                        subtitle: '60s Time Attack • Combos & Bonuses',
                        icon: Icons.timer_rounded,
                        primaryColor: const Color(0xFF00E5FF),
                        accentColor: const Color(0xFF00B0FF),
                        onTap: () {
                          widget.audioManager.playButtonClick();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GameScreen(
                                mode: GameMode.arcade,
                                storageService: widget.storageService,
                                audioManager: widget.audioManager,
                              ),
                            ),
                          ).then((_) {
                            widget.audioManager.playMenuBgm();
                            setState(() {});
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Zen Mode
                      _buildModeButton(
                        title: 'ZEN MASTER',
                        subtitle: '3 Lives • Pure Slicing Meditation',
                        icon: Icons.spa_rounded,
                        primaryColor: const Color(0xFF10B981),
                        accentColor: const Color(0xFF34D399),
                        onTap: () {
                          widget.audioManager.playButtonClick();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GameScreen(
                                mode: GameMode.zen,
                                storageService: widget.storageService,
                                audioManager: widget.audioManager,
                              ),
                            ),
                          ).then((_) {
                            widget.audioManager.playMenuBgm();
                            setState(() {});
                          });
                        },
                      ),

                      const SizedBox(height: 24),

                      // Dojo & Blades Shop
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            widget.audioManager.playButtonClick();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ShopScreen(
                                  storageService: widget.storageService,
                                  audioManager: widget.audioManager,
                                ),
                              ),
                            ).then((_) => setState(() {}));
                          },
                          icon: const Icon(Icons.colorize_rounded, color: Color(0xFFFFD700)),
                          label: Text(
                            'DOJO & BLADES SHOP',
                            style: AppTheme.titleStyle(fontSize: 18, color: Colors.white),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFFFD700), width: 1.8),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBadge({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: AppTheme.glassDecoration(
        opacity: 0.3,
        borderRadius: 20,
        borderColor: Colors.white24,
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 6),
          Text(text, style: AppTheme.titleStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color primaryColor,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryColor.withValues(alpha: 0.85),
                primaryColor.withValues(alpha: 0.55),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accentColor.withValues(alpha: 0.6), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTheme.titleStyle(fontSize: 20)),
                    Text(subtitle, style: AppTheme.bodyStyle(fontSize: 13, color: Colors.white70)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCanvasPainter extends CustomPainter {
  final List<Fruit> fruits;
  final List<BladePoint> bladePoints;
  final List<Particle> particles;

  _MenuCanvasPainter({
    required this.fruits,
    required this.bladePoints,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw fruits
    for (final f in fruits) {
      if (!f.isSliced) {
        canvas.save();
        canvas.translate(f.position.dx, f.position.dy);
        canvas.rotate(f.rotation);

        final r = f.radius;
        final peelPaint = Paint()..color = f.outerColor;
        canvas.drawCircle(Offset.zero, r, peelPaint);

        final pulpPaint = Paint()..color = f.innerColor;
        canvas.drawCircle(Offset.zero, r * 0.82, pulpPaint);

        final textSpan = TextSpan(
          text: f.emoji,
          style: TextStyle(fontSize: r * 0.95),
        );
        final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
        tp.layout();
        tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));

        canvas.restore();
      } else {
        // Draw halves
        if (f.half1 != null) _drawHalf(canvas, f.half1!);
        if (f.half2 != null) _drawHalf(canvas, f.half2!);
      }
    }

    // Draw Particles
    for (final p in particles) {
      final paint = Paint()
        ..color = p.color.withValues(alpha: p.opacity.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(p.position, p.size, paint);
    }

    // Draw Blade Trail & Glow
    if (bladePoints.isNotEmpty) {
      final tipPoint = bladePoints.last.position;

      if (bladePoints.length > 1) {
        for (int i = 0; i < bladePoints.length - 1; i++) {
          final p1 = bladePoints[i];
          final p2 = bladePoints[i + 1];
          final ratio = (i + 1) / bladePoints.length;

          final glowPaint = Paint()
            ..color = const Color(0xFFFF9100).withValues(alpha: (0.6 * ratio).clamp(0.0, 1.0))
            ..strokeWidth = 24.0 * ratio
            ..strokeCap = StrokeCap.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
          canvas.drawLine(p1.position, p2.position, glowPaint);

          final midPaint = Paint()
            ..color = const Color(0xFFFFD700).withValues(alpha: (0.9 * ratio).clamp(0.0, 1.0))
            ..strokeWidth = 14.0 * ratio
            ..strokeCap = StrokeCap.round;
          canvas.drawLine(p1.position, p2.position, midPaint);

          final corePaint = Paint()
            ..color = Colors.white
            ..strokeWidth = 5.0 * ratio
            ..strokeCap = StrokeCap.round;
          canvas.drawLine(p1.position, p2.position, corePaint);
        }
      }

      // Blade Tip Flare
      final headGlow = Paint()
        ..color = const Color(0xFFFF9100).withValues(alpha: 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(tipPoint, 16.0, headGlow);

      final headCore = Paint()..color = Colors.white;
      canvas.drawCircle(tipPoint, 6.0, headCore);
    }
  }

  void _drawHalf(Canvas canvas, SlicedHalf half) {
    canvas.save();
    canvas.translate(half.position.dx, half.position.dy);
    canvas.rotate(half.rotation);
    final r = half.radius;
    final path = Path();
    if (half.isLeftHalf) {
      path.addArc(Rect.fromCircle(center: Offset.zero, radius: r), half.cutAngle + pi / 2, pi);
    } else {
      path.addArc(Rect.fromCircle(center: Offset.zero, radius: r), half.cutAngle - pi / 2, pi);
    }
    path.close();
    final peelPaint = Paint()..color = half.outerColor.withValues(alpha: half.opacity.clamp(0.0, 1.0));
    canvas.drawPath(path, peelPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MenuCanvasPainter oldDelegate) => true;
}
