import 'dart:math';
import 'package:flutter/material.dart';
import '../../game/blade_trail_manager.dart';
import '../../models/blade.dart';
import '../../models/dojo_theme.dart';
import '../../models/particle.dart';
import '../../services/audio_manager.dart';
import '../../services/storage_service.dart';
import '../theme/app_theme.dart';

class ShopScreen extends StatefulWidget {
  final StorageService storageService;
  final AudioManager audioManager;

  const ShopScreen({
    super.key,
    required this.storageService,
    required this.audioManager,
  });

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BladeTrailManager _testBladeTrail = BladeTrailManager();
  final List<Particle> _testParticles = [];
  late String _selectedBladeId;
  late String _selectedDojoId;
  late BladeSkin _previewBlade;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedBladeId = widget.storageService.selectedBladeId;
    _selectedDojoId = widget.storageService.selectedDojoId;
    _previewBlade = BladeSkin.getById(_selectedBladeId);
  }

  void _onPanUpdate(Offset pos) {
    _testBladeTrail.addPoint(pos);
    _testParticles.addAll(
      Particle.createBladeSparks(pos, _previewBlade.sparkColor, count: 2),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final coins = widget.storageService.coins;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            widget.audioManager.playButtonClick();
            Navigator.pop(context);
          },
        ),
        title: Text(
          'DOJO & BLADES SHOP',
          style: AppTheme.titleStyle(fontSize: 22, color: const Color(0xFFFFD700)),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: AppTheme.glassDecoration(
              opacity: 0.25,
              borderRadius: 16,
              borderColor: const Color(0xFFFFB300).withValues(alpha: 0.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on_rounded, color: Color(0xFFFFB300), size: 18),
                const SizedBox(width: 4),
                Text('$coins', style: AppTheme.titleStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFFD700),
          indicatorWeight: 3,
          labelStyle: AppTheme.titleStyle(fontSize: 16),
          tabs: const [
            Tab(text: '🗡️ BLADES'),
            Tab(text: '⛩️ DOJO THEMES'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF190B24), Color(0xFF0C0312)],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildBladesTab(),
            _buildDojosTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildBladesTab() {
    final unlockedBlades = widget.storageService.unlockedBladeIds;

    return Column(
      children: [
        // Interactive Blade Testing Area
        Container(
          height: 140,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _previewBlade.glowColor.withValues(alpha: 0.5), width: 1.5),
          ),
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (e) => _onPanUpdate(e.localPosition),
            onPointerMove: (e) => _onPanUpdate(e.localPosition),
            onPointerUp: (_) => _testBladeTrail.clear(),
            onPointerCancel: (_) => _testBladeTrail.clear(),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    '⚡ SWIPE HERE TO TEST BLADE ⚡',
                    style: AppTheme.bodyStyle(
                      fontSize: 14,
                      color: _previewBlade.trailColor.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: CustomPaint(
                    painter: _TestBladePainter(
                      bladeSkin: _previewBlade,
                      points: _testBladeTrail.points,
                      particles: _testParticles,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Blade Cards List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: BladeSkin.allBlades.length,
            itemBuilder: (_, index) {
              final blade = BladeSkin.allBlades[index];
              final isUnlocked = unlockedBlades.contains(blade.id);
              final isEquipped = blade.id == _selectedBladeId;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isEquipped
                      ? blade.glowColor.withValues(alpha: 0.25)
                      : Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isEquipped ? blade.trailColor : Colors.white12,
                    width: isEquipped ? 2.0 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    // Blade Color Dot & Glow
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [blade.coreColor, blade.trailColor],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: blade.glowColor,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.flash_on_rounded, color: Colors.black87, size: 22),
                      ),
                    ),

                    const SizedBox(width: 14),

                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            blade.name,
                            style: AppTheme.titleStyle(fontSize: 18, color: Colors.white),
                          ),
                          Text(
                            blade.description,
                            style: AppTheme.bodyStyle(fontSize: 12, color: Colors.white60),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Action Button
                    ElevatedButton(
                      onPressed: () async {
                        widget.audioManager.playButtonClick();
                        if (isUnlocked) {
                          await widget.storageService.setSelectedBladeId(blade.id);
                          setState(() {
                            _selectedBladeId = blade.id;
                            _previewBlade = blade;
                          });
                        } else {
                          // Try purchase
                          final success = await widget.storageService.spendCoins(blade.price);
                          if (success) {
                            await widget.storageService.unlockBlade(blade.id);
                            await widget.storageService.setSelectedBladeId(blade.id);
                            if (!mounted) return;
                            setState(() {
                              _selectedBladeId = blade.id;
                              _previewBlade = blade;
                            });
                          } else {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Not enough coins!')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isEquipped
                            ? const Color(0xFF10B981)
                            : isUnlocked
                                ? const Color(0xFF374151)
                                : const Color(0xFFFFB300),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isEquipped
                            ? 'EQUIPPED'
                            : isUnlocked
                                ? 'EQUIP'
                                : '${blade.price} 🪙',
                        style: AppTheme.titleStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDojosTab() {
    final unlockedDojos = widget.storageService.unlockedDojoIds;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: DojoTheme.allThemes.length,
      itemBuilder: (_, index) {
        final dojo = DojoTheme.allThemes[index];
        final isUnlocked = unlockedDojos.contains(dojo.id);
        final isEquipped = dojo.id == _selectedDojoId;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: dojo.backgroundGradient),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isEquipped ? dojo.accentColor : Colors.white12,
              width: isEquipped ? 2.0 : 1.0,
            ),
            boxShadow: isEquipped
                ? [
                    BoxShadow(
                      color: dojo.accentColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: dojo.wallBoardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: dojo.accentColor),
                ),
                child: const Center(
                  child: Icon(Icons.home_filled, color: Colors.white, size: 24),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dojo.name,
                      style: AppTheme.titleStyle(fontSize: 18, color: Colors.white),
                    ),
                    Text(
                      dojo.description,
                      style: AppTheme.bodyStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  widget.audioManager.playButtonClick();
                  if (isUnlocked) {
                    await widget.storageService.setSelectedDojoId(dojo.id);
                    setState(() => _selectedDojoId = dojo.id);
                  } else {
                    final success = await widget.storageService.spendCoins(dojo.price);
                    if (success) {
                      await widget.storageService.unlockDojo(dojo.id);
                      await widget.storageService.setSelectedDojoId(dojo.id);
                      if (!mounted) return;
                      setState(() => _selectedDojoId = dojo.id);
                    } else {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Not enough coins!')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEquipped
                      ? const Color(0xFF10B981)
                      : isUnlocked
                          ? const Color(0xFF374151)
                          : const Color(0xFFFFB300),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isEquipped
                      ? 'EQUIPPED'
                      : isUnlocked
                          ? 'EQUIP'
                          : '${dojo.price} 🪙',
                  style: AppTheme.titleStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TestBladePainter extends CustomPainter {
  final BladeSkin bladeSkin;
  final List<BladePoint> points;
  final List<Particle> particles;

  _TestBladePainter({
    required this.bladeSkin,
    required this.points,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final tipPoint = points.last.position;

    // Draw trail
    if (points.length > 1) {
      for (int i = 0; i < points.length - 1; i++) {
        final p1 = points[i];
        final p2 = points[i + 1];
        final ratio = (i + 1) / points.length;

        final glow = Paint()
          ..color = bladeSkin.glowColor.withValues(alpha: (0.65 * ratio).clamp(0.0, 1.0))
          ..strokeWidth = bladeSkin.baseWidth * 2.5 * ratio
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawLine(p1.position, p2.position, glow);

        final mid = Paint()
          ..color = bladeSkin.trailColor.withValues(alpha: (0.95 * ratio).clamp(0.0, 1.0))
          ..strokeWidth = bladeSkin.baseWidth * 1.3 * ratio
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(p1.position, p2.position, mid);

        final core = Paint()
          ..color = bladeSkin.coreColor
          ..strokeWidth = max(3.5, bladeSkin.baseWidth * 0.45 * ratio)
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(p1.position, p2.position, core);
      }
    }

    // Blade Tip Flare
    final headGlow = Paint()
      ..color = bladeSkin.glowColor.withValues(alpha: 0.85)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(tipPoint, bladeSkin.baseWidth * 0.9, headGlow);

    final headCore = Paint()..color = bladeSkin.coreColor;
    canvas.drawCircle(tipPoint, bladeSkin.baseWidth * 0.35, headCore);

    // Star flare
    final flarePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final flareLen = bladeSkin.baseWidth * 0.85;
    canvas.drawLine(tipPoint - Offset(flareLen, 0), tipPoint + Offset(flareLen, 0), flarePaint);
    canvas.drawLine(tipPoint - Offset(0, flareLen), tipPoint + Offset(0, flareLen), flarePaint);

    // Draw sparks
    for (final p in particles) {
      final paint = Paint()..color = p.color.withValues(alpha: p.opacity.clamp(0.0, 1.0));
      canvas.drawCircle(p.position, p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TestBladePainter oldDelegate) => true;
}
